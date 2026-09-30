#!/usr/bin/env bash
# Runs the Reviews API test suite only. The solution also contains SpaceRockIT.Web tests,
# which are not part of the feature you are building, so every count quoted in the modules
# is scoped with this filter.

set -euo pipefail
cd "$(dirname "$0")/.."
exec dotnet test --nologo --filter FullyQualifiedName~SpaceRockIT.Reviews.Api.Tests "$@"
