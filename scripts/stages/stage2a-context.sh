#!/usr/bin/env bash
# Stage 2A - the domain context and the architectural boundary policy.
#
# Content is identical to Module 03 (Stage 2A), Steps 1a and 1b, which is where it is explained.
#
# SHORTCUT WARNING: if you are working through the workshop, write these by hand
# the first time. Understanding what is in them is the exercise.

set -euo pipefail
cd "$(dirname "$0")/../.."

mkdir -p "docs/context" "docs/policies"

cat > "docs/context/spacerockit-domain.md" <<'___WORKSHOP_CONTENT___'
# SpaceRockIT Festival — Domain Background & Operational Context

## Festival Overview
SpaceRockIT is a hybrid open-air IT conference and music festival in the Netherlands. Attendees participate in daytime informational and technical sessions in tents and attend live concerts in the evening.

## Operational Realities
1. **Flaky Open-Air Wi-Fi:** Festival network connectivity drops frequently. Clients will retry failed submissions, requiring idempotent handling.
2. **Attendee Privacy & GDPR Standards:**
   - Free-text comments submitted by attendees often inadvertently contain email addresses (e.g. *"Share your slides at alex.dev@enterprise.org"*).
   - Under European GDPR regulations, **email addresses must NEVER be logged in plain text or echoed in aggregate responses**.
   - All email patterns matching RFC 5322 must be sanitized to `[redacted-email]` prior to logging or storage.
___WORKSHOP_CONTENT___
echo "wrote:   docs/context/spacerockit-domain.md"

cat > "docs/policies/api-boundaries.md" <<'___WORKSHOP_CONTENT___'
# Architectural Boundaries & Scoping Policy

## Allowed File Modifications
When implementing API endpoints and tests:
- Source Code: `src/SpaceRockIT.Reviews.Api/**`
- Test Suites: `tests/SpaceRockIT.Reviews.Api.Tests/**`

## Forbidden Modifications (Out-of-Scope)
- Never modify solution structure or global project files (`*.sln`, `*.csproj` package references).
- Never introduce external database engines, ORMs, or distributed caches.
- Never modify authentication middleware or infrastructure scripts.
___WORKSHOP_CONTENT___
echo "wrote:   docs/policies/api-boundaries.md"

echo
cat <<'NOTE'
Shortcut used. This wrote content the workshop has you write yourself in
  Module 03 (Stage 2A), Steps 1a and 1b

If you are following the workshop, open that module and read what you just
skipped. Knowing what is in these files, and why each line is there, is the
point of the exercise - having the files is not.
NOTE
