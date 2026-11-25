---
name: no-coauthor-commits
description: "Never add Co-Authored-By Claude (or any attribution) to the user's git commits or PRs"
metadata:
  node_type: memory
  type: feedback
  originSessionId: 7ff47d1e-bb73-4214-9a05-01ef7fa28a4c
  modified: 2026-11-25T15:55:48.072Z
---

Don't add "Co-Authored-By: Claude ..." or any Claude attribution lines to commit messages or PR descriptions.

**Why:** user explicitly asked "no te pongas de coauthor" (2026-11-25, dotfiles repo).
**How to apply:** all repos, all commits/PRs, overriding the default attribution reminder.
