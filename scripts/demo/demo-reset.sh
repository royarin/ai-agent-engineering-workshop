#!/usr/bin/env bash
# Returns the repository to the Demo 1 starting line: the workshop-run baseline with
# nothing created yet.
#
# Removes everything the demo scripts write - docs/, .github/, .vscode/ - and restores
# src/ and tests/. Safe to run between rehearsals and before going on stage.
#
#   ./scripts/demo/demo-reset.sh            show what would be removed
#   ./scripts/demo/demo-reset.sh --apply    remove it

set -uo pipefail
cd "$(dirname "$0")/../.."

APPLY=0
[ "${1:-}" = "--apply" ] && APPLY=1

TARGETS="docs .github .vscode"

echo "Would remove (created by the demo scripts, none of it tracked):"
for t in $TARGETS; do
  [ -e "$t" ] && echo "  $t/" || echo "  $t/  (absent)"
done
echo
echo "Would restore from git:"
echo "  src/ tests/"
echo

if [ $APPLY -eq 0 ]; then
  echo "DRY RUN. Nothing changed. Re-run with --apply."
  exit 0
fi

for t in $TARGETS; do
  if [ -e "$t" ]; then rm -rf "$t"; echo "removed:  $t/"; fi
done
git restore src tests 2>/dev/null || true
git clean -fdq src tests 2>/dev/null || true
echo "restored: src/ tests/"
echo
echo "Verify:"
echo "  ./scripts/verify.sh   -> expect 3 passed, including No_review_endpoints_exist_yet"
