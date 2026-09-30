<#
.SYNOPSIS
  Runs the Reviews API test suite only.

.DESCRIPTION
  The solution also contains SpaceRockIT.Web tests, which are not part of the feature you
  are building, so every count quoted in the modules is scoped with this filter.
#>
$ErrorActionPreference = 'Continue'
Set-Location (Join-Path $PSScriptRoot '..')
dotnet test --nologo --filter FullyQualifiedName~SpaceRockIT.Reviews.Api.Tests @args
exit $LASTEXITCODE
