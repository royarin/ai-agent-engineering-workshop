#!/usr/bin/env bash
# Turn parts of the governance layer on and off, and add or remove the deliberate
# anti-pattern files, without editing anything by hand.
#
# The workshop builds these guardrails one at a time, so the "before" state happens
# naturally the first time through. This script gives you that "before" state again on
# demand — for re-running an exercise, for comparing behaviour, or for driving the
# conference demos, which walk the same ground faster.
#
#   ./scripts/toggle.sh status
#   ./scripts/toggle.sh disable instructions
#   ./scripts/toggle.sh enable  instructions
#   ./scripts/toggle.sh add-prop     conflicting-rule
#   ./scripts/toggle.sh remove-prop  conflicting-rule
#   ./scripts/toggle.sh reset                 # everything on, all props removed
#
# Layers: instructions | path-rules | hooks | agents | skills | mcp
# Props:  conflicting-rule | tool-starved
#
# Disabling renames a file to <name>.disabled. Nothing is deleted, and `reset` always
# puts it back.

set -uo pipefail
cd "$(dirname "$0")/.."

layer_path() {
  case "$1" in
    instructions) echo ".github/copilot-instructions.md" ;;
    path-rules)   echo ".github/instructions/reviews.instructions.md" ;;
    hooks)        echo ".github/hooks/guardrails.json" ;;
    agents)       echo ".github/agents" ;;
    skills)       echo ".github/skills" ;;
    mcp)          echo ".vscode/mcp.json" ;;
    *) return 1 ;;
  esac
}

prop_path() {
  case "$1" in
    conflicting-rule) echo ".github/instructions/rating-scale.instructions.md" ;;
    tool-starved)     echo ".github/agents/auditor-lite.agent.md" ;;
    *) return 1 ;;
  esac
}

write_prop() {
  case "$1" in
    conflicting-rule)
      mkdir -p .github/instructions
      cat > "$(prop_path conflicting-rule)" <<'PROP'
---
applyTo: "src/SpaceRockIT.Reviews.Api/**"
---

# Reviews module — rating scale

<!-- DEMO PROP. Contradicts copilot-instructions.md and reviews.instructions.md on purpose.
     Remove it with: ./scripts/toggle.sh remove-prop conflicting-rule -->

1. **Rating validation.** Ratings are integers from `1` to `10` inclusive. Anything outside
   that range returns HTTP `400 Bad Request`.

2. The ten-point scale is the house standard for all attendee-facing feedback surfaces.
PROP
      ;;
    tool-starved)
      mkdir -p .github/agents
      cat > "$(prop_path tool-starved)" <<'PROP'
---
name: auditor-lite
description: "Lightweight privacy auditor. Use for quick checks that attendee free text is redacted before it reaches logs, storage, or responses."
tools: ["view", "grep"]
---

# Auditor (Lite)

<!-- DEMO PROP. The instructions below demand a capability the tools list does not grant.
     Remove it with: ./scripts/toggle.sh remove-prop tool-starved -->

You are a fast, focused privacy auditor for the SpaceRockIT Reviews API.

1. Locate every path where attendee free text is logged, stored, or serialized into a response.
2. Confirm each one passes through the redaction helper first.
3. **Run the verification step described in the `pii-sanitizer` skill** and report the actual result.
4. Report PASS or FAIL per path, with the evidence that led you there.

## Constraints
- Read-only. Never edit a file.
- Never report PASS on the strength of reading the code. A path is verified when the
  verification step has run and produced output.
PROP
      ;;
  esac
}

cmd="${1:-status}"

case "$cmd" in
  status)
    echo "Governance layers"
    for l in instructions path-rules hooks agents skills mcp; do
      p=$(layer_path "$l")
      if   [ -e "$p" ];           then printf "  %-14s on       %s\n" "$l" "$p"
      elif [ -e "$p.disabled" ];  then printf "  %-14s DISABLED %s.disabled\n" "$l" "$p"
      else                             printf "  %-14s absent   %s\n" "$l" "$p"
      fi
    done
    echo
    echo "Demo props"
    any=0
    for d in conflicting-rule tool-starved; do
      p=$(prop_path "$d")
      if [ -e "$p" ]; then printf "  %-18s PRESENT  %s\n" "$d" "$p"; any=1
      else                 printf "  %-18s absent\n" "$d"; fi
    done
    if [ $any -eq 1 ]; then
      echo
      echo "A prop is in place. Remove it before a full run —"
      echo "a leftover conflicting rule changes what the agent builds."
    fi
    ;;

  disable|enable)
    layer="${2:-}"
    p=$(layer_path "$layer") || { echo "Unknown layer: ${layer:-<none>}" >&2; exit 1; }
    if [ "$cmd" = "disable" ]; then
      [ -e "$p" ] || { echo "Already off or absent: $p"; exit 0; }
      mv "$p" "$p.disabled" && echo "disabled: $p -> $p.disabled"
    else
      [ -e "$p.disabled" ] || { echo "Nothing disabled at: $p.disabled"; exit 0; }
      mv "$p.disabled" "$p" && echo "enabled:  $p"
    fi
    ;;

  add-prop)
    d="${2:-}"; prop_path "$d" >/dev/null || { echo "Unknown prop: ${d:-<none>}" >&2; exit 1; }
    write_prop "$d"; echo "added:   $(prop_path "$d")"
    echo "Remember: ./scripts/toggle.sh remove-prop $d"
    ;;

  remove-prop)
    d="${2:-}"; p=$(prop_path "$d") || { echo "Unknown prop: ${d:-<none>}" >&2; exit 1; }
    rm -f "$p" && echo "removed: $p"
    ;;

  reset)
    for l in instructions path-rules hooks agents skills mcp; do
      p=$(layer_path "$l")
      if [ -e "$p.disabled" ]; then mv "$p.disabled" "$p"; echo "enabled:  $p"; fi
    done
    for d in conflicting-rule tool-starved; do
      p=$(prop_path "$d")
      if [ -e "$p" ]; then rm -f "$p"; echo "removed:  $p"; fi
    done
    echo "All layers on, all props removed."
    ;;

  *)
    sed -n '2,25p' "$0" | sed 's/^# \{0,1\}//'
    exit 1
    ;;
esac
