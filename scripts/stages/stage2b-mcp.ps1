<#
.SYNOPSIS
  Stage 2B - two hosted read-only GitHub MCP servers.

.DESCRIPTION
  Content is identical to Module 04 (Stage 2B), Step 2 - recommitted as Level 3 in Module 06, which is where it is explained.

  SHORTCUT WARNING: if you are working through the workshop, write these by hand
  the first time. Understanding what is in them is the exercise.
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
Write-Host 'Shortcut used. This wrote content the workshop has you write yourself in' -ForegroundColor Yellow
Write-Host '  Module 04 (Stage 2B), Step 2 - recommitted as Level 3 in Module 06' -ForegroundColor Yellow
Write-Host ''
Write-Host 'If you are following the workshop, open that module and read what you just'
Write-Host 'skipped. Knowing what is in these files, and why each line is there, is the'
Write-Host 'point of the exercise - having the files is not.'
