"""Trajectory anti-pattern detection rules.

Each rule is a function: (TrajectoryGraph, Deployment) -> list[Violation].
Rules are registered in ALL_RULES and run by tracecheck.py.
"""


class Violation:
    """A detected anti-pattern in a trajectory."""

    def __init__(self, rule, event_id, message, severity="error"):
        self.rule = rule
        self.event_id = event_id
        self.message = message
        self.severity = severity  # "error" or "warning"

    def __str__(self):
        return f"[{self.severity}] {self.rule} at {self.event_id}: {self.message}"


# ---------------------------------------------------------------------------
# Rule 1: Circular verification
#
# For each 'verify' event, check if verification_target is an ancestor of
# the verify event in the dependency DAG. If yes, the verification is
# testing something that depends on itself — it can only return True.
#
# Real example (MacBeth Day 96): defined strictness via a circular
# definition, then ran a computation testing that definition.
# ---------------------------------------------------------------------------

def check_circular_verification(graph, deployment=None):
    """Detect verify events whose target is reachable from themselves."""
    violations = []

    for event in graph.verify_events():
        target_id = event.verification_target
        if target_id is None:
            continue

        ancestors = graph.ancestors(event.id)
        ancestors.discard(event.id)

        if target_id in ancestors:
            violations.append(Violation(
                rule="circular-verification",
                event_id=event.id,
                message=(
                    f"verification target '{target_id}' is an ancestor of this "
                    f"verify event — the evidence depends on the thing being "
                    f"verified, making the check tautological"
                ),
            ))

    return violations


# ---------------------------------------------------------------------------
# Rule 2: Tautological transport
#
# A 'verify' event verifying that a map F preserves a structure S, where
# S was DEFINED using F. The meta field must carry:
#   meta.preserves_structure: event ID of the structure definition
#   meta.preserving_map: event ID of the map introduction
#
# Detection: the structure definition event has the map introduction
# event in its transitive inputs.
#
# Real example (MacBeth Day 96): "I transported the structure along the
# functor, then congratulated the functor for preserving it."
# ---------------------------------------------------------------------------

def check_tautological_transport(graph, deployment=None):
    """Detect verify events where the preserved structure was defined using the preserving map."""
    violations = []

    for event in graph.verify_events():
        meta = event.meta
        structure_id = meta.get("preserves_structure")
        map_id = meta.get("preserving_map")

        if structure_id is None or map_id is None:
            continue

        # Check if the map introduction is in the ancestry of the structure definition
        structure_event = graph.events.get(structure_id)
        if structure_event is None:
            continue

        structure_ancestors = graph.ancestors(structure_id)
        if map_id in structure_ancestors:
            violations.append(Violation(
                rule="tautological-transport",
                event_id=event.id,
                message=(
                    f"structure '{structure_id}' was defined using map "
                    f"'{map_id}' — verifying that the map preserves the "
                    f"structure is tautological"
                ),
            ))

    return violations


# ---------------------------------------------------------------------------
# Rule 3: Estimand substitution
#
# A 'verify' or 'cite' event where the evidence's object tag disagrees
# with the claim's object tag. The outputs field carries object tags:
#   outputs: ["claim:kl-positivity:object=type-B3"]
#   outputs: ["result:spectrum:object=type-A2"]
#
# Detection: parse object tags from the verify event's inputs' outputs
# and from the verification target's outputs. If they disagree, the
# evidence was computed for a different object than the claim.
#
# Real example (Lyra GECCO): 13 instances where a correct number was
# cited against the wrong mathematical object.
# ---------------------------------------------------------------------------

def _parse_object_tag(output_str):
    """Extract object tag from an output string like 'result:spectrum:object=type-A2'."""
    for part in output_str.split(":"):
        if part.startswith("object="):
            return part[7:]
    return None


def _collect_object_tags(graph, event_id):
    """Collect all object tags from an event's outputs."""
    event = graph.events.get(event_id)
    if event is None:
        return set()
    tags = set()
    for out in event.outputs:
        tag = _parse_object_tag(out)
        if tag:
            tags.add(tag)
    return tags


def check_estimand_substitution(graph, deployment=None):
    """Detect verify/cite events where evidence object != claim object."""
    violations = []

    for event in graph.verify_events():
        target_id = event.verification_target
        if target_id is None:
            continue

        # Collect object tags from the claim (target)
        claim_objects = _collect_object_tags(graph, target_id)
        if not claim_objects:
            continue

        # Collect object tags from all evidence inputs
        evidence_objects = set()
        for inp_id in event.inputs:
            evidence_objects |= _collect_object_tags(graph, inp_id)

        if not evidence_objects:
            continue

        # If there are object tags on both sides and they don't overlap,
        # the evidence was computed for a different object
        if claim_objects and evidence_objects and not (claim_objects & evidence_objects):
            violations.append(Violation(
                rule="estimand-substitution",
                event_id=event.id,
                message=(
                    f"evidence objects {sorted(evidence_objects)} do not match "
                    f"claim objects {sorted(claim_objects)} — the evidence may "
                    f"have been computed for a different mathematical object"
                ),
            ))

    return violations


# ---------------------------------------------------------------------------
# Rule 4: Shallow source depth
#
# A 'claim' event at trajectory grade 'independent' or above where EVERY
# 'read' event in its transitive input closure has source_depth at or
# below a blocking threshold (default: 'agent-summary').
#
# This mirrors the source-blocking rule in trust-boundaries: a claim
# cannot reach a high trajectory grade if all its evidence comes from
# shallow reads.
#
# Real example (MacBeth Day 96): "the reproof→citation pattern has fired
# four times, and every time the scooping source was at agent-summary
# depth in sources.json."
# ---------------------------------------------------------------------------

# Source depth ordering (weakest to strongest)
SOURCE_DEPTH_RANK = {
    "recalled": 0,
    "agent-summary": 1,
    "rag-summary": 2,
    "abstract": 3,
    "chunk-read": 4,
    "context-read": 5,
    "deep-read": 6,
    "paper-read": 7,
    "verified-quote": 8,
}


def check_shallow_source_depth(graph, deployment=None):
    """Detect claims whose entire ancestry relies on shallow reads."""
    violations = []

    if deployment is None:
        return violations

    for rule_level, rule_config in deployment.source_blocking.items():
        blocking_depth = rule_config.get("all_reads_below")
        if blocking_depth is None:
            continue

        blocking_rank = SOURCE_DEPTH_RANK.get(blocking_depth, -1)

        for event in graph.claim_events():
            reads = graph.read_events_in_ancestry(event.id)
            if not reads:
                continue

            # Check if ALL reads are at or below the blocking depth
            all_shallow = all(
                SOURCE_DEPTH_RANK.get(r.source_depth, 0) <= blocking_rank
                for r in reads
            )

            if all_shallow:
                depths = [r.source_depth or "unknown" for r in reads]
                violations.append(Violation(
                    rule="shallow-source-depth",
                    event_id=event.id,
                    message=(
                        f"all {len(reads)} read(s) in ancestry are at or below "
                        f"'{blocking_depth}' depth {depths} — "
                        f"{rule_config.get('message', 'claim may lack sufficient source grounding')}"
                    ),
                    severity="warning",
                ))

    return violations


# ---------------------------------------------------------------------------
# Rule 5: Brief-as-deme (retrospective)
#
# A 'decide' event that chose path A (following the brief) over a
# sub-agent's recommended path B, where post-hoc evidence shows path A
# failed and path B succeeded.
#
# Detection requires meta fields:
#   meta.chose: event ID of the chosen path's claim
#   meta.rejected: event ID of the rejected alternative's claim
#   meta.chose_outcome: "dead-end" or "proved" (filled in retrospectively)
#   meta.rejected_outcome: "dead-end" or "proved" (filled in retrospectively)
#
# The rule fires when chose_outcome is worse than rejected_outcome.
#
# This rule is RETROSPECTIVE — it can only fire after outcomes are known.
# That is honest: you cannot detect "the brief is wrong" at the time you
# follow it, only after the alternative proves correct.
#
# Real example (Lyra GECCO): sub-agents contradicted the brief and were
# right. "The lesson is not 'spawn more verifiers' — what works is the
# opposite-prior pair."
# ---------------------------------------------------------------------------

OUTCOME_RANK = {
    "dead-end": 0,
    "refuted": 0,
    "abandoned": 0,
    "unresolved": 1,
    "in-progress": 1,
    "computed": 2,
    "checked-sober": 3,
    "proved": 4,
    "lean-verified": 5,
}


def check_brief_as_deme(graph, deployment=None):
    """Detect decide events where the chosen path failed and the rejected path succeeded."""
    violations = []

    for eid in graph.order:
        event = graph.events[eid]
        if event.kind != "decide":
            continue

        meta = event.meta
        chose_outcome = meta.get("chose_outcome")
        rejected_outcome = meta.get("rejected_outcome")

        if chose_outcome is None or rejected_outcome is None:
            continue

        chose_rank = OUTCOME_RANK.get(chose_outcome, -1)
        rejected_rank = OUTCOME_RANK.get(rejected_outcome, -1)

        if chose_rank < rejected_rank:
            violations.append(Violation(
                rule="brief-as-deme",
                event_id=event.id,
                message=(
                    f"chose path with outcome '{chose_outcome}' over rejected "
                    f"path with outcome '{rejected_outcome}' — the brief was "
                    f"the error source (retrospective detection)"
                ),
                severity="warning",
            ))

    return violations


ALL_RULES = [
    ("circular-verification", check_circular_verification),
    ("tautological-transport", check_tautological_transport),
    ("estimand-substitution", check_estimand_substitution),
    ("shallow-source-depth", check_shallow_source_depth),
    ("brief-as-deme", check_brief_as_deme),
]
