<#
.SYNOPSIS
  Returns the repository to the Demo 1 starting line: the workshop-run baseline with
  nothing created yet.

.DESCRIPTION
  Removes everything the demo scripts write - docs/, .github/, .vscode/ - and restores
  src/ and tests/. Safe to run between rehearsals and before going on stage.

.EXAMPLE
  .\scripts\demo\demo-reset.ps1
  Dry run.

.EXAMPLE
  .\scripts\demo\demo-reset.ps1 -Apply
#>
[CmdletBinding()]
param([switch]$Apply)

$ErrorActionPreference = 'Stop'
Set-Location (Join-Path $PSScriptRoot '../..')

$targets = 'docs', '.github', '.vscode'

Write-Host 'Would remove (created by the demo scripts, none of it tracked):'
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
Write-Host 'Verify:'
Write-Host '  .\scripts\verify.ps1   -> expect 3 passed, including No_review_endpoints_exist_yet'
