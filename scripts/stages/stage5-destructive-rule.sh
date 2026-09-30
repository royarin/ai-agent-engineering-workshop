#!/usr/bin/env bash
# Stage 5 Level 0 - appends the destructive-command rule to the global instructions.
#
# Content is identical to Module 08 (Stage 5), Level 0, which is where it is explained.
#
# SHORTCUT WARNING: if you are working through the workshop, write this by hand
# the first time. Understanding what is in it is the exercise.

set -euo pipefail
cd "$(dirname "$0")/../.."

TARGET=".github/copilot-instructions.md"

if [ ! -f "$TARGET" ]; then
  echo "ERROR: $TARGET does not exist yet." >&2
  echo "Run scripts/stages/stage3-level1-instructions.sh first (Module 06, Level 1)." >&2
  exit 1
fi

if grep -qF "## 5. Destructive operations" "$TARGET"; then
  echo "already present: $TARGET already has the destructive-operations section"
  exit 0
fi

printf '\n' >> "$TARGET"
cat >> "$TARGET" <<'___WORKSHOP_CONTENT___'
## 5. Destructive operations

- Never run a destructive or irreversible shell command. This includes `rm -rf`,
  `git clean -fd`, `git push --force`, dropping tables, and piping a download into a shell.
- If a task appears to need one, stop and explain what you would run and why. The human decides.
- Prefer a reversible alternative when one exists.
___WORKSHOP_CONTENT___
echo "appended: $TARGET"

echo
cat <<'NOTE'
Shortcut used. This wrote content the workshop has you write yourself in
  Module 08 (Stage 5), Level 0

If you are following the workshop, open that module and read what you just
skipped. Knowing what is in these files, and why each line is there, is the
point of the exercise - having the files is not.
NOTE
