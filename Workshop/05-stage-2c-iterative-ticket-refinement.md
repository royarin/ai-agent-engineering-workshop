# Module 05 — Stage 2C: Iterative Ticket Refinement

**Workshop Navigation:**  
[← Previous Step: Stage 2B — MCP Connected Context](04-stage-2b-mcp-connected-context.md) | **Current: Module 05 (Stage 2C)** | [Next Step: Stage 3 — The Durability Ladder →](06-stage-3-the-durability-ladder.md)

---

## 🎯 Learning Goal
Learn how context is iterative and bi-directional. When product owners or engineering teams update requirements in the system of record, a connected agent adapts its plan immediately without needing a full prompt rewrite.

---

## 📝 Step 1: Perform a Live Ticket Refinement

In real-world projects, requirements evolve during sprint execution. Imagine your product team just finished refinement and added an anti-spam constraint: comments must not exceed 500 characters and cannot be empty whitespace.

Open Issue #1 in the GitHub web UI. If your repository assigned a different number, use that
number instead. A facilitator or repository collaborator with issue write access performs this
authoring step in the UI; the read-only MCP connection must not create or comment on issues.

Add this comment and submit it:

```markdown
> *"Constraint added during refinement: Limit comments to a maximum of 500 characters. Reject comment submissions that are whitespace-only or exceed 500 characters with HTTP 400 Bad Request."*
```

---

## 💬 Step 2: Prompt Copilot for the Requirements Delta

Instead of repeating all previous instructions, ask Copilot to re-inspect the issue and report only what changed.

> [!IMPORTANT]
> **Start a new session in Copilot Chat in VS Code**, select **Ask** mode, **re-enable both
> `github-issues-readonly` and `github-repos-readonly` in the tools picker (🛠️)** — tool selections
> reset with every new session — and send the following prompt:

```text
The team just refined Issue #1 in GitHub. If your repository assigned a different number, use
that number instead.
Re-fetch the issue and its comments through MCP. State only the delta in requirements and the new test cases required, citing the new comment.
```

**What to expect:** The response should cite the newly added comment, identify only the 500
character and whitespace constraints, and propose matching tests without losing earlier rules.

---

## 🔍 Step 3: Observe the Agent's Dynamic Adaptation

Notice how Copilot responds:
1. **Detects the Exact Delta:** Copilot pinpoints the new 500-character comment constraint from the recent comment.
2. **Generates Targeted Test Plan:** Proposes adding a new xUnit test case (e.g. `PostReview_CommentExceeding500Chars_Returns400BadRequest`).
3. **Preserves Existing Context:** Keeps all previous requirements (rating validation, PII masking, idempotency) intact without regression.

---

## 🧠 Key Takeaways from Stage 2C

> **Key Takeaway:** *"When your agent is connected to your workflow, keeping it informed is just doing your normal job: update the ticket."*

We have seen the power of Objectives, Context, and Live Connections. However, entering rules in
chat prompts is still fragile. If you start a new session in Copilot Chat tomorrow, all of this
conversation context disappears.

In the next module, we will climb **The Durability Ladder** to permanently institutionalize our guardrails, custom agents, and reusable skills.

---

**Workshop Navigation:**  
[← Previous Step: Stage 2B — MCP Connected Context](04-stage-2b-mcp-connected-context.md) | **Current: Module 05 (Stage 2C)** | [Next Step: Stage 3 — The Durability Ladder →](06-stage-3-the-durability-ladder.md)
