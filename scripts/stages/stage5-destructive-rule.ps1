<#
.SYNOPSIS
  Stage 5 Level 0 - appends the destructive-command rule to the global instructions.

.DESCRIPTION
  Content is identical to Module 08 (Stage 5), Level 0, which is where it is explained.

  SHORTCUT WARNING: if you are working through the workshop, write this by hand
  the first time. Understanding what is in it is the exercise.
#>
[CmdletBinding()] param()

$ErrorActionPreference = 'Stop'
Set-Location (Join-Path $PSScriptRoot '../..')

$target = '.github/copilot-instructions.md'

if (-not (Test-Path $target)) {
    Write-Host "ERROR: $target does not exist yet." -ForegroundColor Red
    Write-Host 'Run scripts/stages/stage3-level1-instructions.ps1 first (Module 06, Level 1).'
    exit 1
}

if ((Get-Content $target -Raw) -like '*## 5. Destructive operations*') {
    Write-Host "already present: $target already has the destructive-operations section"
    exit 0
}

$c = @'
## 5. Destructive operations

- Never run a destructive or irreversible shell command. This includes `rm -rf`,
  `git clean -fd`, `git push --force`, dropping tables, and piping a download into a shell.
- If a task appears to need one, stop and explain what you would run and why. The human decides.
- Prefer a reversible alternative when one exists.
'@
Add-Content -Path $target -Value "`n$c" -Encoding UTF8
Write-Host "appended: $target"

Write-Host ''
Write-Host 'Shortcut used. This wrote content the workshop has you write yourself in' -ForegroundColor Yellow
Write-Host '  Module 08 (Stage 5), Level 0' -ForegroundColor Yellow
Write-Host ''
Write-Host 'If you are following the workshop, open that module and read what you just'
Write-Host 'skipped. Knowing what is in these files, and why each line is there, is the'
Write-Host 'point of the exercise - having the files is not.'
