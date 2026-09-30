# Module 07 — Stage 4: Orchestration Patterns (Routed & Supervisor-Style)

**Workshop Navigation:**  
[← Previous Step: Stage 3 — The Durability Ladder](06-stage-3-the-durability-ladder.md) | **Current: Module 07 (Stage 4)** | [Next Step: Stage 5 — Hooks →](08-stage-5-hooks-from-instruction-to-enforcement.md)

---

## 🎯 Learning Goal
Name the three ways work reaches an agent — **single-agent**, **routed**, and **supervisor-style** — recognise which one you are already using, and build a supervisor that can only delegate. Learn what each pattern costs, and why the most impressive one is the one you should reach for last.

---

## 🧭 The Only Axis That Matters

Every orchestration debate collapses to one question: **who decides what happens next?**

| Pattern | Who decides | Hand-off medium | Reach for it when | What it costs you |
|---|---|---|---|---|
| **Single-agent** | You, every turn | The chat window | One concern, a short task, and you are watching it | Nothing is reusable; it all lives in one context |
| **Routed** | The `description` field | Whichever specialist the request matched | Many small requests of different kinds, each wanting a different clearance | Silent misrouting — the wrong specialist answers confidently |
| **Supervisor-style** | The supervisor agent | Subagent results, each in an isolated context | A repeating multi-stage flow where failure isolation pays for itself | Hardest to debug: *where did this rule come from?* |

You have already used the first two. Stages 0 through 2C were single-agent. The moment you
created four personas in Stage 3, you had a routed workflow — you just did not call it that.

---

## 💬 Step 1: Prove You Already Have a Routed Workflow

> [!IMPORTANT]
> **Start a new session in Copilot Chat** and leave the agent picker on the default. Do not
> `@`-mention anybody. That is the point of this step.

Send this:

```text
We need to calculate average rating and count on GET /reviews
```

→ Copilot routes to the **Developer** persona.

Now, in another new session, send this:

```text
Record why we decided against a database for this feature.
```

→ Copilot routes to the **Documenter** persona.

Two requests, no `@`-mentions, two different specialists with two different clearances.

🔍 **Where the routing actually happened:** the `description` field in each agent file. That
is your routing table. Open `developer.agent.md` and `documenter.agent.md` side by side and
read only those two lines.

### The failure mode of routed workflows

Routing is inference, and inference is wrong sometimes. Try a request that sits on a boundary:

```text
The redaction regex misses plus-addressing. Sort that out and note why.
```

**What to expect:** the agent picks one specialist — probably the Developer — and does its
half of the job. The "note why" part quietly does not happen, because the Documenter was
never invoked and the Developer has no mandate to write in `docs/`.

> [!WARNING]
> A routed workflow has no idea it routed badly. There is no "this request spans two
> specialists" warning. Work that falls between two descriptions simply does not get done,
> and the response looks complete.

**The fix for a request that spans stages is not a better description.** It is a supervisor.

---

## 🪜 Step 2: Build the Supervisor (`feature-builder.agent.md`)

A supervisor is an agent whose only capability is delegation. It cannot read a file, cannot
run a command, cannot write anything — so every stage runs in its own context with its own
clearance, and a mistake made while implementing cannot quietly edit its way into the tests
or into the record of what was decided.

### 📁 Step 1: Create the file

**Windows (PowerShell):**
```powershell
New-Item -ItemType File -Force -Path .github\agents\feature-builder.agent.md | Out-Null
```

**macOS/Linux (bash):**
```bash
touch .github/agents/feature-builder.agent.md
```

> [!TIP]
> **Shortcut — second pass only.** Read the `tools:` line before anything else — one verb, and that emptiness is the safety argument.
>
> **Windows (PowerShell):**
>
> ```powershell
> .\scripts\stages\stage4-supervisor.ps1
> ```
>
> **macOS/Linux (bash):**
>
> ```bash
> ./scripts/stages/stage4-supervisor.sh
> ```

📝 **Paste the following into `.github/agents/feature-builder.agent.md` and save:**

```markdown
---
name: feature-builder
description: "Supervisor for end-to-end feature delivery on the Reviews API. Use when a whole feature must go from ticket to reviewed change across the full flow: plan, implement, test, document, review. Delegates every step; writes nothing itself."
tools: ["agent"]
agents: ["developer", "tester", "documenter", "reviewer"]
---

# Feature Builder — Supervisor Persona

## Role & Mandate
You coordinate. You do not write code, tests, documentation or reviews — you have no tools for
any of them. Your only capability is delegation, and that is deliberate.

## Workflow
1. **Gather.** Read the ticket and any policy it links to. Restate the acceptance criteria as a
   numbered list. If any is ambiguous, stop and ask the human. Do not proceed on an assumption —
   an unresolved question here becomes a hallucination three steps later.
2. **Implement.** Delegate to `@developer` with the numbered criteria. One coherent slice at a
   time; do not hand over a whole ticket that spans unrelated concerns.
3. **Test.** Delegate to `@tester` with the same criteria plus whatever `@developer` reported changing.
4. **Document.** Delegate to `@documenter` with the diff, the test result, and any constraint that
   came from a policy rather than the ticket. Document runs before review, not after it.
5. **Review.** Delegate to `@reviewer`. If the recommendation is BLOCK, return to step 2 with the
   findings — do not argue with the reviewer and do not fix anything yourself.
6. **Report.** Summarize for the human: what changed, the test result, what was documented, the
   audit outcome, and anything you had to decide without being told.

## Operational Constraints & Boundaries
1. **Never skip the audit,** even when the change looks trivial.
2. **Never report success on the strength of a plan.** Report the actual `dotnet test` summary
   that `@tester` returned.
3. **Surface every assumption you made.** The human gate is at your report, so an assumption you
   hide is a gate that did not happen.
```

### 💬 Step 2: Run the supervisor on the boundary-spanning request

New chat session. Select **Feature Builder**, then send the request that fell through the
cracks in Step 1:

```text
The redaction regex misses plus-addressing. Sort that out and note why.
```

**What to expect:** a numbered restatement of what it thinks you asked for, then delegation to
`@developer`, `@tester` and `@documenter` in sequence, then a report. The "note why" half is no
longer optional, because a stage in the workflow owns it.

🔍 **Watch the report.** A good supervisor tells you what it decided without being told. That
list is your human gate — read it before you read the diff.

---

## ⚖️ Step 3: Count the Cost

Supervisors demo beautifully. Before adopting one, be honest about the bill:

1. **Debuggability.** GitHub Copilot merges hook and instruction configuration from up to six
   sources. Add a supervisor and the question *"where did this rule come from?"* stops having a
   quick answer.
2. **Latency and opacity.** Each delegated stage is a separate context. You see the summary, not
   the reasoning, unless you go looking.
3. **Over-application.** A supervisor invoked for a one-line fix is pure overhead.

> [!TIP]
> One genuinely useful economic note: a subagent session is part of the **same** premium
> request as the parent. Delegation is free at the request-billing level. The cost of
> orchestration is debuggability, not money.

### When to climb this rung

| You have | Use |
|---|---|
| One concern, you are watching | Single-agent |
| Many small requests of differing kinds | Routed — which you already have |
| The *same* multi-stage flow, repeatedly | Supervisor-style |

Reach for a supervisor when a multi-phase workflow has become common enough that you are
tired of sequencing it by hand. Not before, and not because the diagram looks impressive.

---

## 🧠 Key Takeaways from Stage 4

> **Key Takeaway:** *"Routing is something you already have and never named. A supervisor is something you should add last."*

- **Single-agent, routed, supervisor-style** differ on one axis: who decides what happens next.
- Your `description` fields are a routing table. Write them for the router, not for a human reader.
- Routed workflows fail silently on requests that span two specialists.
- A supervisor with `tools: ["agent"]` cannot damage anything directly — its safety argument *is*
  its emptiness.
- Sequence **document before review**, so the reviewer audits the record as well as the code.

In the next module, we add the one layer that does not ask nicely: hooks.

---

**Workshop Navigation:**  
[← Previous Step: Stage 3 — The Durability Ladder](06-stage-3-the-durability-ladder.md) | **Current: Module 07 (Stage 4)** | [Next Step: Stage 5 — Hooks →](08-stage-5-hooks-from-instruction-to-enforcement.md)
