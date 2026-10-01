# Module 08 — Stage 5: Hooks — From Instruction to Enforcement

**Workshop Navigation:**  
[← Previous Step: Stage 4 — Orchestration Patterns](07-stage-4-orchestration-patterns.md) | **Current: Module 08 (Stage 5)** | [Next Step: Stage 6 — The Full Loop Redo →](09-stage-6-full-loop-redo-and-verification.md)

---

## 🎯 Learning Goal
Discover that every rung of the ladder so far is **advisory**, then add the one that is not. Build a `preToolUse` gate that blocks a destructive command before it runs, and an `agentStop` gate that refuses to let the agent finish while the test suite is red.

> [!IMPORTANT]
> Hooks are a fast-moving surface and IDE support is **preview**. Check the official hooks
> reference before you rely on edge-case behaviour, and expect field names to shift.

---

## 🚨 Level 0 of this stage: Prose Is Advisory

Your `copilot-instructions.md` has carried a boundary since Stage 3. Let's find out what it
is actually worth.

First, add an explicit prohibition — the strongest wording you can reasonably write. Append
this section to `.github/copilot-instructions.md`:

```markdown
## 5. Destructive operations

- Never run a destructive or irreversible shell command. This includes `rm -rf`,
  `git clean -fd`, `git push --force`, dropping tables, and piping a download into a shell.
- If a task appears to need one, stop and explain what you would run and why. The human decides.
- Prefer a reversible alternative when one exists.
```

> [!IMPORTANT]
> **New chat session**, **Agent** mode.

```text
Clean all untracked files out of the working tree so we start from a clean slate.
```

**What to expect:** one of two things, and both make the point.

- The agent reaches for `git clean -fd`, or proposes it and asks to run it. The rule you just
  wrote lost to a plausible-sounding request.
- The agent refuses and cites your rule. Good — **today**. You have no way to prove it will
  hold on the next model version, under a different phrasing, or three turns into a long
  session where the instruction has been summarised out of the context window.

> [!WARNING]
> That second outcome is more dangerous than the first, because it feels like a guarantee.
> A rule you cannot test is not a control. It is a preference that has not yet been
> contradicted.

---

> [!TIP]
> **Shortcut — second pass only.** Write them by hand first; a gate you did not read is a
> gate you cannot trust, which is rather the theme of this stage.
>
> **Windows (PowerShell):**
>
> ```powershell
> .\scripts\stages\stage5-hooks.ps1
> ```
>
> **macOS/Linux (bash):**
>
> ```bash
> ./scripts/stages/stage5-hooks.sh
> ```

---

## 🪜 Level 6: Hooks (`.github/hooks/`)

Custom instructions are text the agent may choose to follow. **Hooks are shell commands wired
into the agent's lifecycle**: when the condition is met, the script runs. No interpretation,
no forgetting.

It is the shift from *"please don't do that"* to *"you cannot do that"*.

| Property | What it means here |
|---|---|
| **Deterministic** | Fires every time the condition is met |
| **Synchronous** | Blocks the agent while it runs — keep it fast |
| **Shared** | One config, committed, applies to everyone who clones |
| **Versioned** | Reviewed in a pull request; rolled back with `git revert` |

### 📁 Step 1: Create the hook configuration

**Windows (PowerShell):**
```powershell
New-Item -ItemType Directory -Force -Path .github\hooks\scripts | Out-Null
New-Item -ItemType File -Force -Path .github\hooks\guardrails.json | Out-Null
```

**macOS/Linux (bash):**
```bash
mkdir -p .github/hooks/scripts && touch .github/hooks/guardrails.json
```

> [!TIP]
> **Shortcut — second pass only.** Writes the config and both gate scripts together.
>
> **Windows (PowerShell):**
>
> ```powershell
> .\scripts\stages\stage5-hooks.ps1
> ```
>
> **macOS/Linux (bash):**
>
> ```bash
> ./scripts/stages/stage5-hooks.sh
> ```

📝 **Paste the following into `.github/hooks/guardrails.json` and save:**

```json
{
  "version": 1,
  "hooks": {
    "preToolUse": [
      {
        "type": "command",
        "bash": "./.github/hooks/scripts/block-dangerous-commands.sh",
        "powershell": "pwsh -NoProfile -File ./.github/hooks/scripts/block-dangerous-commands.ps1",
        "timeoutSec": 5
      }
    ],
    "agentStop": [
      {
        "type": "command",
        "bash": "dotnet test --nologo --filter FullyQualifiedName~SpaceRockIT.Reviews.Api.Tests",
        "powershell": "dotnet test --nologo --filter FullyQualifiedName~SpaceRockIT.Reviews.Api.Tests",
        "timeoutSec": 120
      }
    ]
  }
}
```

### 📁 Step 2: Create the `preToolUse` gate script

`preToolUse` runs **before** any tool call. It reads the proposed call on stdin and answers
`allow`, `deny` or `ask`. This is the central control mechanism.

📝 **Create `.github/hooks/scripts/block-dangerous-commands.sh`:**

```bash
#!/usr/bin/env bash
# preToolUse gate. Reads the tool call on stdin, denies the ones we never want run.
#
# Contract: print nothing and exit 0 to allow. Print a permissionDecision to deny.
# Keep this under 5 seconds — see the warning about timeouts below.

set -uo pipefail

INPUT=$(cat)
CMD=$(printf '%s' "$INPUT" | jq -r '.toolArgs.command // empty' 2>/dev/null || true)

[ -z "$CMD" ] && exit 0

DENY_PATTERN='rm[[:space:]]+-rf|git[[:space:]]+push[[:space:]]+--force|git[[:space:]]+clean[[:space:]]+-fd([[:space:]]|$)|DROP[[:space:]]+TABLE|curl[^|]*\|[[:space:]]*(ba)?sh'

if printf '%s' "$CMD" | grep -qiE "$DENY_PATTERN"; then
  printf '%s' '{"permissionDecision":"deny","permissionDecisionReason":"Blocked by repository policy: destructive or unreviewed-execution command."}'
  exit 0
fi

exit 0
```

📝 **And `.github/hooks/scripts/block-dangerous-commands.ps1`:**

```powershell
# preToolUse gate (PowerShell). See the .sh file for the contract.
$ErrorActionPreference = 'Stop'

$raw = [Console]::In.ReadToEnd()
if ([string]::IsNullOrWhiteSpace($raw)) { exit 0 }
try { $payload = $raw | ConvertFrom-Json } catch { exit 0 }

$cmd = $payload.toolArgs.command
if ([string]::IsNullOrWhiteSpace($cmd)) { exit 0 }

$deny = 'rm\s+-rf|git\s+push\s+--force|git\s+clean\s+-fd(\s|$)|DROP\s+TABLE|curl[^|]*\|\s*(ba)?sh|Remove-Item\s+.*-Recurse.*-Force'

if ($cmd -imatch $deny) {
    Write-Output '{"permissionDecision":"deny","permissionDecisionReason":"Blocked by repository policy: destructive or unreviewed-execution command."}'
}
exit 0
```

On macOS and Linux, make the script executable:

```bash
chmod +x .github/hooks/scripts/block-dangerous-commands.sh
```

### 💬 Step 3: Prove the gate fires

Start a **new chat session** — hooks are read when a session begins, so a config you wrote
mid-session is not yet in force. Then, in Agent mode:

```text
Run this command: echo 'DROP TABLE demo'
```

🔍 **Expected output — before the command executes:**

```json
{"permissionDecision":"deny","permissionDecisionReason":"Blocked by repository policy: destructive or unreviewed-execution command."}
```

That command is completely harmless — it prints a string and touches nothing. **That is
precisely why it is the right test.** It matches `DROP TABLE` in the deny pattern, so the gate
has to fire, and the result does not depend on the model deciding to do something dangerous.

> [!IMPORTANT]
> **Why not re-run the Level 0 prompt here?** Because *"clean all untracked files"* only
> reaches the gate if the model actually calls the shell. If it follows your instruction and
> declines, no tool call is made, nothing is intercepted, and you have learned nothing about
> the hook. `preToolUse` fires **before a tool executes** — not when the model considers an
> action and thinks better of it. A test whose outcome depends on the model's choice cannot
> tell you whether your gate works.

> [!WARNING]
> **If the command prints `DROP TABLE demo` instead of being denied, the gate is not loaded.**
> Check, in this order:
> - Did you start a new session *after* writing the files?
> - Is this folder trusted? Repository hook config under `.github/hooks/` is trusted
>   configuration; in an untrusted folder it is not loaded at all. Use `/add-dir`.
> - Run `/env`, which lists the hooks actually in force. If `preToolUse` is not in that list,
>   nothing you do in chat will trigger it.
>
> A hook that silently fails to load looks exactly like a well-behaved agent. Verify, don't assume.

The difference from Level 0 is not that the agent behaved better. It is that the agent's
behaviour stopped being the deciding factor.

> [!NOTE]
> This gate is also why a bare `git clean -fd` is now survivable in this repository. Do not
> rely on that during Stage 4 — scope your cleans anyway. A preview-stage guardrail is a
> second line of defence, not a first.

---

## 🧪 Step 4: The `agentStop` Quality Gate

`preToolUse` stops bad things happening. `agentStop` stops the agent *finishing* while
something is wrong — it fires when the agent tries to end its turn and can send it back.

### 1. Break a test on purpose

In `tests/SpaceRockIT.Reviews.Api.Tests/ApiTests.cs`, change the expectation in
`Health_responds`:

```csharp
// from
Assert.Equal(HttpStatusCode.OK, response.StatusCode);

// to
Assert.Equal(HttpStatusCode.Accepted, response.StatusCode);
```

Confirm the suite is red:

```text
./scripts/verify.sh
```

### 2. Tell the agent it is done

```text
That's everything for this task — you can stop here.
```

**What to expect:** the `agentStop` hook runs the filtered test command, the suite fails, and
the agent is sent back for another turn instead of ending cleanly.

> **The line that matters:** the agent does not get to decide it is finished. The test runner
> decides.

### 3. Undo the break

```text
git checkout -- tests/SpaceRockIT.Reviews.Api.Tests/ApiTests.cs
```

Then confirm you are green again before moving on.

---

## 🐉 Step 5: The Dragon in the Detail

Read this twice. It is the part people get wrong.

> [!WARNING]
> **`preToolUse` fails *closed* on error and *open* on timeout.**
>
> A script that errors denies the call — safe. A script that runs slow and times out
> **allows** it. A gate that gets slow quietly stops being a gate, and nothing tells you.

Practical consequences:

1. **Keep hooks under five seconds.** That is why the gate script above does almost nothing:
   read stdin, one regex, exit.
2. **Never put a network call in a `preToolUse` hook.** The one time the network is slow is
   the one time the gate is open.
3. **Log, do not compute.** Append to a file; analyse later.
4. **Treat hook scripts as production code.** They run with the agent's permissions. Review
   them, test them by piping sample JSON in, and never log secrets.

Other limits worth knowing:

- Multiple hooks can run for one event; **the most restrictive decision wins**. One `deny`
  blocks the call even if others approve.
- Configuration merges from several sources — repository, user, policy, plugins. When a rule
  surprises you, *where it came from* is a real question.
- `agentStop` can force another turn by returning `{"decision":"block","reason":"…"}`, but the
  CLI stops overriding after a number of consecutive blocks so a broken gate cannot trap you
  in a loop forever.

---

## 🧠 Key Takeaways from Stage 5

> **Key Takeaway:** *"Hooks turn guidelines into guarantees. Everything below this rung is advice."*

- Levels 1 to 5 are **non-deterministic** guardrails: the agent may comply. Hooks are
  **deterministic**: the agent has no say.
- Start with `preToolUse` security gating — highest value, lowest effort.
- `agentStop` is where a quality bar becomes enforceable: green tests or no finish.
- Build **both walls**. Instructions tell the agent what good looks like; hooks make the
  worst outcomes impossible. Neither replaces the other.
- A slow hook is an open hook. Under five seconds, always.
- A hook that never loaded looks exactly like a well-behaved agent. Test every gate with a
  harmless command that *must* trip it, and confirm with `/env` — never infer from good behaviour.

---

**Workshop Navigation:**  
[← Previous Step: Stage 4 — Orchestration Patterns](07-stage-4-orchestration-patterns.md) | **Current: Module 08 (Stage 5)** | [Next Step: Stage 6 — The Full Loop Redo →](09-stage-6-full-loop-redo-and-verification.md)
