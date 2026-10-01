# Stage scripts — shortcuts that write each stage's artifacts

> [!WARNING]
> **These are shortcuts, and shortcuts skip the learning.**
>
> Every file here is one a module has you write yourself, with an explanation of what each
> line is for. Running a script gets you the file. It does not get you the understanding,
> and the understanding is the point.
>
> **Write them by hand the first time.** Each script prints which module it short-cut when
> it runs, so you know what to go back and read.

## When they earn their place

- **Re-running an exercise** without retyping forty lines.
- **Catching up** if you fell behind or joined late.
- **Resetting** between attempts — `scripts/reset-all` puts you back at the beginning.
- **Presenting.** The conference session covers the same ground in 45 minutes.

## What each one does

Named for the stage and level that teaches the content, so they line up with the module you
are reading.

| Script | Writes | Taught in |
|---|---|---|
| `stage1-objective` | `docs/context/product-objective.md` | Module 02 (Stage 1), Step 1 |
| `stage2a-context` | `docs/context/spacerockit-domain.md`, `docs/policies/api-boundaries.md` | Module 03 (Stage 2A), Steps 1a–1b |
| `stage2b-mcp` | `.vscode/mcp.json` | Module 04 (Stage 2B), Step 2 |
| `stage3-level1-instructions` | `.github/copilot-instructions.md` (sections 1–4) | Module 06, Level 1, Step 1 |
| `stage3-level2-path-rules` | `.github/instructions/reviews.instructions.md` | Module 06, Level 2, Step 1 |
| `stage3-level4-agents` | The four specialist personas | Module 06, Level 4, Step 1 |
| `stage3-level4-tool-starved` | A persona its grant cannot support — **anti-pattern** | Module 06, Level 4, Step 3 |
| `stage3-level5-skills` | The four skills | Module 06, Level 5, Step 1 |
| `stage4-supervisor` | `.github/agents/feature-builder.agent.md` | Module 07 (Stage 4), Step 2 |
| `stage5-destructive-rule` | **Appends** section 5 to the global instructions | Module 08 (Stage 5), Level 0 |
| `stage5-hooks` | Both gate scripts and `guardrails.json` | Module 08 (Stage 5), Level 6 |

Two live one level up, because they undo rather than create:

| Script | What it does |
|---|---|
| `../reset-feature` | Removes the review feature and `docs/`, keeps the guardrails. Used by Stage 6 |
| `../reset-all` | Removes everything every stage creates and restores `src/`, `tests/` |

## Running them

**Windows (PowerShell):**

```powershell
.\scripts\stages\stage3-level1-instructions.ps1
```

**macOS/Linux (bash):**

```bash
./scripts/stages/stage3-level1-instructions.sh
```

The tool-starved anti-pattern script takes a switch to undo itself.

Every script overwrites rather than appends, so running one twice is harmless.
`stage5-destructive-rule` is the exception — it appends, and checks first, so a second run
reports that the section is already there and changes nothing.

## The anti-pattern script

`stage3-level4-tool-starved` writes a file that is **deliberately wrong**. It exists so you
can watch a persona whose instructions demand a capability its `tools:` line does not grant.

It undoes itself with `--remove` (`-Remove` in PowerShell). **Use it.**
