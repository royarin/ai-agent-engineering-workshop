<#
.SYNOPSIS
  Demo 2 Step 4 - two hosted read-only GitHub MCP servers.

.DESCRIPTION
  Writes the file(s) below, overwriting any earlier copy, so the step is repeatable.
  Content is identical to Module 06 (Stage 3), Level 3, which is where it is explained.

  SHORTCUT WARNING: if you are working through the workshop, write these by hand the
  first time. Understanding what is in them is the exercise.
#>
[CmdletBinding()]
param([switch]$Remove)

$ErrorActionPreference = 'Stop'
Set-Location (Join-Path $PSScriptRoot '../..')

New-Item -ItemType Directory -Force -Path '.vscode' | Out-Null
$c0 = @'
{
  "$schema": "https://json.schemastore.org/mcp-settings.json",
  "servers": {
    "github-issues-readonly": {
      "type": "http",
      "url": "https://api.githubcopilot.com/mcp/x/issues/readonly",
      "description": "Hosted read-only access to GitHub repository issues and discussion comments."
    },
    "github-repos-readonly": {
      "type": "http",
      "url": "https://api.githubcopilot.com/mcp/x/repos/readonly",
      "description": "Hosted read-only access to repository tree, file contents, and commit history."
    }
  }
}
'@
Set-Content -Path '.vscode/mcp.json' -Value $c0 -Encoding UTF8
Write-Host 'wrote:   .vscode/mcp.json'

Write-Host ''
Write-Host 'Shortcut used. This wrote files the workshop has you write yourself in' -ForegroundColor Yellow
Write-Host '  Module 06 (Stage 3), Level 3' -ForegroundColor Yellow
Write-Host ''
Write-Host 'If you are following the workshop, open that module and read the content you just'
Write-Host 'skipped. Knowing what is in these files, and why each line is there, is the whole'
Write-Host 'point of the exercise - having the files is not.'
