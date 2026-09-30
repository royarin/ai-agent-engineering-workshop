# Demo scripts — shortcuts that write the workshop's files for you

> [!WARNING]
> **These are shortcuts, and shortcuts skip the learning.**
>
> Every file these scripts write is a file the workshop has you write yourself, in a module
> that explains what each line is for and why it is there. Running a script gets you the
> file. It does not get you the understanding, and the understanding is the point.
>
> **The first time through, write them by hand.** Come back to these afterwards.

## When they are genuinely useful

- **Re-running an exercise.** You want to see the Level 0 → Level 1 comparison again without
  retyping 40 lines.
- **Catching up.** You fell behind, or joined late, and need to reach the state a later
  module assumes.
- **Resetting between runs.** `demo-reset.sh` puts the repository back to the starting line.
- **Presenting.** The conference session walks the same ground in 45 minutes, and typing is
  not a good use of them.

## What each one writes

Named `d<demo><step>` after the conference demo that uses it. The workshop module in the
last column is where the content is actually explained — read that, not the script.

| Script | Writes | Explained in |
|---|---|---|
| `d1s4-product-objective` | `docs/context/product-objective.md` | Module 02 (Stage 1), Step 1 |
| `d2s3-domain-and-boundaries` | `docs/context/spacerockit-domain.md`, `docs/policies/api-boundaries.md` | Module 03 (Stage 2A), Steps 1a–1b |
| `d2s4-mcp` | `.vscode/mcp.json` | Module 06 (Stage 3), Level 3 |
| `d3s2-repo-instructions` | `.github/copilot-instructions.md` | Module 06 Level 1, plus the section 5 Module 08 adds |
| `d3s3-conflicting-rule` | A rating rule that contradicts the others — **an anti-pattern, on purpose** | Module 06, Level 2, Step 3 |
| `d3s4-path-rules` | `.github/instructions/reviews.instructions.md` | Module 06 (Stage 3), Level 2 |
| `d4s0-roster` | Four agents, the supervisor, four skills | Module 06 Levels 4–5, Module 07 Step 2 |
| `d4s1-tool-starved` | A persona whose grant cannot support its instructions — **an anti-pattern, on purpose** | Module 06, Level 4, Step 3 |
| `d5s2-hooks` | Both gate scripts and `guardrails.json` | Module 08 (Stage 5), Steps 1–2 |
| `demo-reset` | Nothing — **removes** `docs/`, `.github/`, `.vscode/` and restores `src/`, `tests/` | — |

## Using them

```bash
./scripts/demo/d3s2-repo-instructions.sh          # writes the file
./scripts/demo/d3s3-conflicting-rule.sh           # adds the anti-pattern
./scripts/demo/d3s3-conflicting-rule.sh --remove  # takes it away again
./scripts/demo/demo-reset.sh                      # dry run
./scripts/demo/demo-reset.sh --apply              # back to the starting line
```

On Windows use the `.ps1` alongside each one, with `-Remove` and `-Apply` instead.

Every script overwrites rather than appends, so running one twice is harmless.

## The two anti-pattern scripts

`d3s3-conflicting-rule` and `d4s1-tool-starved` write files that are **deliberately wrong**.
They exist so you can watch a specific failure happen: a rule silently losing a coin-flip
against a duplicate, and a persona whose instructions demand a capability its tool grant
does not include.

Both support `--remove`. Use it. A leftover conflicting rule changes what the agent builds
in later modules, and the failure is quiet.
