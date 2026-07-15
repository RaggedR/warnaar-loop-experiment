"""Event schema validation and trajectory graph construction from JSONL."""

import json
from collections import defaultdict

VALID_KINDS = {"compute", "read", "claim", "verify", "cite", "delegate", "decide"}

REQUIRED_FIELDS = {"id", "kind", "action"}
OPTIONAL_FIELDS = {
    "timestamp", "agent", "phase", "inputs", "outputs",
    "source_depth", "verification_target", "verification_method", "meta",
}
ALL_FIELDS = REQUIRED_FIELDS | OPTIONAL_FIELDS


class SchemaError:
    def __init__(self, line, event_id, message):
        self.line = line
        self.event_id = event_id
        self.message = message

    def __str__(self):
        return f"line {self.line} ({self.event_id}): {self.message}"


class TrajectoryEvent:
    """A single event in a trajectory."""

    __slots__ = (
        "id", "timestamp", "agent", "phase", "kind", "action",
        "inputs", "outputs", "source_depth", "verification_target",
        "verification_method", "meta",
    )

    def __init__(self, data):
        self.id = data["id"]
        self.timestamp = data.get("timestamp")
        self.agent = data.get("agent")
        self.phase = data.get("phase")
        self.kind = data["kind"]
        self.action = data["action"]
        self.inputs = data.get("inputs", [])
        self.outputs = data.get("outputs", [])
        self.source_depth = data.get("source_depth")
        self.verification_target = data.get("verification_target")
        self.verification_method = data.get("verification_method")
        self.meta = data.get("meta", {})


class TrajectoryGraph:
    """DAG of trajectory events with dependency edges."""

    def __init__(self):
        self.events = {}          # id -> TrajectoryEvent
        self.children = defaultdict(list)   # id -> [ids that depend on it]
        self.order = []           # insertion order

    def add_event(self, event):
        self.events[event.id] = event
        self.order.append(event.id)
        for inp in event.inputs:
            self.children[inp].append(event.id)

    def ancestors(self, event_id, visited=None):
        """All transitive inputs (ancestors in the dependency DAG)."""
        if visited is None:
            visited = set()
        if event_id in visited:
            return visited
        visited.add(event_id)
        event = self.events.get(event_id)
        if event is None:
            return visited
        for inp in event.inputs:
            self.ancestors(inp, visited)
        return visited

    def is_reachable(self, source_id, target_id):
        """Can target_id be reached from source_id via the inputs relation?"""
        return target_id in self.ancestors(source_id)

    def verify_events(self):
        """Yield all events of kind 'verify'."""
        for eid in self.order:
            event = self.events[eid]
            if event.kind == "verify":
                yield event

    def claim_events(self):
        """Yield all events of kind 'claim'."""
        for eid in self.order:
            event = self.events[eid]
            if event.kind == "claim":
                yield event

    def read_events_in_ancestry(self, event_id):
        """All 'read' events in the transitive input closure of event_id."""
        anc = self.ancestors(event_id)
        return [
            self.events[eid] for eid in anc
            if eid in self.events and self.events[eid].kind == "read"
        ]


def validate_event(data, line_num):
    """Validate a single event dict. Returns list of SchemaErrors."""
    errors = []
    eid = data.get("id", f"<line {line_num}>")

    for field in REQUIRED_FIELDS:
        if field not in data:
            errors.append(SchemaError(line_num, eid, f"missing required field '{field}'"))

    if "kind" in data and data["kind"] not in VALID_KINDS:
        errors.append(SchemaError(
            line_num, eid,
            f"invalid kind '{data['kind']}', must be one of {sorted(VALID_KINDS)}",
        ))

    if "inputs" in data and not isinstance(data["inputs"], list):
        errors.append(SchemaError(line_num, eid, "'inputs' must be a list"))

    if "outputs" in data and not isinstance(data["outputs"], list):
        errors.append(SchemaError(line_num, eid, "'outputs' must be a list"))

    if data.get("kind") == "verify" and not data.get("verification_target"):
        errors.append(SchemaError(
            line_num, eid, "verify events must have a 'verification_target'",
        ))

    return errors


def load_trajectory(path):
    """Load a JSONL trajectory file. Returns (TrajectoryGraph, list[SchemaError])."""
    graph = TrajectoryGraph()
    errors = []
    seen_ids = set()

    with open(path) as f:
        for line_num, line in enumerate(f, 1):
            line = line.strip()
            if not line or line.startswith("#"):
                continue
            try:
                data = json.loads(line)
            except json.JSONDecodeError as e:
                errors.append(SchemaError(line_num, "<parse error>", str(e)))
                continue

            errs = validate_event(data, line_num)
            errors.extend(errs)

            if "id" in data:
                if data["id"] in seen_ids:
                    errors.append(SchemaError(
                        line_num, data["id"], "duplicate event id",
                    ))
                seen_ids.add(data["id"])

            # Check inputs reference known events
            for inp in data.get("inputs", []):
                if inp not in seen_ids:
                    errors.append(SchemaError(
                        line_num, data.get("id", f"<line {line_num}>"),
                        f"input '{inp}' references unknown event",
                    ))

            if not errs or all(e.message.startswith("input") for e in errs):
                event = TrajectoryEvent(data)
                graph.add_event(event)

    return graph, errors
