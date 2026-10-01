# Module 06 — Stage 3: The Durability Ladder

**Workshop Navigation:**  
[← Previous Step: Stage 2C — Iterative Ticket Refinement](05-stage-2c-iterative-ticket-refinement.md) | **Current: Module 06 (Stage 3)** | [Next Step: Stage 4 — Orchestration Patterns →](07-stage-4-orchestration-patterns.md)

---

## 🎯 Learning Goal

Learn why typing rules into chat prompts fails across teams and sessions, and progressively build **The Durability Ladder** (Levels 0 → 5) using committed repository instructions, path-scoped rules, tool governance, custom agent personas, and reusable skills.

```text
  ▲  Level 6: Agent Hooks (`.github/hooks/`)             → Enforcement, not advice  (Stage 5)
  │  Level 5: Reusable Skills (`.github/skills/`)        → Portable across 100+ repositories
  │  Level 4: Custom Agents (`.github/agents/`)          → Specialized personas & role refusal
  │  Level 3: Tool & MCP Governance (`.vscode/mcp.json`) → Least-privilege API permissions
  │  Level 2: Path-Scoped Instructions (`applyTo`)       → Surgical, zero-bloat file rules
  │  Level 1: Repo Instructions (`copilot-instructions`) → Permanent project-wide memory
  │  Level 0: Spoken Chat Prompt (Ephemeral & Flaky)     → Dies when chat tab closes
```

---

## 🪜 Level 0: The Ephemeral Chat Failure Mode

### 1. Test Chat Ephemerality

> [!IMPORTANT]
> **Start a new session in Copilot Chat in VS Code** (Ctrl+Shift+I or click + in Chat), select
> **Ask** mode, and send the prompt.

Send the following prompt:

```text
Plan adding persistence to our review endpoint.
```

🔍 **Observe the Failure:** The agent forgets all previous conversation context: it proposes installing Entity Framework Core with SQLite, modifies unauthorized folders, and completely forgets PII redaction rules.

---

## 🪜 Level 1: Permanent Repository Memory (`.github/copilot-instructions.md`)

Repository instructions give your project a permanent memory that every developer's Copilot automatically inherits.

### 📁 Step 1: Create `.github/copilot-instructions.md`

Create the file `.github/copilot-instructions.md` in your workspace. Run one of the following, or create it manually in VS Code:

**Windows (PowerShell):**
```powershell
New-Item -ItemType Directory -Force -Path .github | Out-Null
New-Item -ItemType File -Force -Path .github\copilot-instructions.md | Out-Null
```

**macOS/Linux (bash):**
```bash
mkdir -p .github && touch .github/copilot-instructions.md
```

📝 **Paste the following content into `.github/copilot-instructions.md` and save:**

```markdown
# Repository Instructions for SpaceRockIT

## Sources of record

- **Policies:** always consult the repository wiki for policies covering what you are implementing — PII handling, retention, and anything similar — and follow them. The GitHub MCP servers do not expose wiki pages, so fetch the wiki URL with the `web` tool instead. Cite the page you used. The wiki is the source of record even when the ticket does not link it.
- Resolve `owner` and `repo` for every MCP call from the `origin` remote of this repository, not from the folder name or from memory. Never read from any other repository, and in particular never fall back to the upstream repository this one was forked from.
- Take the issue number from the request. If that issue cannot be fetched from that repository, stop and say so. Do not substitute a similar issue from somewhere else.
- State the `owner/repo` and the issue title you actually fetched in your first reply, so a wrong repository is visible immediately rather than discovered three steps later.

## 1. Implementation Boundaries & Documentation Exception
- Implementation code and tests may ONLY be modified under `src/SpaceRockIT.Reviews.Api/` and `tests/SpaceRockIT.Reviews.Api.Tests/`.
- Documentation exception: `@documenter` may create or update files under `docs/`, including `docs/adr/`, when recording decisions or documenting a change. This exception does not permit code or test changes outside the paths above.
- Never modify solution structure, CI/CD pipelines, or authentication middleware.
- Keep all data persistence in-memory (no EF Core, SQLite, or external databases).

## 2. Planning & Execution Pattern
- Always output a concise implementation plan before making edits.
- State which files will be modified and which tests will be added.

## 3. Testing Obligation
- Every business logic modification requires at least one automated xUnit test in `tests/SpaceRockIT.Reviews.Api.Tests/`.
- Always use synthetic test fixtures (e.g. `alex.dev@enterprise.org`, never real user data).

## 4. Privacy & Data Guardrails
- Sanitize free-text user inputs for email addresses before writing to logs or public response payloads.
- Use the `/skill pii-sanitizer` skill to apply the standard redaction logic.
```

> [!IMPORTANT]
> The hosted MCP servers take `owner` and `repo` as arguments on every call — they cannot see which
> folder you have open. Nothing resolves the repository for them, so **Sources of record** makes the
> rule explicit: derive it from this repository's `origin` remote, every time.
>
> Without that rule an agent has to guess, and the guess that looks most plausible is the repository
> you forked *from* — which exists, is readable, and has its own Issue #1. The run then succeeds,
> cites a real ticket, and is simply the wrong one. That is the failure this section prevents: not an
> error message, but a confident answer about somebody else's repository.

> [!TIP]
> **Shortcut — second pass only.** Type this by hand the first time — knowing what is in it, and why each line is there, is the exercise.
>
> **Windows (PowerShell):**
>
> ```powershell
> .\scripts\stages\stage3-level1-instructions.ps1
> ```
>
> **macOS/Linux (bash):**
>
> ```bash
> ./scripts/stages/stage3-level1-instructions.sh
> ```

### 💬 Step 2: Test Repo Memory in a Blank Chat Tab

> [!IMPORTANT]
> **Start a new session in Copilot Chat in VS Code**, select **Ask** mode, and send:

```text
Plan adding persistence to our review endpoint.
```

🔍 **Observe the Difference:** The agent now explicitly states:  
*"Per repository instructions, I will keep data in-memory and only modify src/SpaceRockIT.Reviews.Api/ and tests/SpaceRockIT.Reviews.Api.Tests/. Here is my scoped plan before I make any edits."*

---

## 🪜 Level 2: Path-Scoped Surgical Instructions (`applyTo`)

Global instructions can cause "prompt bloat". Path-scoped instructions inject specialized rules **only when the agent works on matching file paths**.

> [!TIP]
> **Shortcut — second pass only.** Write it by hand first; the `applyTo` line is the whole idea.
>
> **Windows (PowerShell):**
>
> ```powershell
> .\scripts\stages\stage3-level2-path-rules.ps1
> ```
>
> **macOS/Linux (bash):**
>
> ```bash
> ./scripts/stages/stage3-level2-path-rules.sh
> ```

### 📁 Step 1: Create `.github/instructions/reviews.instructions.md`

Create the file `.github/instructions/reviews.instructions.md`. Run one of the following, or create it manually in VS Code:

**Windows (PowerShell):**
```powershell
New-Item -ItemType Directory -Force -Path .github\instructions | Out-Null
New-Item -ItemType File -Force -Path .github\instructions\reviews.instructions.md | Out-Null
```

**macOS/Linux (bash):**
```bash
mkdir -p .github/instructions && touch .github/instructions/reviews.instructions.md
```

📝 **Paste the following content into `.github/instructions/reviews.instructions.md` and save:**

```markdown
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
```

### 💬 Step 2: Test Path Scoping

1. **Out of Scope Test:** Ask Copilot: *"Refactor styling in src/SpaceRockIT.Web/wwwroot/css/site.css"*.  
   → The review rules are **not loaded**, keeping context clean.
2. **In Scope Test:** Ask Copilot: *"Update src/SpaceRockIT.Reviews.Api/Controllers/ReviewsController.cs to log incoming attendee comments"*.  
   → The agent **automatically applies email sanitization** to the logger without being asked!

You did not mention privacy in that second prompt. You mentioned a file path.

---

## 🪜 Level 3: Committed Tool & MCP Governance (`.vscode/mcp.json`)

When connecting agents to external tools, security cannot rely on conversational politeness. We enforce least-privilege tool access via configuration.

> [!TIP]
> **Shortcut — second pass only.** The same file you created in Stage 2B. If it already exists, you can skip this step entirely.
>
> **Windows (PowerShell):**
>
> ```powershell
> .\scripts\stages\stage2b-mcp.ps1
> ```
>
> **macOS/Linux (bash):**
>
> ```bash
> ./scripts/stages/stage2b-mcp.sh
> ```

### 📁 Step 1: Create `.vscode/mcp.json`

Create the file `.vscode/mcp.json`. Run one of the following, or create it manually in VS Code:

**Windows (PowerShell):**
```powershell
New-Item -ItemType Directory -Force -Path .vscode | Out-Null
New-Item -ItemType File -Force -Path .vscode\mcp.json | Out-Null
```

**macOS/Linux (bash):**
```bash
mkdir -p .vscode && touch .vscode/mcp.json
```

📝 **Paste the following content into `.vscode/mcp.json` and save:**

```json
{
  "$schema": "https://json.schemastore.org/mcp-settings.json",
  "servers": {
    "github-issues-readonly": {
      "type": "http",
      "url": "https://api.githubcopilot.com/mcp/x/issues/readonly",
      "description": "Hosted read-only access to GitHub repository issues and discussion comments."
    },
    "github-repos-readonly": {
      "type": "http",
      "url": "https://api.githubcopilot.com/mcp/x/repos/readonly",
      "description": "Hosted read-only access to repository tree, file contents, and commit history."
    }
  }
}
```

The hosted servers authenticate through the GitHub account signed in to Copilot. No personal access token belongs in this committed file. This is the same self-contained configuration first introduced in Stage 2B; here, it becomes a committed durability-ladder artifact. If VS Code prompts for authorization, complete it in the browser and verify the connection with the Stage 2B smoke test.

> [!NOTE]
> As in Stage 2B, both servers must be **started** in the MCP Servers view and **ticked in the chat
> tools picker (🛠️)** for the session you are working in. Committing `mcp.json` makes the
> configuration durable for the whole team, but enabling the tools remains a per-session action.
>
> That per-session tick is the last manual step left in the ladder, and Level 4 removes it. A
> custom agent names the MCP servers it needs in its own `tools:` list, so the grant travels with
> the agent instead of with your session. The servers must still be **started** — a grant cannot
> start a server that is not running — but you no longer re-tick anything per agent.

🔍 **Why this matters:** Even if an agent is tricked into trying to delete or close Issue #1 (or
the issue number assigned in your repository), the tool harness physically blocks the write operation.

---

## 🪜 Level 4: Specialized Custom Agents (`.github/agents/`)

A single monolithic agent should not write code, write tests, document its own decisions and
approve its own PR. We separate duties into four specialized personas, one per stage of
`implement → test → document → review`:

| Agent Persona | File | Mandate | Intended Scope (instruction, not tool-enforced) |
|---|---|---|---|
| **Developer** (`@developer`) | `developer.agent.md` | ASP.NET Core Web API (Controllers) & model implementation | `src/SpaceRockIT.Reviews.Api/**` only |
| **Tester** (`@tester`) | `tester.agent.md` | QA, boundary tests, synthetic fixtures | `tests/SpaceRockIT.Reviews.Api.Tests/**` only |
| **Documenter** (`@documenter`) | `documenter.agent.md` | Decision records and module documentation | Instructed to write only under `docs/**` — no `execute` tool |
| **Reviewer** (`@reviewer`) | `reviewer.agent.md` | Read-only security & compliance audit | **Read-only** (no `edit` or `execute` tool) |

Read down the last column before you read anything else. The prose in each file describes a
role; the `tools:` line limits which tool capabilities are available. The developer, tester,
and documenter path scopes are instructions, not filesystem enforcement: the tool grants do
not lock an agent to those folders. The reviewer is read-only in practice because it has no
editing or command-execution tool.

For portability between VS Code and GitHub Copilot, use the documented shared aliases in
`tools:`: `read`, `edit`, `search`, `execute`, `web`, and `agent`. `edit` includes file creation;
there is no shared `create` alias. `web` covers fetching a URL and web search — it is what lets an
agent read the policy wiki, which the MCP servers do not expose. The underlying tool names vary by
harness. See the
[VS Code tool reference](https://code.visualstudio.com/docs/agents/reference/tools-reference)
and [GitHub custom-agent tool aliases](https://docs.github.com/en/copilot/reference/custom-agents-configuration#tool-aliases).

> [!TIP]
> **Shortcut — second pass only.** Writes all four personas. Nine files across this level and the next is a lot of typing, but the tool grants are the whole point — read each `tools:` line before you reach for the script.
>
> **Windows (PowerShell):**
>
> ```powershell
> .\scripts\stages\stage3-level4-agents.ps1
> ```
>
> **macOS/Linux (bash):**
>
> ```bash
> ./scripts/stages/stage3-level4-agents.sh
> ```

### 📁 Step 1: Create the Four Agent Personas

Create the four empty files first. Run one of the following, or create them manually in VS Code:

**Windows (PowerShell):**
```powershell
New-Item -ItemType Directory -Force -Path .github\agents | Out-Null
New-Item -ItemType File -Force -Path .github\agents\developer.agent.md, .github\agents\tester.agent.md, .github\agents\documenter.agent.md, .github\agents\reviewer.agent.md | Out-Null
```

**macOS/Linux (bash):**
```bash
mkdir -p .github/agents && touch .github/agents/developer.agent.md .github/agents/tester.agent.md .github/agents/documenter.agent.md .github/agents/reviewer.agent.md
```

1. Create `.github/agents/developer.agent.md`:
```markdown
---
name: developer
description: "Expert backend developer for SpaceRockIT .NET APIs. Use when asked to implement features, modify route endpoints, write business logic, or refactor application code."
tools: ["read", "edit", "execute", "search", "web", "github-issues-readonly/*", "github-repos-readonly/*"]
---

# Developer Agent — Backend Implementation Persona

## Role & Mandate
You are the primary backend implementation agent for SpaceRockIT. Your responsibility is to write clean, minimal ASP.NET Core Web API controllers and domain models that strictly satisfy product acceptance criteria.

## Operational Constraints & Boundaries
1. **Intended Write Scope:** Modify files only in `src/SpaceRockIT.Reviews.Api/`. This path boundary is an instruction, not a filesystem permission.
2. **Forbidden Scope:** Never modify tests directly or introduce external database engines.
3. **Privacy:** Ensure all user comments pass through regex email redaction using `/skill pii-sanitizer`.
4. **Read the Ticket Yourself:** You have both read-only MCP servers — `github-issues-readonly` for the ticket and `github-repos-readonly` for committed repository content. Fetch the issue and implement against its acceptance criteria verbatim rather than against a summary someone pasted for you, and cite the issue URL in your report. Both grants are read-only: never create, edit, close, or comment through MCP.
```

2. Create `.github/agents/tester.agent.md`:
```markdown
---
name: tester
description: "Test automation and QA engineer for SpaceRockIT APIs. Use when asked to write unit/integration tests, discover boundary edge cases, verify test suites, or generate synthetic test data."
tools: ["read", "edit", "execute", "search", "web", "github-issues-readonly/*", "github-repos-readonly/*"]
---

# Tester Agent — Quality Assurance & Test Persona

## Role & Mandate
You are the dedicated QA and test automation agent for SpaceRockIT. Your mission is to design comprehensive xUnit test suites, identify adversarial edge cases, and run `dotnet test`.

## Operational Constraints & Boundaries
1. **Intended Write Scope:** Modify files only in `tests/SpaceRockIT.Reviews.Api.Tests/`. This path boundary is an instruction, not a filesystem permission.
2. **Forbidden Scope:** You are strictly forbidden from modifying application code under `src/SpaceRockIT.Reviews.Api/`.
3. **Synthetic Data Obligation:** Always use synthetic test fixtures (e.g. `alex.dev@enterprise.org`).
4. **Read the Ticket Yourself:** You have both read-only MCP servers — `github-issues-readonly` for the ticket and `github-repos-readonly` for committed repository content. Fetch the issue and write at least one test per acceptance criterion, citing the issue URL. Both grants are read-only: never create, edit, close, or comment through MCP.
```

3. Create `.github/agents/documenter.agent.md`:
```markdown
---
name: documenter
description: "Technical writer for the SpaceRockIT Reviews API. Use when asked to record an architectural decision, write or update an ADR, refresh documentation after a code change, or document an endpoint."
tools: ["read", "edit", "search", "web", "github-issues-readonly/*", "github-repos-readonly/*"]
---

# Documenter Agent — Decision Record Persona

## Role & Mandate
You write the record of what was decided and why. You do not change the thing itself.

## Operational Constraints & Boundaries
1. **Intended Write Scope:** Create and modify files only under `docs/`. The repository instruction's source/test boundary governs implementation code; its explicit documentation exception permits this role to write under `docs/`, including `docs/adr/`. These are complementary scopes, not conflicting rules. This path boundary is an instruction, not a filesystem permission.
2. **Forbidden Scope:** Never touch `src/` or `tests/`. If the documentation cannot be written truthfully because the code is wrong, say so and hand back to `@developer`.
3. **No Command Execution:** You have no `execute` tool, so you cannot run the test suite. Never write "all tests pass" on your own authority — record what `@tester` reported, and attribute it.
4. **Cite the Source:** Every non-obvious constraint records where it came from — the ticket, the policy page, or the instruction file. A rule with no cited origin gets deleted by the next person who finds it inconvenient.
5. **Required ADR workflow:** When a task produces a decision that should be recorded, invoke `/skill adr` before writing the record and follow its template. Create the ADR under `docs/adr/`; do not skip it because the repository's implementation boundary names only `src/` and `tests/`.
6. **Evidence:** Cite the applicable repository instruction and policy source in the ADR. Include a Verification section with the exact test result reported by `@tester`, attributed to that agent. Do not invent or omit a result; if none was provided, state that explicitly.
7. **Read the Ticket Yourself:** You have both read-only MCP servers — `github-issues-readonly` for the ticket and `github-repos-readonly` for committed repository content — so a Source line citing the ticket must come from the fetched issue, not from memory. Both grants are read-only: never create, edit, close, or comment through MCP. The MCP servers do not expose wiki pages, so consult the policy wiki by fetching its URL with the `web` tool, and cite the page you used alongside the repository instruction that encodes the same rule.
```

4. Create `.github/agents/reviewer.agent.md`:
```markdown
---
name: reviewer
description: "Read-only security, architecture, and compliance auditor. Use when asked to review git diffs, check PR readiness, audit security/PII policies, or verify repository guardrails."
tools: ["read", "search", "web", "github-issues-readonly/*", "github-repos-readonly/*"]
---

# Reviewer Agent — Security & Compliance Auditor Persona

## Role & Mandate
You are a strictly read-only compliance auditor for SpaceRockIT.

## Operational Boundaries & Explicit Denials
1. **Strictly Read-Only:** You have zero file editing permissions.
2. **Refusal to Edit Code:** If asked to "fix the issues" or "apply changes", you MUST refuse. Instruct the user to delegate code changes to `@developer` and tests to `@tester`.
3. **Read-Only MCP Grant:** `github-issues-readonly` lets you verify the change against the stated acceptance criteria; `github-repos-readonly` lets you inspect committed file contents and history, which is otherwise invisible to you because you have no `execute` tool and cannot run `git`. Both grants are read-only: never create, edit, close, or comment through MCP.
```

### 💬 Step 2: Test Intent-Based Routing & Explicit Refusal

1. **Intent-Based Routing:** Type: *"We need to calculate average rating and count on GET /reviews"*.  
   → Copilot routes the task to the **Developer Persona** (`developer.agent.md`).
2. **Explicit Review Invocation:** Type: `"@reviewer Audit the staged review changes in ReviewsController.cs"`.  
   → The Reviewer agent analyzes the diff and outputs findings.
3. **The Refusal Test:** Type: `"@reviewer Go ahead and fix those findings in ReviewsController.cs"`.  
   → 🛑 **The Reviewer explicitly refuses:**  
   *"I cannot modify code files. My role is strictly read-only compliance auditing. Please delegate implementation to @developer."*

The Reviewer does not refuse because the prose asked it to. It refuses because there is no
`edit` verb in its grant. The paragraph is belt; the missing verb is braces.

> [!IMPORTANT]
> **MCP tools are a separate namespace.** The aliases `read`, `edit`, `execute` and `search` cover
> built-in capabilities only — none of them ever implies an MCP tool. If an agent must read Issue #1,
> say so explicitly as `server-name/*` (the whole server) or `server-name/tool-name` (one tool),
> using the server name exactly as it appears in `.vscode/mcp.json`. A bare `github-issues-readonly`
> is **not** a valid entry and is silently ignored, which looks identical to an agent that simply
> chose not to use the tool.
>
> This is also why all four specialists name **both** servers for themselves rather than relying on
> the supervisor. A **named** custom agent uses its own `tools:` list, so it does not inherit the
> grants of whatever delegated to it. The supervisor keeps `tools: ["agent"]` and gathers the
> ticket by delegation — see Module 07.
>
> The same reasoning explains the `web` grant. The GitHub MCP servers expose issues and committed
> repository content, but **not wiki pages** — a wiki lives in a separate `.wiki.git` repository.
> Without `web`, an agent told to consult the PII policy has no way to reach it and will fall back
> to whatever it remembers about PII, which is exactly the failure Stage 2A demonstrated.

### 🚨 Step 3: The Anti-Pattern — A Persona That Starves Its Own Skill

A tool grant that does not cover what the persona's instructions demand does not produce a
smaller agent. It produces an agent whose work silently does not happen.

> [!TIP]
> **Shortcut — second pass only.** Write it by hand first — spotting the mismatch between the instructions and the `tools:` line before you run it is half the lesson. The script undoes itself with `--remove` / `-Remove`.
>
> **Windows (PowerShell):**
>
> ```powershell
> .\scripts\stages\stage3-level4-tool-starved.ps1
> ```
>
> **macOS/Linux (bash):**
>
> ```bash
> ./scripts/stages/stage3-level4-tool-starved.sh
> ```

Create a deliberately broken persona:

**Windows (PowerShell):**
```powershell
New-Item -ItemType File -Force -Path .github\agents\auditor-lite.agent.md | Out-Null
```

**macOS/Linux (bash):**
```bash
touch .github/agents/auditor-lite.agent.md
```

📝 **Paste the following and save:**

```markdown
---
name: auditor-lite
description: "Lightweight privacy auditor. Use for quick checks that attendee free text is redacted before it reaches logs, storage, or responses."
tools: ["read", "search"]
---

# Auditor (Lite)

You are a fast, focused privacy auditor for the SpaceRockIT Reviews API.

## What you do
1. Locate every path where attendee free text is logged, stored, or serialized into a response.
2. Confirm each one passes through the redaction helper first.
3. **Run the verification step described in the `pii-sanitizer` skill** and report the actual result.
4. Report PASS or FAIL per path, with the evidence that led you there.

## Constraints
- Read-only. Never edit a file.
- Never report PASS on the strength of reading the code. A path is verified when the verification step has run and produced output.
```

Select **Auditor (Lite)** in the chat agent picker, then ask:

```text
Verify that attendee comments are redacted before they reach the logs. Run the verification step described in the pii-sanitizer skill and report the result.
```

**What to expect:** a confident, well-structured PASS report. Step 3 of its own instructions
cannot have run — verifying requires executing something, and this grant has no `execute` tool.
The agent does not say so. There is no error and no "I could not run that."

> [!WARNING]
> Instructions that demand a capability the grant does not include fail **silently**. The
> fix is not better prose. It is either adding `execute` to the grant, or an honest
> description saying this agent reads and does not verify.

**Delete the broken persona before continuing:**

**Windows (PowerShell):**
```powershell
Remove-Item -Force .github\agents\auditor-lite.agent.md
```

**macOS/Linux (bash):**
```bash
rm -f .github/agents/auditor-lite.agent.md
```

---

## 🪜 Level 5: Reusable Portable Skills (`.github/skills/`)

While instructions define *what* rules to follow, **Skills** encapsulate *how* to execute standard engineering capabilities across 100+ repositories.

> [!TIP]
> **Shortcut — second pass only.** Writes all four. Read the `description` field of each one first — that is what makes a skill discoverable, and it is the part people get wrong.
>
> **Windows (PowerShell):**
>
> ```powershell
> .\scripts\stages\stage3-level5-skills.ps1
> ```
>
> **macOS/Linux (bash):**
>
> ```bash
> ./scripts/stages/stage3-level5-skills.sh
> ```

### 📁 Step 1: Create the Four Skills

Create the four empty files first. Run one of the following, or create them manually in VS Code:

**Windows (PowerShell):**
```powershell
New-Item -ItemType Directory -Force -Path .github\skills\pii-sanitizer, .github\skills\git-commit, .github\skills\git-pr-summary, .github\skills\adr | Out-Null
New-Item -ItemType File -Force -Path .github\skills\pii-sanitizer\SKILL.md, .github\skills\git-commit\SKILL.md, .github\skills\git-pr-summary\SKILL.md, .github\skills\adr\SKILL.md | Out-Null
```

**macOS/Linux (bash):**
```bash
mkdir -p .github/skills/{pii-sanitizer,git-commit,git-pr-summary,adr}
touch .github/skills/pii-sanitizer/SKILL.md .github/skills/git-commit/SKILL.md .github/skills/git-pr-summary/SKILL.md .github/skills/adr/SKILL.md
```

1. Create `.github/skills/pii-sanitizer/SKILL.md`:
```markdown
---
name: pii-sanitizer
description: "Applies standard GDPR/PII email redaction patterns and sanitization algorithms to free-text user inputs, logging statements, and DTOs."
---

# Skill: PII Sanitizer (`pii-sanitizer`)

## Capabilities & Implementation Logic
- **Regex Standard:** Employs RFC 5322 regex: `[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}`.
- **Masking Strategy:** Replaces all email matches with `[redacted-email]`.
- **Implementation:** Injects C# sanitization filter: `Regex.Replace(input, pattern, "[redacted-email]")`.
```

2. Create `.github/skills/git-commit/SKILL.md`:
```markdown
---
name: git-commit
description: "Inspects staged git changes and generates standardized Conventional Commit messages (feat, fix, test, docs, refactor, chore) with 72-character limits."
---

# Skill: Git Commit Message Generator (`git-commit`)

## Capabilities
Inspects staged diffs and formats standard Conventional Commits (`feat(module): ...`, `test(module): ...`).
```

3. Create `.github/skills/git-pr-summary/SKILL.md`:
```markdown
---
name: git-pr-summary
description: "Inspects branch diffs against base branch to generate structured Pull Request descriptions with change summaries, issue linkages, and verification checklists."
---

# Skill: Pull Request Summary Generator (`git-pr-summary`)

## Capabilities
Analyzes full branch diffs against `main`, extracts issue linkages (`Closes #1`, or the issue
number assigned in your repository), and formats auditor-ready PR descriptions with verification checklists.
```

---

4. Create `.github/skills/adr/SKILL.md`:
````markdown
---
name: adr
description: "Writes an Architecture Decision Record into docs/adr/ using the project's standard format. Use when a decision needs recording, when the user mentions an ADR or a decision record, or after a change that locks in a constraint future contributors must not casually undo."
---

# Skill: Architecture Decision Record (`adr`)

## When a decision is worth a record
Write one when the decision constrains future work and the reason is not obvious from the code: a technology deliberately rejected, a boundary deliberately drawn, a regulatory obligation, a trade-off with a real cost. Do **not** write one for a naming choice or a refactor.

## Steps
1. Find the highest existing number in `docs/adr/`. Yours is the next one, zero-padded to four digits.
2. Name the file `NNNN-kebab-case-title.md`. The title states the decision, not the topic: `0002-redact-email-before-logging`, not `0002-logging`.
3. Fill every section of the template. No placeholders left behind.
4. Cite the origin of the constraint — ticket, policy page, or instruction file. For repository boundaries, cite the relevant section of `.github/copilot-instructions.md`; cite the linked PII policy page when it drives the decision.
5. Include the exact test result supplied by `@tester` in the Verification section and attribute it to that agent. If the supervisor did not supply a result, state that no test result was provided; never invent one.

## Template

```markdown
# NNNN. <the decision, as a statement>

- **Status:** Accepted
- **Date:** <YYYY-MM-DD>
- **Source:** <ticket, policy page, or instruction file that drove this>

## Context
What was true that forced a decision, including the constraint that makes the obvious alternative wrong.

## Decision
What we do now, in the present tense. One paragraph.

## Consequences
What this makes easy, what it makes hard, and what a future contributor must not do without revisiting this record.

## Verification
Record the exact test summary reported by `@tester`, attributed to that agent. If no test result was provided, say so.

## Alternatives considered
Each rejected option and the specific reason it was rejected. "It was worse" is not a reason.
```

## Constraints
- **Always:** one decision per record, and an honest Consequences section including the annoying ones.
- **Never:** claim a verification you did not perform. Attribute test results to whoever ran them.
- **Never:** edit an accepted ADR to change its decision. Supersede it with a new record and mark the old one `Superseded by NNNN`.
````

### 💬 Step 2: Invoke a Skill

A skill is a reusable procedure the agent can apply to a task; it is not another agent or a
tool permission. Invoke one directly to make its contribution visible:

```text
/skill pii-sanitizer
Sanitize this comment and show the C# transformation you would use. Do not edit any files:
"Great talk — reach me at alex.dev@enterprise.org"
```

**Expected:** the email is replaced with `[redacted-email]`, and the response identifies the
regex/replacement pattern from `pii-sanitizer/SKILL.md`. Compare that result with the skill
file: the file stores the repeatable method, and invoking the skill applies it to the current
input. Skills can also be selected by relevance through their `description`; for a dependable
demo, invoke this one explicitly.

The skill does not itself enforce that every code path uses the helper. The instruction file
and tests provide the project rule and verification; the skill supplies the reusable
implementation recipe.

---

## 🧠 Key Takeaways from Stage 3

> **Key Takeaway:** *"Don't rely on prompt memory. Institutionalize control: Repo instructions for project memory, path-scoped rules for precision, MCP limits for safety, custom agents for review, and skills for organizational portability."*

Now that our full Durability Ladder is committed, we are ready to execute the **Full Loop Redo** in Module 07!

> [!IMPORTANT]
> **Stage 4 begins with a required reset.** In **Step 0** of Module 07 you will delete the review
> implementation and tests from Stages 1–2C and remove the `docs/` folder, keeping only the
> `.github/` and `.vscode/` artifacts you just built. That is deliberate: Stage 4 proves your durable
> context can rebuild the feature on its own, which is only meaningful once the manual context and
> the old code are gone. Complete Step 0 before sending any prompt — and do not discard your
> `.github/` and `.vscode/` work in the meantime.

---

**Workshop Navigation:**  
[← Previous Step: Stage 2C — Iterative Ticket Refinement](05-stage-2c-iterative-ticket-refinement.md) | **Current: Module 06 (Stage 3)** | [Next Step: Stage 4 — Orchestration Patterns →](07-stage-4-orchestration-patterns.md)
