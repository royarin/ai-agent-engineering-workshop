<#
.SYNOPSIS
  Turn parts of the governance layer on and off, and add or remove the deliberate
  anti-pattern files, without editing anything by hand.

.DESCRIPTION
  The workshop builds these guardrails one at a time, so the "before" state happens
  naturally the first time through. This script gives you that "before" state again on
  demand - for re-running an exercise, for comparing behaviour, or for driving the
  conference demos, which walk the same ground faster.

  Layers: instructions | path-rules | hooks | agents | mcp
  Props:  conflicting-rule | tool-starved

  Disabling renames a file to <name>.disabled. Nothing is deleted, and reset puts it back.

.EXAMPLE
  .\scripts\toggle.ps1 status
.EXAMPLE
  .\scripts\toggle.ps1 disable instructions
.EXAMPLE
  .\scripts\toggle.ps1 add-prop conflicting-rule
.EXAMPLE
  .\scripts\toggle.ps1 reset
#>
[CmdletBinding()]
param(
    [Parameter(Position = 0)][string]$Command = 'status',
    [Parameter(Position = 1)][string]$Name
)

$ErrorActionPreference = 'Stop'
Set-Location (Join-Path $PSScriptRoot '..')

$Layers = [ordered]@{
    'instructions' = '.github/copilot-instructions.md'
    'path-rules'   = '.github/instructions/reviews.instructions.md'
    'hooks'        = '.github/hooks/guardrails.json'
    'agents'       = '.github/agents'
    'mcp'          = '.vscode/mcp.json'
}
$Props = [ordered]@{
    'conflicting-rule' = '.github/instructions/rating-scale.instructions.md'
    'tool-starved'     = '.github/agents/auditor-lite.agent.md'
}

$PropBody = @{
    'conflicting-rule' = @'
---
applyTo: "src/SpaceRockIT.Reviews.Api/**"
---

# Reviews module - rating scale

<!-- DEMO PROP. Contradicts copilot-instructions.md and reviews.instructions.md on purpose.
     Remove it with: .\scripts\toggle.ps1 remove-prop conflicting-rule -->

1. **Rating validation.** Ratings are integers from `1` to `10` inclusive. Anything outside
   that range returns HTTP `400 Bad Request`.

2. The ten-point scale is the house standard for all attendee-facing feedback surfaces.
'@
    'tool-starved' = @'
---
name: auditor-lite
description: "Lightweight privacy auditor. Use for quick checks that attendee free text is redacted before it reaches logs, storage, or responses."
tools: ["view", "grep"]
---

# Auditor (Lite)

<!-- DEMO PROP. The instructions below demand a capability the tools list does not grant.
     Remove it with: .\scripts\toggle.ps1 remove-prop tool-starved -->

You are a fast, focused privacy auditor for the SpaceRockIT Reviews API.

1. Locate every path where attendee free text is logged, stored, or serialized into a response.
2. Confirm each one passes through the redaction helper first.
3. **Run the verification step described in the `pii-sanitizer` skill** and report the actual result.
4. Report PASS or FAIL per path, with the evidence that led you there.

## Constraints
- Read-only. Never edit a file.
- Never report PASS on the strength of reading the code. A path is verified when the
  verification step has run and produced output.
'@
}

switch ($Command) {
    'status' {
        Write-Host "Governance layers"
        foreach ($l in $Layers.Keys) {
            $p = $Layers[$l]
            if     (Test-Path $p)             { "  {0,-14} on       {1}" -f $l, $p | Write-Host }
            elseif (Test-Path "$p.disabled")  { "  {0,-14} DISABLED {1}.disabled" -f $l, $p | Write-Host -ForegroundColor Yellow }
            else                              { "  {0,-14} absent   {1}" -f $l, $p | Write-Host -ForegroundColor DarkGray }
        }
        Write-Host ""
        Write-Host "Demo props"
        $any = $false
        foreach ($d in $Props.Keys) {
            if (Test-Path $Props[$d]) { "  {0,-18} PRESENT  {1}" -f $d, $Props[$d] | Write-Host -ForegroundColor Yellow; $any = $true }
            else                      { "  {0,-18} absent" -f $d | Write-Host -ForegroundColor DarkGray }
        }
        if ($any) {
            Write-Host ""
            Write-Host "A prop is in place. Remove it before a full run -" -ForegroundColor Yellow
            Write-Host "a leftover conflicting rule changes what the agent builds." -ForegroundColor Yellow
        }
    }

    { $_ -in 'disable', 'enable' } {
        if (-not $Layers.Contains($Name)) { Write-Error "Unknown layer: $Name" }
        $p = $Layers[$Name]
        if ($Command -eq 'disable') {
            if (-not (Test-Path $p)) { Write-Host "Already off or absent: $p"; break }
            Move-Item $p "$p.disabled"; Write-Host "disabled: $p -> $p.disabled"
        } else {
            if (-not (Test-Path "$p.disabled")) { Write-Host "Nothing disabled at: $p.disabled"; break }
            Move-Item "$p.disabled" $p; Write-Host "enabled:  $p"
        }
    }

    'add-prop' {
        if (-not $Props.Contains($Name)) { Write-Error "Unknown prop: $Name" }
        $p = $Props[$Name]
        New-Item -ItemType Directory -Force -Path (Split-Path $p) | Out-Null
        Set-Content -Path $p -Value $PropBody[$Name]
        Write-Host "added:   $p"
        Write-Host "Remember: .\scripts\toggle.ps1 remove-prop $Name"
    }

    'remove-prop' {
        if (-not $Props.Contains($Name)) { Write-Error "Unknown prop: $Name" }
        Remove-Item -Force $Props[$Name] -ErrorAction SilentlyContinue
        Write-Host "removed: $($Props[$Name])"
    }

    'reset' {
        foreach ($l in $Layers.Keys) {
            $p = $Layers[$l]
            if (Test-Path "$p.disabled") { Move-Item "$p.disabled" $p; Write-Host "enabled:  $p" }
        }
        foreach ($d in $Props.Keys) {
            if (Test-Path $Props[$d]) { Remove-Item -Force $Props[$d]; Write-Host "removed:  $($Props[$d])" }
        }
        Write-Host "All layers on, all props removed." -ForegroundColor Green
    }

    default { Get-Help $PSCommandPath -Detailed; exit 1 }
}
