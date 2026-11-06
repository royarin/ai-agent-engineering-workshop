# Module 04 — Stage 2B: Context by Connection via MCP

**Workshop Navigation:**  
[← Previous Step: Stage 2A — Context & PII Exploit](03-stage-2a-context-and-the-pii-exploit.md) | **Current: Module 04 (Stage 2B)** | [Next Step: Stage 2C — Iterative Ticket Refinement →](05-stage-2c-iterative-ticket-refinement.md)

---

## 🎯 Learning Goal
Understand why manual copy-pasting of requirements into chat prompts is fragile and stale, and learn how **Model Context Protocol (MCP)** connects AI agents directly to live enterprise systems of record (backlog items, wikis, PRs) with authoritative citations.

---

## 💡 What is Model Context Protocol (MCP)?

In everyday development, critical requirements do not live in your chat clipboard:
- Product requirements live in **GitHub Issues** or **Azure DevOps Boards**.
- Architecture policies live in **Team Wikis** or **Confluence**.
- Security rules live in **Central Policy Repositories**.

**Model Context Protocol (MCP)** is an open standard that allows Copilot to query these systems on demand. Instead of a human developer pasting outdated snippets, the agent pulls fresh, structured data directly from the authoritative source.

---

## 🔐 Prerequisite: Configure and Verify Read-Only GitHub MCP Access

Complete this once before the live MCP exercises. These steps use GitHub's hosted MCP endpoints and the GitHub account already signed in to GitHub Copilot; **do not create, paste, or commit a personal access token for this workshop**.

1. Confirm that you are signed in to GitHub Copilot in VS Code and have read access to the workshop repository.
2. Create `.vscode/mcp.json` with the following credential-free configuration. Run one of these first to create the empty file, or create it manually in VS Code:

   **Windows (PowerShell):**
   ```powershell
   New-Item -ItemType Directory -Force -Path .vscode | Out-Null
   New-Item -ItemType File -Force -Path .vscode\mcp.json | Out-Null
   ```

   **macOS/Linux (bash):**
   ```bash
   mkdir -p .vscode && touch .vscode/mcp.json
   ```

   It exposes only the GitHub read-only Issues and Repositories MCP endpoints:

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
3. In VS Code, open the MCP Servers view by typing "> MCP List Servers" in the command palette, then start **both** servers — `github-issues-readonly` **and** `github-repos-readonly` — completing the browser sign-in/authorization prompt if VS Code requests it. Do not approve a server you do not recognize. Both must show as running; later steps read issue content through one and repository content through the other.
4. Starting a server only makes it reachable. You must also **enable its tools for your chat session** before Copilot will call it. In the Copilot Chat input box, select the **tools icon** (🛠️) to open the tools picker, then **tick the checkbox next to both `github-issues-readonly` and `github-repos-readonly`**. The tool count shown beside the icon should increase once they are enabled.

   > [!IMPORTANT]
   > This tool selection applies to the **current chat session only**. The workshop asks you to start
   > a new session at several points, so **re-open the tools picker and re-tick both servers each time
   > you start a fresh session**. Forgetting this is the single most common reason an MCP prompt
   > returns invented answers instead of live GitHub data.

5. Then follow this action:

   > [!IMPORTANT]
   > **Start a new session in Copilot Chat in VS Code**, select **Ask** mode, enable both MCP servers
   > in the tools picker as described above, and run the smoke test below. Do not continue an
   > existing conversation.

   ```text
   Use the github-issues-readonly MCP server to list the open issues in this repository. Cite each issue number and title. Do not create, update, close, or comment on any issue.
   ```

   The first time Copilot invokes a tool, VS Code asks you to confirm the call — choose **Allow** (or **Always allow** for this session) to let the request through.

6. Continue only when Copilot returns live issue data with citations. If it cannot authenticate, verify that the signed-in account can view the repository and that your organization permits MCP access. Do not substitute a token in a committed file.

> **Credential safety:** `.gitignore` excludes `.env`, `.env.*`, and `.vscode/mcp.local.json` for any future local-only experiments. A real token must never appear in source code, `mcp.json`, chat transcripts, or commits.

---

## 📁 Step 1: Use the GitHub UI to Initialize the Live Backlog Issue and Wiki

The next exercises use real GitHub sources of record, not local Markdown stand-ins. Use the GitHub web UI for every authoring action: creating and editing Issue #1, publishing the wiki page, linking the policy, and adding the Stage 2C refinement comment. The workshop MCP connection is intentionally read-only and is used only to retrieve and cite Issue #1.

> **Issue number:** A clean fork starts with this workshop issue as **Issue #1**. In an existing
> or shared repository, the issue number can be any number based on that repository's current
> state. Record the assigned number and replace every `#1` reference in the remaining workshop
> prompts with that number.

### 1. Create Issue #1

In the GitHub repository, select **Issues** → **New issue**, use the title `Workshop session reviews & Rating API`, and paste this issue body:

```markdown
## Description
As a festival organizer, I want attendees to submit ratings and reviews for workshop sessions so that we can evaluate speaker quality and popularity in real time.

## Acceptance Criteria
- **AC 1:** `POST /reviews` accepts JSON payload containing `WorkshopId` (string), `AttendeeId` (string), `Rating` (int 1–5), and optional `Comment` (string). Return HTTP 201 on success; HTTP 400 on validation failure.
- **AC 2:** Comments must have email addresses sanitized to `[redacted-email]` per team PII policy before logging or persistence.
- **AC 3:** `GET /reviews?workshopId={id}` returns aggregate summary: `AverageRating` (float), `TotalCount` (int), and sanitized `Comments` (list of strings).
- **AC 4 (Idempotency):** Submissions from the same `AttendeeId` for the same `WorkshopId` must update the previous rating rather than creating duplicate entries.
```

### 2. Publish the PII policy wiki page

In the GitHub repository, enable **Wikis** under **Settings** → **General** → **Features** if necessary. Then select the **Wiki** tab, create the page `Engineering/Policies/PII-Handling-Standard`, and paste:

```markdown
# Wiki: /Engineering/Policies/PII-Handling-Standard

## Policy Scope
This standard applies to all customer-facing and attendee-facing APIs across SpaceRockIT.

## Mandatory Redaction Rules
1. **Email Redaction:** Any string field containing user-generated input must be passed through regex pattern matching (`[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}`) and replaced with `[redacted-email]` before logging or serializing into external responses.
2. **Synthetic Test Data Obligation:** Automated test suites must NEVER use real personal emails or phone numbers. All unit and integration test fixtures must use synthetic addresses (e.g. `alex.dev@enterprise.org`, `test.user@example.com`).
```

Copy the published wiki page URL and add it to the Issue #1 description beneath the acceptance criteria:

```markdown
## Related policy
PII policy: <published-wiki-page-url>
```

### 3. Confirm the live sources in the UI

Open the issue and wiki URL in a browser while signed in. Confirm the issue contains AC 1 through AC 4 and the policy page contains the email-redaction rule. Then run this non-destructive MCP check for the issue:

> [!IMPORTANT]
> **Check your tools before sending this prompt.** Both `github-issues-readonly` and
> `github-repos-readonly` must be started *and* ticked in the chat tools picker (🛠️) for this
> session — see the prerequisite steps above. A running server that is not enabled in the chat will
> not be called, and Copilot will answer from guesswork instead of live GitHub data.

```text
Use the GitHub MCP server to fetch Issue #1 in this repository. Cite the issue URL and list AC 1 through AC 4. Do not write or modify anything.
```

Continue only when MCP cites the issue and the linked policy is visible in the GitHub UI. The wiki remains the human-visible policy source in this exercise; do not attempt to create, edit, or comment through MCP.

---

## 💬 Step 2: Prompt Copilot via Connected Context

Now, ask Copilot to query the backlog issue through MCP and use the linked policy page that you verified in the GitHub UI.

> [!WARNING]
> **Your issue number may not be `#1`.** A freshly forked repository starts empty, so the issue you
> created in Step 1 becomes Issue #1. But if your repository already contains issues — or if issues
> or pull requests were opened in it at any point in the past — GitHub keeps counting from the
> highest number ever used and will not reuse `#1`. Note that pull requests share the same numbering
> sequence as issues, so even a repository with no visible issues can start at a higher number.
>
> Check the number shown on your own issue in the GitHub UI, and **replace `#1` in the prompt below
> with that number** before sending it. Do the same for every remaining prompt in this stage and in
> Stage 2C and Stage 4. If you use the wrong number, Copilot will either cite someone else's issue
> or report that it cannot find it — and the requirement map in Step 3 will not match what the
> workshop describes.

> [!IMPORTANT]
> **Start a new session in Copilot Chat in VS Code**, select **Ask** mode, **re-enable both MCP
> servers in the tools picker (🛠️)** — tool selections do not carry over to a new session — and send
> the following prompt:

```text
Fetch the requirements for our review feature from Issue #1 through MCP. Use the linked team PII policy page as the privacy source.
List every requirement needed to complete this feature, citing the issue and the policy page URL.
Do not write code yet.
```

---

## 🔍 Step 3: Discover the "Surprise Requirement"

Look at the structured requirement map that Copilot returns:

1. **Rating Range 1–5:** Cited from `Issue #1 - AC #1`.
2. **Email Redaction:** Cited from `Wiki: /Engineering/Policies/PII-Handling-Standard`.
3. **Aggregate Summary:** Cited from `Issue #1 - AC #3`.
4. 💡 **The Surfaced Surprise Requirement:**  
   `Issue #1 - AC #4: Idempotency (Same AttendeeId updates existing rating instead of duplicating).`

Notice what just happened: In Stages 0 and 1, we completely overlooked duplicate attendee submissions. Because the agent was connected to the system of record, it surfaced the idempotency requirement automatically.

---

## 🧠 Key Takeaways from Stage 2B

> **Key Takeaway:** *"Don't paste context — connect to it. MCP turns fragile copy-pasting into live, traceable truth."*

In the next module, we will explore what happens when requirements change dynamically in the system of record.

---

**Workshop Navigation:**  
[← Previous Step: Stage 2A — Context & PII Exploit](03-stage-2a-context-and-the-pii-exploit.md) | **Current: Module 04 (Stage 2B)** | [Next Step: Stage 2C — Iterative Ticket Refinement →](05-stage-2c-iterative-ticket-refinement.md)
