#!/usr/bin/env bash
# Stage 5 Level 6 - the preToolUse gate scripts and the config that switches them on.
#
# Content is identical to Module 08 (Stage 5), Level 6, Steps 1 and 2, which is where it is explained.
#
# SHORTCUT WARNING: if you are working through the workshop, write these by hand
# the first time. Understanding what is in them is the exercise.

set -euo pipefail
cd "$(dirname "$0")/../.."

mkdir -p ".github/hooks" ".github/hooks/scripts"

cat > ".github/hooks/scripts/block-dangerous-commands.sh" <<'___WORKSHOP_CONTENT___'
#!/usr/bin/env bash
# preToolUse gate. Reads the tool call on stdin, denies the ones we never want run.
#
# Contract: print nothing and exit 0 to allow. Print a permissionDecision to deny.
# Keep this under 5 seconds — see the warning about timeouts below.

set -uo pipefail

INPUT=$(cat)
CMD=$(printf '%s' "$INPUT" | jq -r '.toolArgs.command // empty' 2>/dev/null || true)

[ -z "$CMD" ] && exit 0

DENY_PATTERN='rm[[:space:]]+-rf|git[[:space:]]+push[[:space:]]+--force|git[[:space:]]+clean[[:space:]]+-fd([[:space:]]|$)|DROP[[:space:]]+TABLE|curl[^|]*\|[[:space:]]*(ba)?sh'

if printf '%s' "$CMD" | grep -qiE "$DENY_PATTERN"; then
  printf '%s' '{"permissionDecision":"deny","permissionDecisionReason":"Blocked by repository policy: destructive or unreviewed-execution command."}'
  exit 0
fi

exit 0
___WORKSHOP_CONTENT___
echo "wrote:   .github/hooks/scripts/block-dangerous-commands.sh"

cat > ".github/hooks/scripts/block-dangerous-commands.ps1" <<'___WORKSHOP_CONTENT___'
# preToolUse gate (PowerShell). See the .sh file for the contract.
$ErrorActionPreference = 'Stop'

$raw = [Console]::In.ReadToEnd()
if ([string]::IsNullOrWhiteSpace($raw)) { exit 0 }
try { $payload = $raw | ConvertFrom-Json } catch { exit 0 }

$cmd = $payload.toolArgs.command
if ([string]::IsNullOrWhiteSpace($cmd)) { exit 0 }

$deny = 'rm\s+-rf|git\s+push\s+--force|git\s+clean\s+-fd(\s|$)|DROP\s+TABLE|curl[^|]*\|\s*(ba)?sh|Remove-Item\s+.*-Recurse.*-Force'

if ($cmd -imatch $deny) {
    Write-Output '{"permissionDecision":"deny","permissionDecisionReason":"Blocked by repository policy: destructive or unreviewed-execution command."}'
}
exit 0
___WORKSHOP_CONTENT___
echo "wrote:   .github/hooks/scripts/block-dangerous-commands.ps1"

cat > ".github/hooks/guardrails.json" <<'___WORKSHOP_CONTENT___'
{
  "version": 1,
  "hooks": {
    "preToolUse": [
      {
        "type": "command",
        "bash": "./.github/hooks/scripts/block-dangerous-commands.sh",
        "powershell": "pwsh -NoProfile -File ./.github/hooks/scripts/block-dangerous-commands.ps1",
        "timeoutSec": 5
      }
    ],
    "agentStop": [
      {
        "type": "command",
        "bash": "dotnet test --nologo --filter FullyQualifiedName~SpaceRockIT.Reviews.Api.Tests",
        "powershell": "dotnet test --nologo --filter FullyQualifiedName~SpaceRockIT.Reviews.Api.Tests",
        "timeoutSec": 120
      }
    ]
  }
}
___WORKSHOP_CONTENT___
echo "wrote:   .github/hooks/guardrails.json"

chmod +x ".github/hooks/scripts/block-dangerous-commands.sh"

echo
cat <<'NOTE'
Shortcut used. This wrote content the workshop has you write yourself in
  Module 08 (Stage 5), Level 6, Steps 1 and 2

If you are following the workshop, open that module and read what you just
skipped. Knowing what is in these files, and why each line is there, is the
point of the exercise - having the files is not.

Before you test: hooks are read when a session starts, so writing these files
mid-session does nothing. Start a new session, and make sure this folder is
trusted (/add-dir) or the repository hook config is not loaded at all. Confirm
with /env, which lists the hooks actually in force.

To prove the preToolUse gate fires, ask the agent to run:

  echo 'DROP TABLE demo'

The command is harmless - it only prints text - but it matches the deny pattern,
so the gate has to deny it. That is the point: the test does not depend on the
model choosing to do something dangerous.
NOTE
