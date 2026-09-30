<#
.SYNOPSIS
  Removes the review feature and the manual context folder, leaving the governance layer
  (.github/, .vscode/) untouched.

.DESCRIPTION
  Used by Module 07 (Stage 4) and by the conference demo script for Demo 6. The exercise
  answers one question: can the durable context rebuild the feature from nothing?

.EXAMPLE
  .\scripts\reset-feature.ps1
  Dry run — shows what would be removed.

.EXAMPLE
  .\scripts\reset-feature.ps1 -Apply
  Performs the reset.
#>
[CmdletBinding()]
param([switch]$Apply)

$ErrorActionPreference = 'Stop'
Set-Location (Join-Path $PSScriptRoot '..')

git rev-parse --git-dir *> $null
if ($LASTEXITCODE -ne 0) {
    Write-Error "Not a git repository. Run this from your clone of the workshop."
}

Write-Host "Restoring tracked files under src/ and tests/ ..." -ForegroundColor Cyan
if ($Apply) { git restore src tests } else { git status --porcelain src tests }

Write-Host ""
Write-Host "Untracked files that would be removed from src/ and tests/:" -ForegroundColor Cyan
git clean -nd src tests
if ($Apply) { git clean -fd src tests }

Write-Host ""
if (Test-Path docs) {
    Write-Host "Removing docs/ (manual context from Stages 1 and 2A - Stage 3 replaced it)" -ForegroundColor Cyan
    if ($Apply) { Remove-Item -Recurse -Force docs }
} else {
    Write-Host "No docs/ folder to remove."
}

Write-Host ""
if (-not $Apply) {
    Write-Host "DRY RUN. Nothing changed. Re-run with -Apply to perform the reset." -ForegroundColor Yellow
    exit 0
}

Write-Host "Governance layer left in place:" -ForegroundColor Green
foreach ($p in '.github', '.vscode') { if (Test-Path $p) { Write-Host "  kept: $p" } }

Write-Host ""
Write-Host "Reset complete. Verify with:"
Write-Host "  .\scripts\verify.ps1"
Write-Host ""
Write-Host "Expect three passing tests, including No_review_endpoints_exist_yet - that test only"
Write-Host "passes while /reviews returns 404, so it is your proof the feature is genuinely gone."
