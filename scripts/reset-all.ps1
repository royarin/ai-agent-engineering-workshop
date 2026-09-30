<#
.SYNOPSIS
  Returns the repository to the very beginning: the workshop-run baseline, with none of
  the artifacts any stage creates.

.DESCRIPTION
  Removes docs/, .github/ and .vscode/, and restores src/ and tests/. None of that is
  tracked by git, which is why whole directories can go safely.

  Use it to start the workshop over, or between rehearsals of the conference session.
  To remove only the review feature and keep the guardrails, use reset-feature instead.

.EXAMPLE
  .\scripts\reset-all.ps1
  Dry run.

.EXAMPLE
  .\scripts\reset-all.ps1 -Apply
#>
[CmdletBinding()]
param([switch]$Apply)

$ErrorActionPreference = 'Stop'
Set-Location (Join-Path $PSScriptRoot '..')

$targets = 'docs', '.github', '.vscode'

Write-Host 'Would remove:'
foreach ($t in $targets) {
    if (Test-Path $t) { Write-Host "  $t/" } else { Write-Host "  $t/  (absent)" -ForegroundColor DarkGray }
}
Write-Host ''
Write-Host 'Would restore from git:'
Write-Host '  src/ tests/'
Write-Host ''

if (-not $Apply) {
    Write-Host 'DRY RUN. Nothing changed. Re-run with -Apply.' -ForegroundColor Yellow
    exit 0
}

foreach ($t in $targets) {
    if (Test-Path $t) { Remove-Item -Recurse -Force $t; Write-Host "removed:  $t/" }
}
git restore src tests 2>$null
git clean -fdq src tests 2>$null
Write-Host 'restored: src/ tests/'
Write-Host ''
Write-Host 'Verify with:'
Write-Host '  .\scripts\verify.ps1     -> expect 3 passed, including No_review_endpoints_exist_yet'
