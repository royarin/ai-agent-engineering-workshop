#!/usr/bin/env bash
# Demo 3 Step 2 - the global instructions file, including the destructive-command rule Demo 5 tests.
#
# Writes the file(s) below, overwriting any earlier copy, so the step is repeatable.
# Content is identical to Module 06 (Stage 3), Level 1 - plus the section 5 that Module 08 adds, which is where it is explained.
#
# SHORTCUT WARNING: if you are working through the workshop, write these by hand the
# first time. Understanding what is in them is the exercise.

set -euo pipefail
cd "$(dirname "$0")/../.."

mkdir -p ".github"

cat > ".github/copilot-instructions.md" <<'___DEMO_CONTENT___'
# Repository Instructions for SpaceRockIT

## 1. Architectural Boundaries & Permitted Modules
- You may ONLY modify files under `src/SpaceRockIT.Reviews.Api/` and `tests/SpaceRockIT.Reviews.Api.Tests/`.
- Never modify solution structure, CI/CD pipelines, or authentication middleware.
- Keep all data persistence in-memory (no EF Core, SQLite, or external databases).

## 2. Planning & Execution Pattern
- Always output a concise implementation plan before making edits.
- State which files will be modified and which tests will be added.

## 3. Testing Obligation
- Every business logic modification requires at least one automated xUnit test in `tests/SpaceRockIT.Reviews.Api.Tests/`.
- Always use synthetic test fixtures (e.g. `alex.dev@enterprise.org`, never real user data).

## 4. Privacy & Data Guardrails
- Sanitize free-text user inputs for email addresses before writing to logs or public response payloads.
- Use the `/skill pii-sanitizer` skill to apply the standard redaction logic.
## 5. Destructive operations

- Never run a destructive or irreversible shell command. This includes `rm -rf`,
  `git clean -fd`, `git push --force`, dropping tables, and piping a download into a shell.
- If a task appears to need one, stop and explain what you would run and why. The human decides.
- Prefer a reversible alternative when one exists.
___DEMO_CONTENT___
echo "wrote:   .github/copilot-instructions.md"

echo
cat <<'NOTE'
Shortcut used. This wrote files the workshop has you write yourself in
  Module 06 (Stage 3), Level 1 - plus the section 5 that Module 08 adds

If you are following the workshop, open that module and read the content you just
skipped. Knowing what is in these files, and why each line is there, is the whole
point of the exercise - having the files is not.
NOTE
