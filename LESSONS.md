# LESSONS.md — rules for orchestrators of this experiment

Rules written after corrections from Robin. Review at session start.

1. **Handover files are layer-scoped and frozen.** HANDOVER-layerN.md is the
   record written after layer N completes. Never retro-edit an older handover
   with new decisions, and never append live layer-(N+1) state to it. Live
   state for the running layer goes in HANDOVER-layer(N+1).md (create it at
   layer launch; rewrite it into the final handover when the layer completes).
2. **Decisions go in the NEXT handover**, not retro-edited into old ones —
   old documents stay as records of their moment.
3. **Verify inherited environment claims before repeating or acting on
   them.** A handover said "this repo is NOT a git repo"; it was, and the
   false note left a handover uncommitted for a whole session. Claims about
   repo/remote/tool state cost one command to check (`git rev-parse
   --git-dir`, `git remote -v`) — run it before propagating the claim.
