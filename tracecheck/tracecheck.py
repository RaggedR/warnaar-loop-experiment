#!/usr/bin/env python3
"""Trajectory validator CLI.

Usage:
    python3 tracecheck/tracecheck.py validate <trajectory.jsonl>
    python3 tracecheck/tracecheck.py check --deployment <deploy.json> <trajectory.jsonl>
    python3 tracecheck/tracecheck.py report --deployment <deploy.json> <trajectory.jsonl>
"""

import argparse
import json
import sys
from pathlib import Path

# Allow running as script or module
if __name__ == "__main__":
    sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from tracecheck.schema import load_trajectory, TrajectoryGraph
from tracecheck.rules import ALL_RULES, Violation


class Deployment:
    """Per-agent trajectory configuration, loaded from a JSON descriptor."""

    def __init__(self, path):
        with open(path) as f:
            data = json.load(f)

        traj = data["trajectory"]
        self.agent = data["agent"]
        self.chain = traj["chain"]
        self.boundary_at = traj["boundary_at"]
        self.source_blocking = traj.get("source_blocking", {})

        # Composition morphism psi: trajectory grade -> trust grade
        notes = data.get("notes", {})
        self.psi = notes.get("psi_sketch")

        # Trust chain for composition checks
        trust_chain_str = notes.get("trust_chain", "")
        if trust_chain_str:
            self._trust_chain = [t.strip() for t in trust_chain_str.split("<")]
            self._trust_rank = {level: i for i, level in enumerate(self._trust_chain)}
        else:
            self._trust_chain = []
            self._trust_rank = {}

        # Build ordinal map for the chain
        self._rank = {level: i for i, level in enumerate(self.chain)}

    def rank(self, level):
        """Ordinal position in the chain. Higher = more trusted."""
        if level not in self._rank:
            raise ValueError(f"unknown trajectory level '{level}' for agent {self.agent}")
        return self._rank[level]

    def at_or_above_boundary(self, level):
        return self.rank(level) >= self.rank(self.boundary_at)

    def trust_rank(self, level):
        """Ordinal position in the trust chain (for composition)."""
        return self._trust_rank.get(level)


def compute_trajectory_tau(graph, deployment):
    """Compute canonical trajectory grade for each event (bottom-up).

    tau(e) = min(own_grade(e), min(tau(d) for d in inputs(e)))

    Events without an explicit grade get 'unsupported'.
    """
    tau = {}
    chain = deployment.chain

    def own_grade(event):
        """Heuristic own-grade based on event kind and properties."""
        if event.kind == "verify":
            # Verify events that have a verification_method get that grade
            method = event.verification_method
            if method == "mechanically-checked":
                return "mechanically-checked"
            elif method == "cross-verified":
                return "cross-verified"
            elif method == "independent":
                return "independent"
            elif method in ("circular", "tautological"):
                return "unsupported"
            return "shallow"
        elif event.kind == "read":
            depth = event.source_depth
            if depth in ("deep-read", "paper-read", "context-read"):
                return "independent"
            elif depth in ("chunk-read", "rag-summary"):
                return "shallow"
            return "unsupported"
        elif event.kind == "compute":
            return "independent"
        elif event.kind == "claim":
            return "shallow"  # claims get grade from their inputs
        elif event.kind == "cite":
            return "shallow"
        elif event.kind in ("delegate", "decide"):
            return "shallow"
        return "unsupported"

    def compute_tau(event_id, visiting=None):
        if event_id in tau:
            return tau[event_id]
        if visiting is None:
            visiting = set()
        if event_id in visiting:
            # Cycle — degrade to bottom
            tau[event_id] = chain[0]
            return chain[0]
        visiting.add(event_id)

        event = graph.events.get(event_id)
        if event is None:
            tau[event_id] = chain[0]
            return chain[0]

        grade = own_grade(event)
        grade_rank = deployment.rank(grade)

        # Take min with all input taus
        for inp in event.inputs:
            inp_tau = compute_tau(inp, visiting)
            inp_rank = deployment.rank(inp_tau)
            if inp_rank < grade_rank:
                grade_rank = inp_rank
                grade = inp_tau

        tau[event_id] = chain[grade_rank] if grade_rank < len(chain) else chain[0]
        visiting.discard(event_id)
        return tau[event_id]

    for eid in graph.order:
        compute_tau(eid)

    return tau


def cmd_validate(args):
    """Validate event schema only."""
    graph, errors = load_trajectory(args.trajectory)

    if errors:
        print(f"Schema validation: {len(errors)} error(s)\n")
        for err in errors:
            print(f"  {err}")
        return 1

    print(f"Schema OK: {len(graph.events)} events, 0 errors")
    return 0


def cmd_check(args):
    """Run trajectory rules against a deployment."""
    graph, schema_errors = load_trajectory(args.trajectory)

    if schema_errors:
        print(f"Schema errors: {len(schema_errors)}")
        for err in schema_errors:
            print(f"  {err}")
        print()

    deployment = Deployment(args.deployment)

    all_violations = []
    for rule_name, rule_fn in ALL_RULES:
        violations = rule_fn(graph, deployment)
        all_violations.extend(violations)

    errors = [v for v in all_violations if v.severity == "error"]
    warnings = [v for v in all_violations if v.severity == "warning"]

    if all_violations:
        print(f"Trajectory check: {len(errors)} error(s), {len(warnings)} warning(s)\n")
        for v in all_violations:
            print(f"  {v}")
        return 1 if errors else 0

    print(f"Trajectory check: {len(graph.events)} events, 0 violations")
    return 0


def cmd_report(args):
    """Report trajectory grades for all events."""
    graph, schema_errors = load_trajectory(args.trajectory)

    if schema_errors:
        print(f"Schema errors: {len(schema_errors)}")
        for err in schema_errors:
            print(f"  {err}")
        print()
        if not graph.events:
            return 1

    deployment = Deployment(args.deployment)
    tau = compute_trajectory_tau(graph, deployment)

    # Run rules too
    all_violations = []
    for rule_name, rule_fn in ALL_RULES:
        all_violations.extend(rule_fn(graph, deployment))

    flagged = {v.event_id for v in all_violations}

    print(f"Trajectory report for {deployment.agent}")
    print(f"Chain: {' < '.join(deployment.chain)}")
    print(f"Boundary: {deployment.boundary_at}")
    print(f"Events: {len(graph.events)}")
    print()

    for eid in graph.order:
        event = graph.events[eid]
        grade = tau.get(eid, "?")
        flag = " ** FLAGGED **" if eid in flagged else ""
        inputs = ", ".join(event.inputs) if event.inputs else "(none)"
        print(f"  {eid:12s}  {event.kind:10s}  tau={grade:20s}  inputs=[{inputs}]{flag}")
        print(f"  {'':12s}  {event.action}")

    if all_violations:
        print(f"\nViolations ({len(all_violations)}):")
        for v in all_violations:
            print(f"  {v}")

    return 0


def cmd_compose(args):
    """Check trajectory grades against a trust-boundaries registry."""
    graph, schema_errors = load_trajectory(args.trajectory)

    if schema_errors:
        print(f"Schema errors: {len(schema_errors)}")
        for err in schema_errors:
            print(f"  {err}")
        print()

    deployment = Deployment(args.deployment)
    tau = compute_trajectory_tau(graph, deployment)

    # Load the psi morphism from deployment
    psi = deployment.psi
    if psi is None:
        print("Error: deployment has no psi morphism defined (notes.psi_sketch)")
        return 1

    # Load the trust-boundaries registry
    with open(args.registry) as f:
        registry = json.load(f)

    # Build a map from claim event outputs to registry node IDs
    # Convention: outputs like "claim:node-id" or meta.registry_node link events to nodes
    mismatches = []

    def walk_registry(node, path=""):
        """Walk registry tree, check each node against trajectory."""
        node_id = node.get("id", "?")
        node_trust = node.get("trust", "unclassified")

        # Find trajectory events that claim to support this node
        for eid in graph.order:
            event = graph.events[eid]
            # Match by: meta.registry_node, or output containing the node ID
            linked = False
            if event.meta.get("registry_node") == node_id:
                linked = True
            else:
                for out in event.outputs:
                    if out == f"claim:{node_id}" or out == f"registry:{node_id}":
                        linked = True
                        break

            if linked:
                traj_grade = tau.get(eid, deployment.chain[0])
                transported = psi.get(traj_grade)
                if transported is None:
                    continue

                # Check: psi(trajectory_tau) should be <= registry trust
                transported_rank = deployment.trust_rank(transported)
                registry_rank = deployment.trust_rank(node_trust)

                if transported_rank is not None and registry_rank is not None:
                    if transported_rank > registry_rank:
                        # Trajectory is stronger than registry claims — fine
                        pass
                    # The interesting case: registry claims more than trajectory supports
                    if registry_rank > transported_rank:
                        mismatches.append((eid, node_id, traj_grade, transported, node_trust))

        for child in node.get("children", []):
            walk_registry(child, f"{path}/{node_id}")

    tree = registry.get("tree")
    if tree:
        walk_registry(tree)

    if mismatches:
        print(f"Composition check: {len(mismatches)} mismatch(es)\n")
        for eid, nid, traj_g, transported, trust_g in mismatches:
            print(f"  event {eid} -> node {nid}: trajectory={traj_g} "
                  f"(psi={transported}) but registry claims {trust_g}")
        return 1

    linked_count = sum(
        1 for eid in graph.order
        if graph.events[eid].meta.get("registry_node") or
           any(o.startswith("claim:") or o.startswith("registry:") for o in graph.events[eid].outputs)
    )
    print(f"Composition check: {linked_count} linked events, 0 mismatches")
    return 0


def main():
    parser = argparse.ArgumentParser(
        description="Trajectory validator for AI agent reasoning paths",
    )
    sub = parser.add_subparsers(dest="command")

    p_validate = sub.add_parser("validate", help="Validate event schema")
    p_validate.add_argument("trajectory", help="Path to trajectory JSONL file")

    p_check = sub.add_parser("check", help="Check trajectory rules")
    p_check.add_argument("--deployment", required=True, help="Path to deployment JSON")
    p_check.add_argument("trajectory", help="Path to trajectory JSONL file")

    p_report = sub.add_parser("report", help="Report trajectory grades")
    p_report.add_argument("--deployment", required=True, help="Path to deployment JSON")
    p_report.add_argument("trajectory", help="Path to trajectory JSONL file")

    p_compose = sub.add_parser("compose", help="Check trajectory vs trust-boundaries registry")
    p_compose.add_argument("--deployment", required=True, help="Path to deployment JSON")
    p_compose.add_argument("--registry", required=True, help="Path to trust-boundaries registry JSON")
    p_compose.add_argument("trajectory", help="Path to trajectory JSONL file")

    args = parser.parse_args()

    if args.command == "validate":
        sys.exit(cmd_validate(args))
    elif args.command == "check":
        sys.exit(cmd_check(args))
    elif args.command == "report":
        sys.exit(cmd_report(args))
    elif args.command == "compose":
        sys.exit(cmd_compose(args))
    else:
        parser.print_help()
        sys.exit(1)


if __name__ == "__main__":
    main()
