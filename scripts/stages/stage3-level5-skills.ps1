<#
.SYNOPSIS
  Stage 3 Level 5 - the four reusable skills.

.DESCRIPTION
  Content is identical to Module 06 (Stage 3), Level 5, Step 1, which is where it is explained.

  SHORTCUT WARNING: if you are working through the workshop, write these by hand
  the first time. Understanding what is in them is the exercise.
#>
[CmdletBinding()]
param([switch]$Remove)

$ErrorActionPreference = 'Stop'
Set-Location (Join-Path $PSScriptRoot '../..')

New-Item -ItemType Directory -Force -Path '.github/skills/pii-sanitizer' | Out-Null
$c0 = @'
---
name: pii-sanitizer
description: "Applies standard GDPR/PII email redaction patterns and sanitization algorithms to free-text user inputs, logging statements, and DTOs."
---

# Skill: PII Sanitizer (`pii-sanitizer`)

## Capabilities & Implementation Logic
- **Regex Standard:** Employs RFC 5322 regex: `[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}`.
- **Masking Strategy:** Replaces all email matches with `[redacted-email]`.
- **Implementation:** Injects C# sanitization filter: `Regex.Replace(input, pattern, "[redacted-email]")`.
'@
Set-Content -Path '.github/skills/pii-sanitizer/SKILL.md' -Value $c0 -Encoding UTF8
Write-Host 'wrote:   .github/skills/pii-sanitizer/SKILL.md'

New-Item -ItemType Directory -Force -Path '.github/skills/git-commit' | Out-Null
$c1 = @'
---
name: git-commit
description: "Inspects staged git changes and generates standardized Conventional Commit messages (feat, fix, test, docs, refactor, chore) with 72-character limits."
---

# Skill: Git Commit Message Generator (`git-commit`)

## Capabilities
Inspects staged diffs and formats standard Conventional Commits (`feat(module): ...`, `test(module): ...`).
'@
Set-Content -Path '.github/skills/git-commit/SKILL.md' -Value $c1 -Encoding UTF8
Write-Host 'wrote:   .github/skills/git-commit/SKILL.md'

New-Item -ItemType Directory -Force -Path '.github/skills/git-pr-summary' | Out-Null
$c2 = @'
---
name: git-pr-summary
description: "Inspects branch diffs against base branch to generate structured Pull Request descriptions with change summaries, issue linkages, and verification checklists."
---

# Skill: Pull Request Summary Generator (`git-pr-summary`)

## Capabilities
Analyzes full branch diffs against `main`, extracts issue linkages (`Closes #1`, or the issue
number assigned in your repository), and formats auditor-ready PR descriptions with verification checklists.
'@
Set-Content -Path '.github/skills/git-pr-summary/SKILL.md' -Value $c2 -Encoding UTF8
Write-Host 'wrote:   .github/skills/git-pr-summary/SKILL.md'

New-Item -ItemType Directory -Force -Path '.github/skills/adr' | Out-Null
$c3 = @'
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
'@
Set-Content -Path '.github/skills/adr/SKILL.md' -Value $c3 -Encoding UTF8
Write-Host 'wrote:   .github/skills/adr/SKILL.md'

Write-Host ''
Write-Host 'Shortcut used. This wrote content the workshop has you write yourself in' -ForegroundColor Yellow
Write-Host '  Module 06 (Stage 3), Level 5, Step 1' -ForegroundColor Yellow
Write-Host ''
Write-Host 'If you are following the workshop, open that module and read what you just'
Write-Host 'skipped. Knowing what is in these files, and why each line is there, is the'
Write-Host 'point of the exercise - having the files is not.'
