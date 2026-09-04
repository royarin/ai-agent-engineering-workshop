# Module 08 — Wrap-Up, Takeaways & Challenge Exercises

**Workshop Navigation:**  
[← Previous Step: Stage 4 — The Full Loop Redo](07-stage-4-full-loop-redo-and-verification.md) | **Current: Module 08 (Wrap-Up)** | [Workshop Roadmap](../README.md)

---

## 🎓 Congratulations!

You have completed the **Taking Control of Your AI Coding Agent(s)** workshop.

You transformed an unguided AI assistant from an unpredictable "noise machine" into a disciplined, governed engineering collaborator operating within strict architectural, privacy, and testing boundaries.

---

## 📊 Summary Matrix: The Evolution of Control

| Stage | Control Loop Step | What Went Wrong (Unguided) | How We Fixed It (Governed) | Persistent Artifact |
|---|---|---|---|---|
| **Stage 0** | Undirected Prompt | Hallucinated SQLite / EF Core architecture, missing validation, zero tests | Discovered the failure mode of unconstrained prompts | *None (Baseline demo)* |
| **Stage 1** | Objective & AC | Scope creep & guessing business rules | Explicit Product Objectives & Acceptance Criteria (1–5 ratings) | `docs/context/product-objective.md` |
| **Stage 2A** | Context & Boundaries | **PII Leak:** Personal emails logged in plain text | Added domain context & module boundaries | `docs/context/spacerockit-domain.md`, `docs/policies/api-boundaries.md` |
| **Stage 2B** | Context by Connection | Stale / fragile clipboard copy-pasting | Connected to Issue #1 (or the issue number assigned in your repository) and its linked PII policy via MCP; uncovered idempotency | GitHub issue and PII policy wiki page |
| **Stage 2C** | Iterative Refinement | Re-prompting entire chat history on change | Dynamic MCP re-fetch; agent updated plan for 500-char comment limit | Updated workshop issue |
| **Stage 3** | The Durability Ladder | Chat rules forgotten when tab closes | Committed Repo Memory, Path Scoping, MCP Tool Limits, Personas & Skills | `.github/copilot-instructions.md`, `.github/instructions/`, `.vscode/mcp.json`, `.github/agents/`, `.github/skills/` |
| **Stage 4** | The Full Loop Redo | Micromanaged code editing | Ultra-minimal prompt (`Implement Issue #1`, or your assigned issue); implicit execution, Green Bookend | Verified PR & passing xUnit tests |

---

## 🏛️ Architecture Reference Sheet

| Mechanism | Location | Purpose & Scope | When to Use |
|---|---|---|---|
| **Repo Instructions** | `.github/copilot-instructions.md` | Global repository memory and non-negotiable boundaries | Architecture constraints, plan-first mandates, test obligations |
| **Path Instructions** | `.github/instructions/*.instructions.md` | Path-scoped rules with `applyTo` glob patterns | Specific business logic, route handlers, database modules |
| **Tool Governance** | `.vscode/mcp.json` | Physical tool permissions (read-only / domain locks) | Enterprise MCP integrations (GitHub, Jira, ADO) |
| **Custom Agents** | `.github/agents/*.agent.md` | Persona separation of concerns & write boundary enforcement | `@developer`, `@tester`, `@reviewer` roles |
| **Reusable Skills** | `.github/skills/*.skill.md` | Executable capabilities portable across 100+ repositories | PII redaction, Conventional Commits, PR scaffolding |

---

## 🚀 Self-Paced Challenge Exercises

Test your new skills by completing these three hands-on challenges:

### Challenge 1: Add Rate-Limiting Guardrails (Path-Scoped Instruction)
1. Open `.github/instructions/reviews.instructions.md`.
2. Add a new rule: *"Limit submissions to a maximum of 10 requests per minute per IP address. Return HTTP 429 Too Many Requests when exceeded."*
3. Ask Copilot: `"Update ReviewsController.cs to enforce rate limiting on POST /reviews"`.
4. Verify that Copilot implements in-memory rate limiting and adds an xUnit test without modifying forbidden folders.

---

### Challenge 2: Build a `@security-auditor` Custom Agent
1. Create `.github/agents/security-auditor.agent.md`. Run one of the following, or create it manually in VS Code:

   **Windows (PowerShell):**
   ```powershell
   New-Item -ItemType Directory -Force -Path .github\agents | Out-Null
   New-Item -ItemType File -Force -Path .github\agents\security-auditor.agent.md | Out-Null
   ```

   **macOS/Linux (bash):**
   ```bash
   mkdir -p .github/agents && touch .github/agents/security-auditor.agent.md
   ```
2. Configure it with read-only tools (`view`, `grep`, `glob`).
3. Instruct the persona to scan git diffs for:
   - Hardcoded API keys or passwords.
   - Raw SQL injection vulnerabilities.
   - Missing input sanitization.
4. Test asking `@security-auditor` to audit your repository.

---

### Challenge 3: Create a `token-redactor` Reusable Skill
1. Create `.github/skills/token-redactor.skill.md`. Run one of the following, or create it manually in VS Code:

   **Windows (PowerShell):**
   ```powershell
   New-Item -ItemType Directory -Force -Path .github\skills | Out-Null
   New-Item -ItemType File -Force -Path .github\skills\token-redactor.skill.md | Out-Null
   ```

   **macOS/Linux (bash):**
   ```bash
   mkdir -p .github/skills && touch .github/skills/token-redactor.skill.md
   ```
2. Define regex patterns to detect Bearer tokens (`Bearer [a-zA-Z0-9_\-\.]+`) and replace them with `Bearer [REDACTED_TOKEN]`.
3. Test invoking `/skill token-redactor` in Copilot Chat on sample log statements.

---

**Workshop Navigation:**  
[← Previous Step: Stage 4 — The Full Loop Redo](07-stage-4-full-loop-redo-and-verification.md) | **Current: Module 08 (Wrap-Up)** | [Workshop Roadmap](../README.md)
