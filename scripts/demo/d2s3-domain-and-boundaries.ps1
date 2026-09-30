<#
.SYNOPSIS
  Demo 2 Step 3 - the domain and policy context that closes the PII leak.

.DESCRIPTION
  Writes the file(s) below, overwriting any earlier copy, so the step is repeatable.
  Content is identical to Module 03 (Stage 2A), Steps 1a and 1b, which is where it is explained.

  SHORTCUT WARNING: if you are working through the workshop, write these by hand the
  first time. Understanding what is in them is the exercise.
#>
[CmdletBinding()]
param([switch]$Remove)

$ErrorActionPreference = 'Stop'
Set-Location (Join-Path $PSScriptRoot '../..')

New-Item -ItemType Directory -Force -Path 'docs/context' | Out-Null
$c0 = @'
# SpaceRockIT Festival — Domain Background & Operational Context

## Festival Overview
SpaceRockIT is a hybrid open-air IT conference and music festival in the Netherlands. Attendees participate in daytime informational and technical sessions in tents and attend live concerts in the evening.

## Operational Realities
1. **Flaky Open-Air Wi-Fi:** Festival network connectivity drops frequently. Clients will retry failed submissions, requiring idempotent handling.
2. **Attendee Privacy & GDPR Standards:**
   - Free-text comments submitted by attendees often inadvertently contain email addresses (e.g. *"Share your slides at alex.dev@enterprise.org"*).
   - Under European GDPR regulations, **email addresses must NEVER be logged in plain text or echoed in aggregate responses**.
   - All email patterns matching RFC 5322 must be sanitized to `[redacted-email]` prior to logging or storage.
'@
Set-Content -Path 'docs/context/spacerockit-domain.md' -Value $c0 -Encoding UTF8
Write-Host 'wrote:   docs/context/spacerockit-domain.md'

New-Item -ItemType Directory -Force -Path 'docs/policies' | Out-Null
$c1 = @'
# Architectural Boundaries & Scoping Policy

## Allowed File Modifications
When implementing API endpoints and tests:
- Source Code: `src/SpaceRockIT.Reviews.Api/**`
- Test Suites: `tests/SpaceRockIT.Reviews.Api.Tests/**`

## Forbidden Modifications (Out-of-Scope)
- Never modify solution structure or global project files (`*.sln`, `*.csproj` package references).
- Never introduce external database engines, ORMs, or distributed caches.
- Never modify authentication middleware or infrastructure scripts.
'@
Set-Content -Path 'docs/policies/api-boundaries.md' -Value $c1 -Encoding UTF8
Write-Host 'wrote:   docs/policies/api-boundaries.md'

Write-Host ''
Write-Host 'Shortcut used. This wrote files the workshop has you write yourself in' -ForegroundColor Yellow
Write-Host '  Module 03 (Stage 2A), Steps 1a and 1b' -ForegroundColor Yellow
Write-Host ''
Write-Host 'If you are following the workshop, open that module and read the content you just'
Write-Host 'skipped. Knowing what is in these files, and why each line is there, is the whole'
Write-Host 'point of the exercise - having the files is not.'
