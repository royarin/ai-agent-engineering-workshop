#!/usr/bin/env bash
# Demo 4 Step 1 - a persona whose tool grant cannot support its own instructions. Pass --remove to take it away.
#
# Writes the file(s) below, overwriting any earlier copy, so the step is repeatable.
# Content is identical to Module 06 (Stage 3), Level 4, Step 3, which is where it is explained.
#
# SHORTCUT WARNING: if you are working through the workshop, write these by hand the
# first time. Understanding what is in them is the exercise.

set -euo pipefail
cd "$(dirname "$0")/../.."

if [ "${1:-}" = "--remove" ]; then
  rm -f ".github/agents/auditor-lite.agent.md" && echo "removed: .github/agents/auditor-lite.agent.md"
  exit 0
fi

mkdir -p ".github/agents"

cat > ".github/agents/auditor-lite.agent.md" <<'___DEMO_CONTENT___'
---
name: auditor-lite
description: "Lightweight privacy auditor. Use for quick checks that attendee free text is redacted before it reaches logs, storage, or responses."
tools: ["view", "grep"]
---

# Auditor (Lite)

<!-- DEMO PROP. The instructions below demand a capability the tools list does not grant. -->

You are a fast, focused privacy auditor for the SpaceRockIT Reviews API.

1. Locate every path where attendee free text is logged, stored, or serialized into a response.
2. Confirm each one passes through the redaction helper first.
3. **Run the verification step described in the `pii-sanitizer` skill** and report the actual result.
4. Report PASS or FAIL per path, with the evidence that led you there.

## Constraints
- Read-only. Never edit a file.
- Never report PASS on the strength of reading the code. A path is verified when the
  verification step has run and produced output.
___DEMO_CONTENT___
echo "wrote:   .github/agents/auditor-lite.agent.md"

echo
cat <<'NOTE'
Shortcut used. This wrote files the workshop has you write yourself in
  Module 06 (Stage 3), Level 4, Step 3

If you are following the workshop, open that module and read the content you just
skipped. Knowing what is in these files, and why each line is there, is the whole
point of the exercise - having the files is not.
NOTE
