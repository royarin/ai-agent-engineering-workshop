#!/usr/bin/env bash
# Starts both SpaceRockIT processes. Web: 5080, Reviews API: 5081.
set -euo pipefail
root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Reviews API -> http://localhost:5081"
dotnet run --project "$root/src/SpaceRockIT.Reviews.Api" --urls http://localhost:5081 &
echo "Web         -> http://localhost:5080"
dotnet run --project "$root/src/SpaceRockIT.Web" --urls http://localhost:5080 &

echo
echo "Open http://localhost:5080 -- give it a few seconds to build."
trap 'kill 0' EXIT
wait
