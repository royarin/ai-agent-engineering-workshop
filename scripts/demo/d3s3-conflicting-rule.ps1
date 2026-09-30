<#
.SYNOPSIS
  Demo 3 Step 3 - a second path-scoped file that contradicts the first. Pass --remove to take it away.

.DESCRIPTION
  Writes the file(s) below, overwriting any earlier copy, so the step is repeatable.
  Content is identical to Module 06 (Stage 3), Level 2, Step 3, which is where it is explained.

  SHORTCUT WARNING: if you are working through the workshop, write these by hand the
  first time. Understanding what is in them is the exercise.
#>
[CmdletBinding()]
param([switch]$Remove)

$ErrorActionPreference = 'Stop'
Set-Location (Join-Path $PSScriptRoot '../..')

if ($Remove) {
    Remove-Item -Force '.github/instructions/rating-scale.instructions.md' -ErrorAction SilentlyContinue
    Write-Host 'removed: .github/instructions/rating-scale.instructions.md'
    exit 0
}

New-Item -ItemType Directory -Force -Path '.github/instructions' | Out-Null
$c0 = @'
---
applyTo: "src/SpaceRockIT.Reviews.Api/**"
---

# Reviews module - rating scale

<!-- DEMO PROP. Contradicts copilot-instructions.md and reviews.instructions.md on purpose. -->

1. **Rating validation.** Ratings are integers from `1` to `10` inclusive. Anything outside
   that range returns HTTP `400 Bad Request`.

2. The ten-point scale is the house standard for all attendee-facing feedback surfaces.
'@
Set-Content -Path '.github/instructions/rating-scale.instructions.md' -Value $c0 -Encoding UTF8
Write-Host 'wrote:   .github/instructions/rating-scale.instructions.md'

Write-Host ''
Write-Host 'Shortcut used. This wrote files the workshop has you write yourself in' -ForegroundColor Yellow
Write-Host '  Module 06 (Stage 3), Level 2, Step 3' -ForegroundColor Yellow
Write-Host ''
Write-Host 'If you are following the workshop, open that module and read the content you just'
Write-Host 'skipped. Knowing what is in these files, and why each line is there, is the whole'
Write-Host 'point of the exercise - having the files is not.'
