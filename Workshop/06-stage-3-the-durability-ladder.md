# Module 06 — Stage 3: The Durability Ladder

**Workshop Navigation:**  
[← Previous Step: Stage 2C — Iterative Ticket Refinement](05-stage-2c-iterative-ticket-refinement.md) | **Current: Module 06 (Stage 3)** | [Next Step: Stage 4 — The Full Loop Redo →](07-stage-4-full-loop-redo-and-verification.md)

---

## 🎯 Learning Goal
Learn why typing rules into chat prompts fails across teams and sessions, and progressively build **The Durability Ladder** (Levels 0 → 5) using committed repository instructions, path-scoped rules, tool governance, custom agent personas, and reusable skills.

```text
  ▲  Level 5: Reusable Skills (`.github/skills/`)        → Portable across 100+ repositories
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

## 1. Architectural Boundaries & Permitted Modules
- You may ONLY modify files under `src/SpaceRockIT.Reviews.Api/` and `tests/SpaceRockIT.Reviews.Api.Tests/`.
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
1. **Out of Scope Test:** Ask Copilot: *"Refactor styling in src/SpaceRockIT.Web/wwwroot/site.css"*.  
   → The review rules are **not loaded**, keeping context clean.
2. **In Scope Test:** Ask Copilot: *"Update src/SpaceRockIT.Reviews.Api/Controllers/ReviewsController.cs to log incoming attendee comments"*.  
   → The agent **automatically applies email sanitization** to the logger without being asked!

---

## 🪜 Level 3: Committed Tool & MCP Governance (`.vscode/mcp.json`)

When connecting agents to external tools, security cannot rely on conversational politeness. We enforce least-privilege tool access via configuration.

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

🔍 **Why this matters:** Even if an agent is tricked into trying to delete or close Issue #1 (or
the issue number assigned in your repository), the tool harness physically blocks the write operation.

---

## 🪜 Level 4: Specialized Custom Agents (`.github/agents/`)

A single monolithic agent should not write code, write tests, and approve its own PR. We separate duties into three specialized personas:

| Agent Persona | File | Mandate | Permitted Scope |
|---|---|---|---|
| **Developer** (`@developer`) | `developer.agent.md` | ASP.NET Core Web API (Controllers) & model implementation | `src/SpaceRockIT.Reviews.Api/**` only |
| **Tester** (`@tester`) | `tester.agent.md` | QA, boundary tests, synthetic fixtures | `tests/SpaceRockIT.Reviews.Api.Tests/**` only |
| **Reviewer** (`@reviewer`) | `reviewer.agent.md` | Read-only security & compliance audit | **Read-Only** (Zero write permissions) |

### 📁 Step 1: Create the Three Agent Personas

Create the three empty files first. Run one of the following, or create them manually in VS Code:

**Windows (PowerShell):**
```powershell
New-Item -ItemType Directory -Force -Path .github\agents | Out-Null
New-Item -ItemType File -Force -Path .github\agents\developer.agent.md, .github\agents\tester.agent.md, .github\agents\reviewer.agent.md | Out-Null
```

**macOS/Linux (bash):**
```bash
mkdir -p .github/agents && touch .github/agents/developer.agent.md .github/agents/tester.agent.md .github/agents/reviewer.agent.md
```

1. Create `.github/agents/developer.agent.md`:
```markdown
---
name: developer
description: "Expert backend developer for SpaceRockIT .NET APIs. Use when asked to implement features, modify route endpoints, write business logic, or refactor application code."
tools: ["view", "edit", "create", "powershell", "grep", "glob"]
---

# Developer Agent — Backend Implementation Persona

## Role & Mandate
You are the primary backend implementation agent for SpaceRockIT. Your responsibility is to write clean, minimal ASP.NET Core Web API controllers and domain models that strictly satisfy product acceptance criteria.

## Operational Constraints & Boundaries
1. **Permitted Write Scope:** You may only modify files in `src/SpaceRockIT.Reviews.Api/`.
2. **Forbidden Scope:** Never modify tests directly or introduce external database engines.
3. **Privacy:** Ensure all user comments pass through regex email redaction using `/skill pii-sanitizer`.
```

2. Create `.github/agents/tester.agent.md`:
```markdown
---
name: tester
description: "Test automation and QA engineer for SpaceRockIT APIs. Use when asked to write unit/integration tests, discover boundary edge cases, verify test suites, or generate synthetic test data."
tools: ["view", "edit", "create", "powershell", "grep", "glob"]
---

# Tester Agent — Quality Assurance & Test Persona

## Role & Mandate
You are the dedicated QA and test automation agent for SpaceRockIT. Your mission is to design comprehensive xUnit test suites, identify adversarial edge cases, and run `dotnet test`.

## Operational Constraints & Boundaries
1. **Permitted Write Scope:** You may only modify files in `tests/SpaceRockIT.Reviews.Api.Tests/`.
2. **Forbidden Scope:** You are strictly forbidden from modifying application code under `src/SpaceRockIT.Reviews.Api/`.
3. **Synthetic Data Obligation:** Always use synthetic test fixtures (e.g. `alex.dev@enterprise.org`).
```

3. Create `.github/agents/reviewer.agent.md`:
```markdown
---
name: reviewer
description: "Read-only security, architecture, and compliance auditor. Use when asked to review git diffs, check PR readiness, audit security/PII policies, or verify repository guardrails."
tools: ["view", "grep", "glob"]
---

# Reviewer Agent — Security & Compliance Auditor Persona

## Role & Mandate
You are a strictly read-only compliance auditor for SpaceRockIT.

## Operational Boundaries & Explicit Denials
1. **Strictly Read-Only:** You have zero file editing permissions.
2. **Refusal to Edit Code:** If asked to "fix the issues" or "apply changes", you MUST refuse. Instruct the user to delegate code changes to `@developer` and tests to `@tester`.
```

### 💬 Step 2: Test Intent-Based Routing & Explicit Refusal
1. **Intent-Based Routing:** Type: *"We need to calculate average rating and count on GET /reviews"*.  
   → Copilot routes the task to the **Developer Persona** (`developer.agent.md`).
2. **Explicit Review Invocation:** Type: `"@reviewer Audit the staged review changes in ReviewsController.cs"`.  
   → The Reviewer agent analyzes the diff and outputs findings.
3. **The Refusal Test:** Type: `"@reviewer Go ahead and fix those findings in ReviewsController.cs"`.  
   → 🛑 **The Reviewer explicitly refuses:**  
   *"I cannot modify code files. My role is strictly read-only compliance auditing. Please delegate implementation to @developer."*

---

## 🪜 Level 5: Reusable Portable Skills (`.github/skills/`)

While instructions define *what* rules to follow, **Skills** encapsulate *how* to execute standard engineering capabilities across 100+ repositories.

### 📁 Step 1: Create the Three Skills

Create the three empty files first. Run one of the following, or create them manually in VS Code:

**Windows (PowerShell):**
```powershell
New-Item -ItemType Directory -Force -Path .github\skills | Out-Null
New-Item -ItemType File -Force -Path .github\skills\pii-sanitizer.skill.md, .github\skills\git-commit.skill.md, .github\skills\git-pr-summary.skill.md | Out-Null
```

**macOS/Linux (bash):**
```bash
mkdir -p .github/skills && touch .github/skills/pii-sanitizer.skill.md .github/skills/git-commit.skill.md .github/skills/git-pr-summary.skill.md
```

1. Create `.github/skills/pii-sanitizer.skill.md`:
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

2. Create `.github/skills/git-commit.skill.md`:
```markdown
---
name: git-commit
description: "Inspects staged git changes and generates standardized Conventional Commit messages (feat, fix, test, docs, refactor, chore) with 72-character limits."
---

# Skill: Git Commit Message Generator (`git-commit`)

## Capabilities
Inspects staged diffs and formats standard Conventional Commits (`feat(module): ...`, `test(module): ...`).
```

3. Create `.github/skills/git-pr-summary.skill.md`:
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
[← Previous Step: Stage 2C — Iterative Ticket Refinement](05-stage-2c-iterative-ticket-refinement.md) | **Current: Module 06 (Stage 3)** | [Next Step: Stage 4 — The Full Loop Redo →](07-stage-4-full-loop-redo-and-verification.md)
