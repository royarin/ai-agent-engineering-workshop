#!/usr/bin/env bash
# Returns the repository to the very beginning: the workshop-run baseline, with none of
# the artifacts any stage creates.
#
# Removes docs/, .github/ and .vscode/, and restores src/ and tests/. None of that is
# tracked by git, which is why whole directories can go safely.
#
# Use it to start the workshop over, or between rehearsals of the conference session.
# To remove only the review feature and keep the guardrails, use reset-feature instead.
#
#   ./scripts/reset-all.sh            show what would be removed
#   ./scripts/reset-all.sh --apply    remove it

set -uo pipefail
cd "$(dirname "$0")/.."

APPLY=0
[ "${1:-}" = "--apply" ] && APPLY=1

TARGETS="docs .github .vscode"

echo "Would remove:"
for t in $TARGETS; do
  if [ -e "$t" ]; then echo "  $t/"; else echo "  $t/  (absent)"; fi
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
echo "Verify with:"
echo "  ./scripts/verify.sh      -> expect 3 passed, including No_review_endpoints_exist_yet"
