# Module 02 — Stage 1: Objective & Acceptance Criteria

**Workshop Navigation:**  
[← Previous Step: Stage 0 — Undirected Prompt](01-stage-0-the-undirected-prompt.md) | **Current: Module 02 (Stage 1)** | [Next Step: Stage 2A — Context & PII Exploit →](03-stage-2a-context-and-the-pii-exploit.md)

---

## 🎯 Learning Goal
Learn how establishing a clear **Product Objective** and unambiguous **Acceptance Criteria (AC)** immediately collapses unwanted agent hallucinations, scopes code generation to an in-memory ASP.NET Core Web API (Controllers), and produces our first verified unit test.

---

## 📁 Step 1: Create the Product Objective Document

Create the file `docs/context/product-objective.md` in your workspace. Run one of the following in your terminal, or create it manually in VS Code:

**Windows (PowerShell):**
```powershell
New-Item -ItemType Directory -Force -Path docs\context | Out-Null
New-Item -ItemType File -Force -Path docs\context\product-objective.md | Out-Null
```

**macOS/Linux (bash):**
```bash
mkdir -p docs/context && touch docs/context/product-objective.md
```

📝 **Paste the following content into `docs/context/product-objective.md` and save:**

```markdown
# Product Objective: Workshop Reviews API

## Business Goal
Enable festival attendees to submit ratings and reviews for workshop sessions so that organizers can measure session quality and improve future festival editions.

## In-Scope Functionality
1. Accept attendee reviews containing a workshop identifier, attendee identifier, numeric rating, and optional comment via `POST /reviews`.
2. Provide aggregate review metrics per workshop (average rating and total submission count).
3. Log every accepted review with `ILogger` at `Information` level so operators can follow incoming submissions in the API console. The entry must include the workshop identifier and the submitted comment, for example: `Received review for ws-ai: <comment>`.

## Out-of-Scope (Strict Non-Goals)
- No user authentication or OAuth flows.
- No external database infrastructure (EF Core, SQL Server, PostgreSQL, SQLite).
- No message queues or external email notification services.
- Keep all data persistence in-memory.

## Primary Acceptance Criteria
- **AC 1 (Rating Range):** Ratings must be integer values between `1` (lowest) and `5` (highest) inclusive. Any rating outside this range must return HTTP `400 Bad Request`.
- **AC 2 (Required Fields):** `WorkshopId`, `AttendeeId`, and `Rating` are required.
- **AC 3 (Automated Testing):** All validation rules must be covered by automated xUnit tests.
```

---

## 💬 Step 2: Plan First, Then Implement

> [!IMPORTANT]
> **Start a new session in Copilot Chat in VS Code** and select **Plan** mode. Do not accept or
> apply changes during the planning pass.

### 2a. Ask for a plan without editing

Send this prompt in **Plan** mode:

```text
Read docs/context/product-objective.md and create a concise implementation plan for it.
Cover the Reviews API files, the xUnit tests, the existing baseline test that may need to be
retired, and the validation needed for every acceptance criterion. Do not edit any files.
```

Review the plan before continuing. You should be able to see the scope, files, tests, and
validation approach **before any code changes are made**. Check that it derives the endpoint
shape, rating range, required fields, and in-memory constraint from the objective document rather
than inventing database infrastructure.

### 2b. Implement the approved plan

> [!TIP]
> When Copilot asks for an execution option, start with **Default permissions**. This is the
> least-permissive choice and keeps you involved when Copilot needs approval to perform actions,
> which is useful while you are learning how the plan maps to real file changes. **Allow all**
> gives Copilot broader permission to carry out the approved plan without asking as often; use it
> only when you understand and accept the additional level of access. **Autopilot** lets Copilot
> proceed with minimal supervision, so treat it as an efficiency option for participants who
> already have enough experience to monitor the work and review the resulting changes carefully.

After reviewing the plan, choose **Start implementation** (or the equivalent implementation
action) in the plan response. Copilot automatically switches to **Agent** mode and continues
with the approved plan; do not resend the prompt. Compare the resulting edits with the plan and
note any difference before accepting them.

**What to expect:** The Plan pass should make the intended work visible without changing files.
Starting implementation should follow that scope, modify only the Reviews API and its tests, and
avoid database packages.

---

## 🔍 Step 3: Observe the Agent's Focused Execution

Notice how the plan-first flow changes the agent's behavior:
1. **Zero Database Bloat:** The agent avoids proposing Entity Framework Core or SQLite because the objective document's out-of-scope constraints explicitly forbid them.
2. **Precise Logic Derived from the Document:** The agent writes a clean controller action with a `if (rating < 1 || rating > 5) return BadRequest(...)` check in `Controllers/ReviewsController.cs`, matching AC 1 from `product-objective.md` — even though the prompt never restated that rule.
3. **Automated Tests Created:** The agent adds structured xUnit test methods targeting the boundary conditions described in AC 3, and retires the now-conflicting baseline test.
4. **Observable Behavior:** The agent injects `ILogger` into the controller and logs each accepted review, giving the next stage a visible server log to inspect.

---

## 🧪 Step 4: Verify the Implementation

Let's verify that the new endpoint, validation rule, and automated tests pass.

### 1. Run Automated xUnit Tests
Run the test suite in your terminal:

```bash
dotnet test
```

🔍 **Expected Output:**
```text
Test summary: total: 41; failed: 0; succeeded: 41; skipped: 0; duration: 2,5s
Build succeeded in 4,2s
```

At least some extra tests should be created if not ask your agent to add the tests. Look at the tests, what are they testing and is it enough to cover the acceptance criteria?

### 2. Test Invalid Rating
Start the API in one terminal:

**Windows (PowerShell):**
```powershell
dotnet run --project src\SpaceRockIT.Reviews.Api --urls http://localhost:5081
```

**macOS/Linux (bash):**
```bash
dotnet run --project src/SpaceRockIT.Reviews.Api --urls http://localhost:5081
```

Then submit an out-of-range rating from a second terminal:

**macOS/Linux (bash):**
```bash
curl -i -X POST "http://localhost:5081/reviews" \
  -H "Content-Type: application/json" \
  -d '{"workshopId":"ws-ai", "attendeeId":"att-01", "rating":6, "comment":"Invalid rating test"}'
```

**Windows (PowerShell):**

```powershell
curl.exe -i -X POST "http://localhost:5081/reviews" `
  -H "Content-Type: application/json" `
  -d '{"workshopId":"ws-ai","attendeeId":"att-01","rating":6,"comment":"Invalid rating test"}'
```

**What to expect:** The Reviews API test project should report four passing tests after the
baseline endpoint test is retired; the web test project may report its separate existing count.

🔍 **Expected Response:**
```http
HTTP/1.1 400 Bad Request
{"error":"Rating must be between 1 and 5."}
```

### 3. Test Valid Rating
Submit a valid rating:

**macOS/Linux (bash):**
```bash
curl -i -X POST "http://localhost:5081/reviews" \
  -H "Content-Type: application/json" \
  -d '{"workshopId":"ws-ai", "attendeeId":"att-01", "rating":4, "comment":"Great session!"}'
```

**Windows (PowerShell):**

```powershell
curl.exe -i -X POST "http://localhost:5081/reviews" `
  -H "Content-Type: application/json" `
  -d '{"workshopId":"ws-ai","attendeeId":"att-01","rating":4,"comment":"Great session!"}'
```

🔍 **Expected Response:**
```http
HTTP/1.1 201 Created
```

### 4. Confirm the Review Is Logged

Switch to the terminal running the Reviews API. The accepted review should appear as an
`Information` log entry containing the workshop identifier and the comment:

```text
info: SpaceRockIT.Reviews.Api.Controllers.ReviewsController[0]
      Received review for ws-ai: Great session!
```

The category name and layout come from the default .NET console logger, so the exact prefix may
differ. What matters is that the workshop identifier and the comment text are visible.

If no review log appears, the implementation skipped the logging item in `product-objective.md`.
Ask Copilot in your Stage 1 session to log each accepted review with `ILogger` at `Information`
level, then restart the API and submit the review again. Stage 2A depends on this log line to
demonstrate a privacy defect.

### 5. Stop the API before continuing

After completing the live checks, return to the terminal running the Reviews API and press
**Ctrl+C**. Leave the API stopped before moving to Stage 2A; the next stage starts the API again
for its before-and-after privacy exercise, and stopping it now prevents a port conflict on 5081.

---

## 🧠 Key Takeaways from Stage 1

> **Key Takeaway:** *"Clear objective, clear scope. Defining what is out-of-scope is just as important as defining what is in-scope."*

We closed our first seam (rating validation) and added an automated test. However, our system still has a hidden security vulnerability. In the next module, we will explore **Context Engineering** and trigger a live PII leak.

---

**Workshop Navigation:**  
[← Previous Step: Stage 0 — Undirected Prompt](01-stage-0-the-undirected-prompt.md) | **Current: Module 02 (Stage 1)** | [Next Step: Stage 2A — Context & PII Exploit →](03-stage-2a-context-and-the-pii-exploit.md)
