<#
.SYNOPSIS
  Stage 1 - the product objective and acceptance criteria.

.DESCRIPTION
  Content is identical to Module 02 (Stage 1), Step 1, which is where it is explained.

  SHORTCUT WARNING: if you are working through the workshop, write these by hand
  the first time. Understanding what is in them is the exercise.
#>
[CmdletBinding()]
param([switch]$Remove)

$ErrorActionPreference = 'Stop'
Set-Location (Join-Path $PSScriptRoot '../..')

New-Item -ItemType Directory -Force -Path 'docs/context' | Out-Null
$c0 = @'
# Product Objective: Workshop Reviews API

## Business Goal
Enable festival attendees to submit ratings and reviews for workshop sessions so that organizers can measure session quality and improve future festival editions.

## In-Scope Functionality
1. Accept attendee reviews containing a workshop identifier, attendee identifier, numeric rating, and optional comment via `POST /reviews`.
2. Provide aggregate review metrics per workshop (average rating and total submission count).
3. Log every accepted review with `ILogger` at `Information` level so operators can follow incoming submissions in the API console. The entry must include the workshop identifier and the submitted comment, for example: `Received review for ws-ai: <comment>`.

## Out-of-Scope (Strict Non-Goals)
- No user authentication or OAuth flows.
- No external database infrastructure (EF Core, SQL Server, PostgreSQL, SQLite).
- No message queues or external email notification services.
- Keep all data persistence in-memory.

## Primary Acceptance Criteria
- **AC 1 (Rating Range):** Ratings must be integer values between `1` (lowest) and `5` (highest) inclusive. Any rating outside this range must return HTTP `400 Bad Request`.
- **AC 2 (Required Fields):** `WorkshopId`, `AttendeeId`, and `Rating` are required.
- **AC 3 (Automated Testing):** All validation rules must be covered by automated xUnit tests.
'@
Set-Content -Path 'docs/context/product-objective.md' -Value $c0 -Encoding UTF8
Write-Host 'wrote:   docs/context/product-objective.md'

Write-Host ''
Write-Host 'Shortcut used. This wrote content the workshop has you write yourself in' -ForegroundColor Yellow
Write-Host '  Module 02 (Stage 1), Step 1' -ForegroundColor Yellow
Write-Host ''
Write-Host 'If you are following the workshop, open that module and read what you just'
Write-Host 'skipped. Knowing what is in these files, and why each line is there, is the'
Write-Host 'point of the exercise - having the files is not.'
