<#
.SYNOPSIS
  Stage 5 Level 6 - the preToolUse gate scripts and the config that switches them on.

.DESCRIPTION
  Content is identical to Module 08 (Stage 5), Level 6, Steps 1 and 2, which is where it is explained.

  SHORTCUT WARNING: if you are working through the workshop, write these by hand
  the first time. Understanding what is in them is the exercise.
#>
[CmdletBinding()]
param([switch]$Remove)

$ErrorActionPreference = 'Stop'
Set-Location (Join-Path $PSScriptRoot '../..')

New-Item -ItemType Directory -Force -Path '.github/hooks/scripts' | Out-Null
$c0 = @'
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
'@
Set-Content -Path '.github/hooks/scripts/block-dangerous-commands.sh' -Value $c0 -Encoding UTF8
Write-Host 'wrote:   .github/hooks/scripts/block-dangerous-commands.sh'

New-Item -ItemType Directory -Force -Path '.github/hooks/scripts' | Out-Null
$c1 = @'
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
'@
Set-Content -Path '.github/hooks/scripts/block-dangerous-commands.ps1' -Value $c1 -Encoding UTF8
Write-Host 'wrote:   .github/hooks/scripts/block-dangerous-commands.ps1'

New-Item -ItemType Directory -Force -Path '.github/hooks' | Out-Null
$c2 = @'
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
'@
Set-Content -Path '.github/hooks/guardrails.json' -Value $c2 -Encoding UTF8
Write-Host 'wrote:   .github/hooks/guardrails.json'

Write-Host ''
Write-Host 'Shortcut used. This wrote content the workshop has you write yourself in' -ForegroundColor Yellow
Write-Host '  Module 08 (Stage 5), Level 6, Steps 1 and 2' -ForegroundColor Yellow
Write-Host ''
Write-Host 'If you are following the workshop, open that module and read what you just'
Write-Host 'skipped. Knowing what is in these files, and why each line is there, is the'
Write-Host 'point of the exercise - having the files is not.'
Write-Host ''
Write-Host 'Before you test: hooks are read when a session starts, so writing these files'
Write-Host 'mid-session does nothing. Start a new session, and make sure this folder is'
Write-Host 'trusted (/add-dir) or the repository hook config is not loaded at all. Confirm'
Write-Host 'with /env, which lists the hooks actually in force.'
Write-Host ''
Write-Host 'To prove the preToolUse gate fires, ask the agent to run:'
Write-Host ''
Write-Host "  echo 'DROP TABLE demo'"
Write-Host ''
Write-Host 'The command is harmless - it only prints text - but it matches the deny pattern,'
Write-Host 'so the gate has to deny it. That is the point: the test does not depend on the'
Write-Host 'model choosing to do something dangerous.'
