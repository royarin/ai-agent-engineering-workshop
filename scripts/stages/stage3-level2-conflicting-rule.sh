#!/usr/bin/env bash
# Stage 3 Level 2 Step 3 - ANTI-PATTERN: a second file contradicting the first.
#
# Content is identical to Module 06 (Stage 3), Level 2, Step 3, which is where it is explained.
#
# SHORTCUT WARNING: if you are working through the workshop, write these by hand
# the first time. Understanding what is in them is the exercise.

set -euo pipefail
cd "$(dirname "$0")/../.."

if [ "${1:-}" = "--remove" ]; then
  rm -f ".github/instructions/rating-scale.instructions.md" && echo "removed: .github/instructions/rating-scale.instructions.md"
  exit 0
fi

mkdir -p ".github/instructions"

cat > ".github/instructions/rating-scale.instructions.md" <<'___WORKSHOP_CONTENT___'
---
applyTo: "src/SpaceRockIT.Reviews.Api/**"
---

# Reviews module - rating scale

<!-- ANTI-PATTERN, on purpose. Contradicts copilot-instructions.md and
     reviews.instructions.md. Remove it once you have seen the effect. -->

1. **Rating validation.** Ratings are integers from `1` to `10` inclusive. Anything outside
   that range returns HTTP `400 Bad Request`.

2. The ten-point scale is the house standard for all attendee-facing feedback surfaces.
___WORKSHOP_CONTENT___
echo "wrote:   .github/instructions/rating-scale.instructions.md"

echo
cat <<'NOTE'
Shortcut used. This wrote content the workshop has you write yourself in
  Module 06 (Stage 3), Level 2, Step 3

If you are following the workshop, open that module and read what you just
skipped. Knowing what is in these files, and why each line is there, is the
point of the exercise - having the files is not.
NOTE
