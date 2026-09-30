#!/usr/bin/env bash
# Removes the review feature and the manual context folder, and leaves the governance
# layer (.github/, .vscode/) untouched.
#
# Used by Module 07 (Stage 4) and by the conference demo script for Demo 6. The whole
# point of the exercise is to answer one question: can the durable context rebuild the
# feature from nothing?
#
#   ./scripts/reset-feature.sh            show what would be removed
#   ./scripts/reset-feature.sh --apply    actually remove it

set -euo pipefail
cd "$(dirname "$0")/.."

APPLY=0
[ "${1:-}" = "--apply" ] && APPLY=1

if ! git rev-parse --git-dir >/dev/null 2>&1; then
  echo "Not a git repository. Run this from your clone of the workshop." >&2
  exit 1
fi

echo "Restoring tracked files under src/ and tests/ ..."
[ $APPLY -eq 1 ] && git restore src tests || git status --porcelain src tests

echo
echo "Untracked files that would be removed from src/ and tests/:"
git clean -nd src tests
[ $APPLY -eq 1 ] && git clean -fd src tests

echo
if [ -d docs ]; then
  echo "Removing docs/ (manual context from Stages 1 and 2A — Stage 3 replaced it)"
  [ $APPLY -eq 1 ] && rm -rf docs
else
  echo "No docs/ folder to remove."
fi

echo
if [ $APPLY -eq 0 ]; then
  echo "DRY RUN. Nothing changed. Re-run with --apply to perform the reset."
  exit 0
fi

echo "Governance layer left in place:"
for p in .github .vscode; do
  [ -e "$p" ] && echo "  kept: $p"
done

echo
echo "Reset complete. Verify with:"
echo "  ./scripts/verify.sh"
echo
echo "Expect three passing tests, including No_review_endpoints_exist_yet — that test only"
echo "passes while /reviews returns 404, so it is your proof the feature is genuinely gone."
