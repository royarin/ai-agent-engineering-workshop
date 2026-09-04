# Module 07 — Stage 4: The Full Loop Redo & Live Verification

**Workshop Navigation:**  
[← Previous Step: Stage 3 — The Durability Ladder](06-stage-3-the-durability-ladder.md) | **Current: Module 07 (Stage 4)** | [Next Step: Module 08 — Wrap-Up & Takeaways →](08-wrap-up-and-takeaways.md)

---

## 🎯 Learning Goal
Experience the ultimate payoff of the Durability Ladder. Reset the repository to a clean baseline,
send an ultra-minimal story prompt (`"Implement Issue #1"`), watch Copilot assemble context and
execute within governed boundaries, verify the live application (Green Bookend), run a reviewer
audit, and generate an auditor-ready PR.

---

## 🧹 Step 0: Reset the Repository Before You Begin

Do this before anything else in Stage 4. Remove the review feature you built in Stages 1–2C and keep
the Durability Ladder you built in Stage 3.

Do this because Stage 4 answers one question: **can your durable context rebuild the feature from
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
| Issue #1 and the PII policy wiki page in GitHub | Read live through MCP |
| Everything under `src/SpaceRockIT.Web/` | Never in scope |

> [!WARNING]
> **Never run a bare `git clean -fd`.** Your `.github/` and `.vscode/` folders are untracked, so an
> unscoped clean deletes your whole Durability Ladder and leaves Stage 4 with nothing to work from.
> Scope every clean to `src` and `tests`, and delete `docs/` as its own separate step.

### 1. Stop the running applications

Go to the terminals running the Reviews API and the web front end and press **Ctrl+C** in each. Free
port 5081 now — if the old API keeps running, your Stage 4 verification will hit the previous build
and appear to pass for the wrong reason.

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
> served their purpose. From here they are only noise — Stage 4 measures whether durable context
> alone can rebuild the feature, and anything left over would weaken that result.

---

## 💬 Step 1: Send the Ultra-Minimal Story Prompt

Remember Stage 0 when we had to type a long prompt and still received hallucinated code?

> [!IMPORTANT]
> Now that the full Durability Ladder (Repo Instructions, Path Scoping, MCP, Custom Agents, and
> Skills) is active, **start a new session in Copilot Chat in VS Code**, select **Agent** mode,
> **re-enable both `github-issues-readonly` and `github-repos-readonly` in the tools picker (🛠️)** —
> without them the agent cannot read the issue — and send only the issue reference. Use `#1` for a
> clean fork, or substitute the issue number assigned in your repository:

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
   - *Phase 3 (Reviewer):* Pre-merge compliance audit.

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

---

## 🧪 Step 4: Run Automated Tests

Execute the full test suite in your terminal:

```bash
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
5. `PostReview_CommentWithEmail_RedactsEmailToPlaceholder` (Stage 4 PII sanitization)
6. `PostReview_SameAttendeeDuplicate_UpdatesExistingRatingIdempotently` (Stage 4 idempotency)
7. `GetReview_CalculatesAverageRatingAndCount` (Stage 4 aggregation)
8. `PostReview_CommentExceeding500Chars_Returns400BadRequest` (Stage 2C refined maximum-length validation)
9. `PostReview_WhitespaceOnlyComment_Returns400BadRequest` (Stage 2C refined blank-comment validation)

> 📌 **Note:** `No_review_endpoints_exist_yet`, the baseline seam test you restored during the reset,
> is retired again here — once `POST /reviews` exists, its assertion no longer applies. Watching the
> agent remove it is a good sign: it recognised the seam test had served its purpose.

> [!TIP]
> Your exact test count and names may differ. Agents are non-deterministic, and some will add an extra test for the logging behaviour required by `reviews.instructions.md`. What matters is that **Failed: 0** and that every acceptance criterion has at least one test covering it.

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

## 🧠 Key Takeaways from Stage 4

> **Key Takeaway:** *"A fast, predictable, test-verified, PII-safe feature — fully planned, executed, tested, and audited within governed boundaries in under an hour."*

Head over to **Module 08** for a final retrospective and self-paced challenge exercises!

---

**Workshop Navigation:**  
[← Previous Step: Stage 3 — The Durability Ladder](06-stage-3-the-durability-ladder.md) | **Current: Module 07 (Stage 4)** | [Next Step: Module 08 — Wrap-Up & Takeaways →](08-wrap-up-and-takeaways.md)
