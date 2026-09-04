# Module 01 — Stage 0: The Undirected Prompt (The Noise Machine)

**Workshop Navigation:**  
[← Previous Step: Module 00 — Setup](00-introduction-and-setup.md) | **Current: Module 01 (Stage 0)** | [Next Step: Stage 1 — Objective & AC →](02-stage-1-objective-and-acceptance-criteria.md)

---

## 🎯 Learning Goal
Understand why unguided, conversational prompts cause AI agents to hallucinate unwanted architecture, miss critical validation rules, and skip automated testing.

---

## 💬 Step 1: Send the Natural Developer Prompt

> [!IMPORTANT]
> **Start a new session in Copilot Chat in VS Code** with no previous chat history and select
> **Ask** mode.

Currently, our backend only has `GET /health` and lacks any review collection endpoint. Let's see what happens when a developer prompts Copilot with a realistic, broad feature request:

Copy the following natural prompt and send it to Copilot:

```text
Add a review endpoint to our festival API so attendees can rate workshop sessions.
```

**What to expect:** Copilot should propose a plausible implementation plan. Record whether it
suggests extra persistence, omits rating boundaries or privacy, and includes tests; do not accept
or apply the changes for this observation-only step.

---

## 🔍 Step 2: Inspect the Agent's Proposed Solution

Carefully examine the plan and code that Copilot returns. Notice what the model decides to generate on its own:

1. **Unwanted Architectural Complexity:**
   - The agent typically proposes installing **Entity Framework Core**, configuring **SQLite** or **PostgreSQL**, creating database migration files, and introducing complex repository patterns.
   - *Why this is a problem:* For a lightweight, in-memory festival prototype, adding external database packages adds unnecessary dependencies and maintenance overhead that nobody requested.

2. **Missing Business Boundaries:**
   - Look at the `rating` field. The agent usually defines it as a generic `int` without checking if it falls between `1` and `5`. Submitting `rating: -100` or `rating: 999` would succeed.

3. **Ignored Privacy & GDPR Concerns:**
   - Free-text `comment` fields are accepted directly and logged or stored without sanitization.

4. **Missing Automated Tests:**
   - The agent often writes only implementation code and provides no xUnit tests to verify its logic.

---

## 🧠 Key Takeaways from Stage 0

> **Key Takeaway:** *"The model isn't the problem — the objective was unconstrained."*

When you provide a vague prompt, LLMs act as **noise machines**: they generate plausible-sounding generic software patterns (like EF Core and SQLite) rather than the precise, lightweight solution your project requires.

In the next module, we will fix this by introducing a formal **Product Objective and Acceptance Criteria**.

---

**Workshop Navigation:**  
[← Previous Step: Module 00 — Setup](00-introduction-and-setup.md) | **Current: Module 01 (Stage 0)** | [Next Step: Stage 1 — Objective & AC →](02-stage-1-objective-and-acceptance-criteria.md)
