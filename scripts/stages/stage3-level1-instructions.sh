#!/usr/bin/env bash
# Stage 3 Level 1 - the global repository instructions.
#
# Content is identical to Module 06 (Stage 3), Level 1, Step 1, which is where it is explained.
#
# SHORTCUT WARNING: if you are working through the workshop, write these by hand
# the first time. Understanding what is in them is the exercise.

set -euo pipefail
cd "$(dirname "$0")/../.."

mkdir -p ".github"

cat > ".github/copilot-instructions.md" <<'___WORKSHOP_CONTENT___'
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
___WORKSHOP_CONTENT___
echo "wrote:   .github/copilot-instructions.md"

echo
cat <<'NOTE'
Shortcut used. This wrote content the workshop has you write yourself in
  Module 06 (Stage 3), Level 1, Step 1

If you are following the workshop, open that module and read what you just
skipped. Knowing what is in these files, and why each line is there, is the
point of the exercise - having the files is not.
NOTE
