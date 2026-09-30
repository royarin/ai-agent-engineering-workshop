#!/usr/bin/env bash
# Demo 3 Step 4 - the path-scoped instructions, scoped by applyTo to the Reviews API.
#
# Writes the file(s) below, overwriting any earlier copy, so the step is repeatable.
# Content is identical to Module 06 (Stage 3), Level 2, which is where it is explained.
#
# SHORTCUT WARNING: if you are working through the workshop, write these by hand the
# first time. Understanding what is in them is the exercise.

set -euo pipefail
cd "$(dirname "$0")/../.."

mkdir -p ".github/instructions"

cat > ".github/instructions/reviews.instructions.md" <<'___DEMO_CONTENT___'
---
applyTo: "src/SpaceRockIT.Reviews.Api/**"
---

# Review Module Guardrails

When modifying or generating code within `src/SpaceRockIT.Reviews.Api/`:

1. **Rating Validation:**  
   Ensure all ratings are validated to the `1`–`5` range (inclusive). Return HTTP `400 Bad Request` for out-of-range ratings.

2. **PII Sanitization:**  
   Attendee comments must be sanitized for email patterns prior to logging or echoing in aggregate endpoints using the `/skill pii-sanitizer` skill.

3. **Testing Obligation:**  
   Every logic change in this module requires at least one automated xUnit test in `tests/SpaceRockIT.Reviews.Api.Tests/` using synthetic test fixtures.

4. **Observability:**  
   Log every accepted review with `ILogger` at `Information` level, including the workshop identifier, attendee identifier, rating, and the sanitized comment. Always log the redacted comment, never the raw input.
___DEMO_CONTENT___
echo "wrote:   .github/instructions/reviews.instructions.md"

echo
cat <<'NOTE'
Shortcut used. This wrote files the workshop has you write yourself in
  Module 06 (Stage 3), Level 2

If you are following the workshop, open that module and read the content you just
skipped. Knowing what is in these files, and why each line is there, is the whole
point of the exercise - having the files is not.
NOTE
