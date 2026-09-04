# Starts both SpaceRockIT processes on fixed ports.
#   Web         http://localhost:5080
#   Reviews API http://localhost:5081
# Fixed ports on purpose: every doc, prompt and slide references them, and a random
# port on the day is one more thing to fumble in front of an audience.

$ErrorActionPreference = 'Stop'
$root = $PSScriptRoot

Write-Host 'Reviews API -> http://localhost:5081' -ForegroundColor Cyan
Start-Process dotnet -ArgumentList @(
    'run', '--project', "$root/src/SpaceRockIT.Reviews.Api",
    '--urls', 'http://localhost:5081'
)

Write-Host 'Web         -> http://localhost:5080' -ForegroundColor Cyan
Start-Process dotnet -ArgumentList @(
    'run', '--project', "$root/src/SpaceRockIT.Web",
    '--urls', 'http://localhost:5080'
)

Write-Host ''
Write-Host 'Open http://localhost:5080 -- give it a few seconds to build.' -ForegroundColor Green
Write-Host 'The site works even if the Reviews API is down; that is by design.'
