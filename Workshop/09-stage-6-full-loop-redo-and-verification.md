# Module 09 — Stage 6: The Full Loop Redo & Live Verification

**Workshop Navigation:**  
[← Previous Step: Stage 5 — Hooks](08-stage-5-hooks-from-instruction-to-enforcement.md) | **Current: Module 09 (Stage 6)** | [Next Step: Wrap-Up & Takeaways →](10-wrap-up-and-takeaways.md)

---

> [!NOTE]
> **This is the last stage, and it is the only one that uses everything at once.** Stages 0
> to 2C taught you what context to provide; Stage 3 made it durable; Stage 4 gave you a
> supervisor; Stage 5 made the important rules enforceable. Here you delete the feature and
> find out whether the system you built can put it back.

## 🎯 Learning Goal
Experience the ultimate payoff of the Durability Ladder. Reset the repository to a clean baseline,
send an ultra-minimal story prompt (`"Implement Issue #1"`), watch Copilot assemble context and
execute within governed boundaries, verify the live application (Green Bookend), run a reviewer
audit, and generate an auditor-ready PR.

---

## 🧹 Step 0: Reset the Repository Before You Begin

Do this before anything else in Stage 4. Remove the review feature you built in Stages 1–2C and keep
the Durability Ladder you built in Stage 3.

Do this because Stage 6 answers one question: **can your durable context rebuild the feature from
nothing?** Leave the old code in place and the agent will just edit what it finds, so you never see
the answer.

**Delete these:**

| Item | Why |
|---|---|
| `ReviewsController.cs` and any review models, DTOs, or storage classes | Stage 4 rewrites the implementation |
| Every review test added under `tests/SpaceRockIT.Reviews.Api.Tests/`, plus the edits to `ApiTests.cs` | Stage 4 regenerates its own tests; keeping the old ones makes a green run meaningless |
| The whole `docs/` folder, including `docs/context/product-objective.md` | This was your **manual** context — a file you had to attach by hand. Stage 3 replaced it with instructions the agent loads on its own. Keep it and Stage 4 may succeed on the old mechanism instead of the ladder |

**Keep these:**

| Item | Role |
|---|---|
| `.github/copilot-instructions.md`, `.github/instructions/`, `.github/agents/`, `.github/skills/` | Your Stage 3 durable context |
| `.vscode/mcp.json` | Your Stage 3 tool governance |
| Issue #1 in GitHub | Read live by the specialist agents through the `github-issues-readonly` MCP server |
| The PII policy wiki page | Linked from the issue. The MCP servers do not expose wiki pages, so the agents fetch it with the `web` tool; the PII rule is also durable in `.github/instructions/` |
| Everything under `src/SpaceRockIT.Web/` | Never in scope |

> [!WARNING]
> **Never run a bare `git clean -fd`.** Your `.github/` and `.vscode/` folders are untracked, so an
> unscoped clean deletes your whole Durability Ladder and leaves Stage 4 with nothing to work from.
> Scope every clean to `src` and `tests`, and delete `docs/` as its own separate step.

### 1. Stop the running applications

Go to the terminals running the Reviews API and the web front end and press **Ctrl+C** in each. Free
port 5081 now — if the old API keeps running, your verification will hit the previous build
and appear to pass for the wrong reason.

> [!TIP]
> **Prefer the script.** `scripts/reset-feature.sh` (or `.ps1`) performs steps 2 and 3 in one
> go and refuses to touch `.github/` or `.vscode/`. Run it without arguments first for a dry
> run that lists exactly what would be removed:
>
> **Windows (PowerShell):** `.\scripts\reset-feature.ps1` then `.\scripts\reset-feature.ps1 -Apply`
> **macOS/Linux (bash):** `./scripts/reset-feature.sh` then `./scripts/reset-feature.sh --apply`
>
> The manual steps below are what the script does, kept here so you can see it.

### 2. Undo the API and test project changes

Run both commands from the repository root. `git restore` reverts files tracked in git, including the
`ApiTests.cs` that Stage 1 modified. `git clean` deletes newly added files and is scoped to `src` and
`tests` so your ladder artifacts stay put.

**Windows (PowerShell):**
```powershell
git restore src tests
git clean -fd src tests
```

**macOS/Linux (bash):**
```bash
git restore src tests
git clean -fd src tests
```

> [!TIP]
> See what will be deleted before deleting it — run `git clean -nd src tests` first. Check the list
> contains only review controllers, models, and tests, then run the real command.

### 3. Delete the manual context folder

**Windows (PowerShell):**
```powershell
Remove-Item -Recurse -Force docs
```

**macOS/Linux (bash):**
```bash
rm -rf docs
```

### 4. Confirm the baseline

Check your working tree:

```text
git status
```

`docs/` is gone, `.github/` and `.vscode/` are still listed as untracked, and `src` and `tests` show
no changes.

Now run the baseline tests:

```text
dotnet test --nologo --filter FullyQualifiedName~SpaceRockIT.Reviews.Api.Tests
```

Three tests pass: `Health_responds`, `Health_leaks_nothing_internal`, and the restored
`No_review_endpoints_exist_yet`. That third test is your proof the review feature is genuinely gone —
it only passes while `/reviews` returns `404 Not Found`.

Your repository is now reset and ready.

> [!NOTE]
> **Why keep the Stage 1–2C code and `docs/` all the way through Stage 3?** Stage 3 needed a real,
> existing implementation and a visible manual-context file so you could watch small scoped edits
> pick up your new instruction files and compare the two approaches side by side. They have now
> served their purpose. From here they are only noise — This stage measures whether durable context
> alone can rebuild the feature, and anything left over would weaken that result.

---

## 💬 Step 1: Send the Ultra-Minimal Story Prompt

You can run this stage two ways. Do the first; come back and do the second if you have time,
because the difference between them is the whole argument for Stage 4.

| | Prompt | What you are testing |
|---|---|---|
| **A — default agent** | `Implement Issue #1.` | Whether durable context alone is enough |
| **B — supervisor** | Select **Feature Builder**, then `Implement Issue #1.` | Whether explicit sequencing beats inference |

Run **A** first.


Remember Stage 0 when we had to type a long prompt and still received hallucinated code?

> [!IMPORTANT]
> Now that the full Durability Ladder (Repo Instructions, Path Scoping, MCP, Custom Agents, and
> Skills) is active, **start a new session in Copilot Chat in VS Code**, select **Agent** mode, and
> confirm both `github-issues-readonly` and `github-repos-readonly` are **started** in
> `.vscode/mcp.json`. The specialists now request these servers in their own `tools:` lists, so you
> no longer tick them per agent — but a grant cannot start a server that is not running, and an
> unavailable server is ignored silently rather than reported as an error. Then send only the issue
> reference. Use `#1` for a clean fork, or substitute the issue number assigned in your repository:

```text
Implement Issue #1.
```

**What to expect:** Copilot should assemble the issue, policy, scoped instructions, personas, and
skills, state its plan before editing, and keep changes within the permitted source and test
folders.

---

## 🔍 Step 2: Observe Autonomous Implicit Context Assembly & Planning

Watch how the agentic harness assembles context without being reminded:
1. **MCP Query:** Fetches Issue #1 (or your repository's assigned issue number) with the rating range 1–5, max 500-character comment length, and idempotency requirement.
2. **Wiki Query:** Queries `/Engineering/Policies/PII-Handling-Standard` via Wiki context.
3. **Instruction Injection:** Injects `reviews.instructions.md` triggered by `applyTo: "src/SpaceRockIT.Reviews.Api/**"`.
4. **Structured Plan Output:** Outputs an implementation plan *before* touching files:
   - *Phase 1 (Developer):* Controller endpoints, in-memory storage, idempotency, `ILogger` observability, and `/skill pii-sanitizer`.
   - *Phase 2 (Tester):* Automated xUnit test suite targeting all boundary conditions and synthetic PII fixtures.
   - *Phase 3 (Documenter):* Decision records for the constraints this feature locks in.
   - *Phase 4 (Reviewer):* Pre-merge compliance audit over both the code and the record.

> [!NOTE]
> Document runs **before** review, not after it. The reviewer should be auditing the decision
> record alongside the code — a decision nobody wrote down is a decision nobody can review.

---

## 🛠️ Step 3: Agent Execution Within Boundaries

Watch the multi-agent personas execute:
- **Developer Persona (`@developer`):**
  - Edits `src/SpaceRockIT.Reviews.Api/Controllers/ReviewsController.cs` and domain models.
  - Invokes `/skill pii-sanitizer` to apply standard email masking:
    `Regex.Replace(input, @"[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}", "[redacted-email]")`
  - Validates ratings (1–5), enforces max 500-character comments, and ensures idempotent updates by `AttendeeId`.
  - Logs each accepted review with `ILogger` at `Information` level using the sanitized comment, which produces the Green Bookend output verified in Step 5.
- **Tester Persona (`@tester`):**
  - Adds comprehensive xUnit tests in `tests/SpaceRockIT.Reviews.Api.Tests/`.
  - Runs `dotnet test` in the terminal.
- **Documenter Persona (`@documenter`):**
  - Must invoke `/skill adr` and write decision records under `docs/adr/` — typically one for the
    in-memory persistence choice and one for redacting email before logging.
  - The repository instruction limits implementation changes to `src/` and `tests/`, but
    explicitly permits the Documenter to write documentation under `docs/`; these scopes do
    not conflict. Records **where each constraint came from**: cite the applicable repository
    instruction and the linked PII policy page where relevant.
  - Has no `execute` tool, so it cannot run the suite. Watch what it writes about the test result:
    it includes the exact result from `@tester` in a Verification section and attributes it,
    rather than claiming it ran the suite. That is the clearance doing a second job — bounding
    not only what the agent can damage, but what it can honestly assert.

---

## 🧪 Step 4: Run Automated Tests

Execute the full test suite in your terminal:

```text
dotnet test
```

🔍 **Expected Output:**
```text
Passed!  - Failed: 0, Passed: 9, Skipped: 0, Total: 9
```

All 9 test cases pass:
1. `Health_responds` (Baseline health test)
2. `Health_leaks_nothing_internal` (Baseline health test)
3. `PostReview_ValidRating_Returns201Created` (Stage 1 rating validation)
4. `PostReview_RatingOutOfRange_Returns400BadRequest` (Stage 1 boundary rejection)
5. `PostReview_CommentWithEmail_RedactsEmailToPlaceholder` (PII sanitization)
6. `PostReview_SameAttendeeDuplicate_UpdatesExistingRatingIdempotently` (idempotency)
7. `GetReview_CalculatesAverageRatingAndCount` (aggregation)
8. `PostReview_CommentExceeding500Chars_Returns400BadRequest` (Stage 2C refined maximum-length validation)
9. `PostReview_WhitespaceOnlyComment_Returns400BadRequest` (Stage 2C refined blank-comment validation)

> 📌 **Note:** `No_review_endpoints_exist_yet`, the baseline seam test you restored during the reset,
> is retired again here — once `POST /reviews` exists, its assertion no longer applies. Watching the
> agent remove it is a good sign: it recognised the seam test had served its purpose.

> [!TIP]
> Your exact test count and names may differ. Agents are non-deterministic, and some will add an extra test for the logging behaviour required by `reviews.instructions.md`. What matters is that **Failed: 0** and that every acceptance criterion has at least one test covering it.

---

## 📝 Step 4b: Inspect the Decision Records

The feature is not the only output. Look at what the documenter produced:

```text
docs/
└── adr/
    ├── 0001-keep-review-persistence-in-memory.md
    └── 0002-redact-email-before-logging.md
```

Open `0002` and read its **Consequences** section. A good record will note that the pattern
covers email addresses only, and that widening it later supersedes the record rather than
editing it in place. Nobody asked for that caveat — it falls out of the skill's template.

Then check the **Source** lines. `0001` should cite the issue and the architectural boundary
in `copilot-instructions.md`; `0002` should cite both the applicable repository instruction
and the PII policy wiki page it fetched, not just the issue. The distinction matters:
one constraint came from the product, the others from policies that outlive this ticket.
Each ADR's **Verification** section should record the exact test result reported by `@tester`
and attribute it to that agent.

> [!TIP]
> If the documenter wrote "all tests pass" as a bare assertion, that is worth pausing on. It
> has no `execute` tool, so it did not run them. Ask it to attribute the claim, and notice that
> the fix is a clearance question rather than a writing-quality one.

---

## 🟢 Step 5: Live Verification & The Green Bookend

Let's test the live running API with the exact exploit payload from Stage 2A.

### 1. Start the API Server
In your terminal, start the API:

**Windows (PowerShell):**
```powershell
dotnet run --project src\SpaceRockIT.Reviews.Api --urls http://localhost:5081
```

**macOS/Linux (bash):**
```bash
dotnet run --project src/SpaceRockIT.Reviews.Api --urls http://localhost:5081
```

### 2. Submit the Exploit Payload
In a second terminal, submit a review containing the attendee email address:

**macOS/Linux (bash):**
```bash
curl -X POST "http://localhost:5081/reviews" \
  -H "Content-Type: application/json" \
  -d '{"workshopId":"ws-ai", "attendeeId":"att-99", "rating":5, "comment":"Great practical insights on agent memory! Happy to share our team benchmark data: alex.dev@enterprise.org"}'
```

**Windows (PowerShell):**

```powershell
curl.exe -X POST "http://localhost:5081/reviews" `
  -H "Content-Type: application/json" `
  -d '{"workshopId":"ws-ai","attendeeId":"att-99","rating":5,"comment":"Great practical insights on agent memory! Happy to share our team benchmark data: alex.dev@enterprise.org"}'
```

### 3. Check Server Logs
Look at the log output printed by your running API:

🔍 **The Green Bookend in Server Logs:**
```text
info: SpaceRockIT.Reviews.Api.Controllers.ReviewsController[0]
      Received review for ws-ai from att-99. Rating: 5. Comment: Great practical insights on agent memory! Happy to share our team benchmark data: [redacted-email]
```

The exact wording of the message is up to the agent, but the line must appear and the email must already be redacted. Notice what just happened: **the issue never asked for logging.** The log statement comes from `reviews.instructions.md`, the path-scoped instruction file you created in Stage 3 — the agent applied your team's engineering convention on its own, without you restating it.

> [!NOTE]
> If you see no output at all, confirm you started the API with `dotnet run` in a visible terminal rather than through `run.ps1` or `run.sh`, which send the API output elsewhere.

### 4. Verify Aggregate Summary
Query the aggregate endpoint:

**macOS/Linux (bash):**
```bash
curl "http://localhost:5081/reviews?workshopId=ws-ai"
```

**Windows (PowerShell):**

```powershell
Invoke-WebRequest -Uri "http://localhost:5081/reviews?workshopId=ws-ai" -Method Get
```

🔍 **Expected JSON Output:**
```json
{
  "workshopId": "ws-ai",
  "averageRating": 5.0,
  "totalCount": 1,
  "comments": [
    "Great practical insights on agent memory! Happy to share our team benchmark data: [redacted-email]"
  ]
}
```

🎉 **Success:** The email address was safely masked, ratings were stored in-memory, and zero PII was leaked!

### Before continuing: stop the API

When the live verification is complete, return to the terminal running the Reviews API and press
**Ctrl+C**. Stop the process before starting the new Copilot reviewer session so the repository
is left clean and port 5081 is available for any later verification.

---

## 🛡️ Step 6: Run Reviewer Audit & Generate PR

### 1. Perform Independent Pre-Merge Audit
> [!IMPORTANT]
> In Copilot Chat, **start a new session**, select **Ask** mode, and invoke the Reviewer agent:

```text
@reviewer Audit current git diff before PR creation.
```

🔍 **Expected Audit Output:**
```text
- Architectural Boundaries: PASS (Confined to src/ and tests/)
- Privacy & PII Check: PASS (Regex email masking verified on comments)
- Observability: PASS (Accepted reviews logged at Information with redacted comment)
- Test Verification: PASS (9/9 xUnit tests green with synthetic fixtures)
- Merge Recommendation: APPROVE FOR MERGE
```

### 2. Generate Standardized Commit & PR
1. Generate the conventional commit message:
   ```text
   /skill git-commit
   ```
2. Generate the Pull Request summary:
   ```text
   /skill git-pr-summary main
   ```

🔍 **Generated PR Summary:**
```markdown
## Summary
Implements the workshop session reviews and rating API per Issue #1 and team PII policy.

## Key Changes
- `feat(reviews)`: add POST /reviews with 1-5 rating validation, max 500-char comments, and idempotency
- `feat(privacy)`: apply regex email sanitization ([redacted-email]) via pii-sanitizer skill
- `feat(aggregate)`: add GET /reviews computing average ratings and total counts
- `test(reviews)`: add 9 xUnit tests covering boundaries, synthetic PII, idempotency, and refined comment validation

Closes #1
```

---

---

## 🔁 Step 7: Run It Again Through the Supervisor

Reset the feature once more:

**Windows (PowerShell):** `.\scripts\reset-feature.ps1 -Apply`
**macOS/Linux (bash):** `./scripts/reset-feature.sh --apply`

Then, in a new session, select the **Feature Builder** agent and send the same three words:

```text
Implement Issue #1.
```

**What to compare:**

1. **Does the documentation stage happen without being asked?** Under the default agent it
   depends on inference. Under the supervisor it is step 4 of a written workflow.
2. **Does the report name its assumptions?** The supervisor is instructed to surface every
   decision it made without being told. That list is your human gate.
3. **Is the audit skipped when the change looks small?** The supervisor is told never to skip
   it. Inference sometimes does.

> [!NOTE]
> Sometimes run A is just as good. That is a fair result and worth sitting with — a
> supervisor buys you *repeatability*, not raw quality. When the flow is the same every time
> and you are tired of sequencing it by hand, the supervisor earns its place. Before that it
> is overhead.

---

## 🛡️ Step 8: Watch the Hooks Fire

Your Stage 5 gates have been live throughout this whole stage. Make that visible.

### 1. The completion gate

Break one test deliberately:

```csharp
// in tests/SpaceRockIT.Reviews.Api.Tests/ApiTests.cs, Health_responds
Assert.Equal(HttpStatusCode.Accepted, response.StatusCode);   // was OK
```

Then tell the agent it is finished:

```text
That's everything for this task — you can stop here.
```

The `agentStop` hook runs the suite, finds it red, and sends the agent back for another turn.
**The agent does not get to decide it is done.** Undo the break afterwards:

```text
git checkout -- tests/SpaceRockIT.Reviews.Api.Tests/ApiTests.cs
```

### 2. The tool gate

```text
Clean all untracked files out of the working tree.
```

```json
{"permissionDecision":"deny","permissionDecisionReason":"Blocked by repository policy: destructive or unreviewed-execution command."}
```

That gate is also why the reset in Step 0 has to be scoped and scripted rather than a bare
`git clean -fd` — the hook stops the agent, not you.

---

## 🧠 Key Takeaways from Stage 6

**What just happened, in one paragraph.** You deleted a feature and rebuilt it from three
words. The rating range and idempotency came from the issue over MCP. The redaction pattern
came from a policy page the issue merely linked to. The log line came from a path-scoped
instruction file, and no acceptance criterion ever mentioned it. The decision records came
from an agent with no shell access, so it attributed the test result rather than claiming it.
A read-only reviewer audited the lot, and a hook refused to let anything finish while the
suite was red. You typed three words.

> **Key Takeaway:** *"A fast, predictable, test-verified, PII-safe feature — fully planned, executed, tested, and audited within governed boundaries in under an hour."*

Head over to **Module 08** for a final retrospective and self-paced challenge exercises!

---

**Workshop Navigation:**  
[← Previous Step: Stage 5 — Hooks](08-stage-5-hooks-from-instruction-to-enforcement.md) | **Current: Module 09 (Stage 6)** | [Next Step: Wrap-Up & Takeaways →](10-wrap-up-and-takeaways.md)
