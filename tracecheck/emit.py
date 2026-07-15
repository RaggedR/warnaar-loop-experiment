"""Lightweight trajectory event emitter for agents.

Usage:
    from tracecheck.emit import init, emit

    init("clio", "prove")
    e1 = emit("read", "read paper 2412.19383", source_depth="deep-read")
    e2 = emit("compute", "computed spectrum at q=zeta_p", inputs=[e1])
    e3 = emit("claim", "spectrum reproduces mod-4 box", inputs=[e2])
    e4 = emit("verify", "checked claim against independent computation",
              inputs=[e2], verification_target=e3)

Events are appended to a JSONL file, one per line.
"""

import json
import os
import time

_LOG = None
_SEQ = 0
_AGENT = None


def init(agent_name, phase, log_dir=None):
    """Initialize the emitter for a session.

    Creates a JSONL file at:
        <log_dir>/<agent>-<phase>-<timestamp>.jsonl
    """
    global _LOG, _SEQ, _AGENT
    _AGENT = agent_name
    if log_dir is None:
        log_dir = os.path.join("state", "trajectory")
    os.makedirs(log_dir, exist_ok=True)
    _LOG = os.path.join(log_dir, f"{agent_name}-{phase}-{int(time.time())}.jsonl")
    _SEQ = 0
    return _LOG


def emit(kind, action, inputs=None, outputs=None, **kwargs):
    """Emit a trajectory event. Returns the event ID.

    Args:
        kind: one of compute, read, claim, verify, cite, delegate, decide
        action: human-readable description of what was done
        inputs: list of event IDs this event depends on
        outputs: list of artifact references produced
        **kwargs: optional fields (source_depth, verification_target, meta, etc.)
    """
    global _SEQ
    if _LOG is None:
        raise RuntimeError("call init() before emit()")

    _SEQ += 1
    event_id = f"evt-{_SEQ:04d}"

    event = {
        "id": event_id,
        "timestamp": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
        "agent": _AGENT,
        "kind": kind,
        "action": action,
        "inputs": inputs or [],
        "outputs": outputs or [],
    }
    event.update(kwargs)

    with open(_LOG, "a") as f:
        f.write(json.dumps(event) + "\n")

    return event_id
