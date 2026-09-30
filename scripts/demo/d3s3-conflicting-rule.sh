#!/usr/bin/env bash
# Demo 3 Step 3 - a second path-scoped file that contradicts the first. Pass --remove to take it away.
#
# Writes the file(s) below, overwriting any earlier copy, so the step is repeatable.
# Content is identical to Module 06 (Stage 3), Level 2, Step 3, which is where it is explained.
#
# SHORTCUT WARNING: if you are working through the workshop, write these by hand the
# first time. Understanding what is in them is the exercise.

set -euo pipefail
cd "$(dirname "$0")/../.."

if [ "${1:-}" = "--remove" ]; then
  rm -f ".github/instructions/rating-scale.instructions.md" && echo "removed: .github/instructions/rating-scale.instructions.md"
  exit 0
fi

mkdir -p ".github/instructions"

cat > ".github/instructions/rating-scale.instructions.md" <<'___DEMO_CONTENT___'
---
applyTo: "src/SpaceRockIT.Reviews.Api/**"
---

# Reviews module - rating scale

<!-- DEMO PROP. Contradicts copilot-instructions.md and reviews.instructions.md on purpose. -->

1. **Rating validation.** Ratings are integers from `1` to `10` inclusive. Anything outside
   that range returns HTTP `400 Bad Request`.

2. The ten-point scale is the house standard for all attendee-facing feedback surfaces.
___DEMO_CONTENT___
echo "wrote:   .github/instructions/rating-scale.instructions.md"

echo
cat <<'NOTE'
Shortcut used. This wrote files the workshop has you write yourself in
  Module 06 (Stage 3), Level 2, Step 3

If you are following the workshop, open that module and read the content you just
skipped. Knowing what is in these files, and why each line is there, is the whole
point of the exercise - having the files is not.
NOTE
