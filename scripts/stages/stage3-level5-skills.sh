#!/usr/bin/env bash
# Stage 3 Level 5 - the four reusable skills.
#
# Content is identical to Module 06 (Stage 3), Level 5, Step 1, which is where it is explained.
#
# SHORTCUT WARNING: if you are working through the workshop, write these by hand
# the first time. Understanding what is in them is the exercise.

set -euo pipefail
cd "$(dirname "$0")/../.."

mkdir -p ".github/skills/pii-sanitizer" \
  ".github/skills/git-commit" \
  ".github/skills/git-pr-summary" \
  ".github/skills/adr"

cat > ".github/skills/pii-sanitizer/SKILL.md" <<'___WORKSHOP_CONTENT___'
---
name: pii-sanitizer
description: "Applies standard GDPR/PII email redaction patterns and sanitization algorithms to free-text user inputs, logging statements, and DTOs."
---

# Skill: PII Sanitizer (`pii-sanitizer`)

## Capabilities & Implementation Logic
- **Regex Standard:** Employs RFC 5322 regex: `[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}`.
- **Masking Strategy:** Replaces all email matches with `[redacted-email]`.
- **Implementation:** Injects C# sanitization filter: `Regex.Replace(input, pattern, "[redacted-email]")`.
___WORKSHOP_CONTENT___
echo "wrote:   .github/skills/pii-sanitizer/SKILL.md"

cat > ".github/skills/git-commit/SKILL.md" <<'___WORKSHOP_CONTENT___'
---
name: git-commit
description: "Inspects staged git changes and generates standardized Conventional Commit messages (feat, fix, test, docs, refactor, chore) with 72-character limits."
---

# Skill: Git Commit Message Generator (`git-commit`)

## Capabilities
Inspects staged diffs and formats standard Conventional Commits (`feat(module): ...`, `test(module): ...`).
___WORKSHOP_CONTENT___
echo "wrote:   .github/skills/git-commit/SKILL.md"

cat > ".github/skills/git-pr-summary/SKILL.md" <<'___WORKSHOP_CONTENT___'
---
name: git-pr-summary
description: "Inspects branch diffs against base branch to generate structured Pull Request descriptions with change summaries, issue linkages, and verification checklists."
---

# Skill: Pull Request Summary Generator (`git-pr-summary`)

## Capabilities
Analyzes full branch diffs against `main`, extracts issue linkages (`Closes #1`, or the issue
number assigned in your repository), and formats auditor-ready PR descriptions with verification checklists.
___WORKSHOP_CONTENT___
echo "wrote:   .github/skills/git-pr-summary/SKILL.md"

cat > ".github/skills/adr/SKILL.md" <<'___WORKSHOP_CONTENT___'
---
name: adr
description: "Writes an Architecture Decision Record into docs/adr/ using the project's standard format. Use when a decision needs recording, when the user mentions an ADR or a decision record, or after a change that locks in a constraint future contributors must not casually undo."
---

# Skill: Architecture Decision Record (`adr`)

## When a decision is worth a record
Write one when the decision constrains future work and the reason is not obvious from the code: a technology deliberately rejected, a boundary deliberately drawn, a regulatory obligation, a trade-off with a real cost. Do **not** write one for a naming choice or a refactor.

## Steps
1. Find the highest existing number in `docs/adr/`. Yours is the next one, zero-padded to four digits.
2. Name the file `NNNN-kebab-case-title.md`. The title states the decision, not the topic: `0002-redact-email-before-logging`, not `0002-logging`.
3. Fill every section of the template. No placeholders left behind.
4. Cite the origin of the constraint — ticket, policy page, or instruction file. For repository boundaries, cite the relevant section of `.github/copilot-instructions.md`; cite the linked PII policy page when it drives the decision.
5. Include the exact test result supplied by `@tester` in the Verification section and attribute it to that agent. If the supervisor did not supply a result, state that no test result was provided; never invent one.

## Template
```markdown
# NNNN. <the decision, as a statement>

- **Status:** Accepted
- **Date:** <YYYY-MM-DD>
- **Source:** <ticket, policy page, or instruction file that drove this>

## Context
What was true that forced a decision, including the constraint that makes the obvious alternative wrong.

## Decision
What we do now, in the present tense. One paragraph.

## Consequences
What this makes easy, what it makes hard, and what a future contributor must not do without revisiting this record.

## Verification
Record the exact test summary reported by `@tester`, attributed to that agent. If no test result was provided, say so.

## Alternatives considered
Each rejected option and the specific reason it was rejected. "It was worse" is not a reason.
___WORKSHOP_CONTENT___
echo "wrote:   .github/skills/adr/SKILL.md"

echo
cat <<'NOTE'
Shortcut used. This wrote content the workshop has you write yourself in
  Module 06 (Stage 3), Level 5, Step 1

If you are following the workshop, open that module and read what you just
skipped. Knowing what is in these files, and why each line is there, is the
point of the exercise - having the files is not.
NOTE
