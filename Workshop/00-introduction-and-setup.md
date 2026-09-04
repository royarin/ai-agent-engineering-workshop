# Module 00 — Introduction & Setup

**Workshop Navigation:**  
[Workshop Roadmap](../README.md) | **Current: Module 00** | [Next Step: Stage 0 — The Undirected Prompt →](01-stage-0-the-undirected-prompt.md)

Welcome to **Taking Control of Your AI Coding Agent(s): patterns, guardrails, and practical tips**.

In this self-paced, hands-on workshop, you will work on the backend service for **SpaceRockIT Festival** — a hybrid open-air music and IT festival. Attendees participate in presentations and hands-on workshops during the day and watch rock bands at night.

Our business goal is to build an API feature allowing festival attendees to **submit ratings and reviews for workshop sessions** they attended.

### The Problem We Are Solving
When developers prompt AI coding agents with vague requirements or unconstrained chat prompts:
- Agents invent unwanted architectures (e.g. adding heavy database engines when in-memory stores are desired).
- Agents miss subtle security and privacy obligations (e.g. accidentally leaking attendee personal email addresses into log files).
- Agents write code without tests or fail to respect architectural boundaries.

Throughout this tutorial, you will progressively build a **governance system** (Objectives, Context, MCP Connections, Repo Instructions, Scoped Rules, Personas, and Skills) that turns an unpredictable AI into a reliable engineering partner.

---

## 🍴 Repository Setup

Before anything else, fork the repository with all branches, clone it, switch to the `workshop-run`
branch, and choose whether to work in a dev container, a GitHub Codespace, or on your local machine
— keeping these instructions open on `main` in your browser.

👉 **Follow [Set up your copy of the repository](../README.md#set-up-your-copy-of-the-repository)
in the README, then return here.**

> [!IMPORTANT]
> Do not skip this. Working on the wrong branch places the workshop instructions — including the
> expected outputs and solutions — inside the repository Copilot can read, and the exercises stop
> demonstrating anything. The README explains why in full.

---

## 🛠️ Prerequisites

> [!TIP]
> **Using the dev container or a Codespace?** Everything in this list is already installed and
> configured for you. Confirm with `dotnet --version` in the container terminal, make sure you are
> signed in to GitHub Copilot, and continue to the next section.

If you are working on your local machine, make sure your development environment has:
1. **.NET 10 SDK** (`dotnet --version`; the required version is pinned in `global.json`)
2. **Visual Studio Code** with the GitHub Copilot and GitHub Copilot Chat extensions
3. **GitHub Copilot** with Chat and Agent Mode enabled
4. **curl** or any REST client (e.g. Postman, Thunder Client, or browser)

---

## 📂 The Baseline Project Layout

In your workspace, the application is organized as follows:

```text
SpaceRockITFestival/
├── src/
│   ├── SpaceRockIT.Reviews.Api/
│   │   ├── Program.cs             # ASP.NET Core entry point (Reviews API, port 5081)
│   │   └── Models/                # Data transfer objects and models
│   └── SpaceRockIT.Web/
│       └── ...                    # The festival website (MVC), port 5080
└── tests/
    └── SpaceRockIT.Reviews.Api.Tests/
        └── ApiTests.cs             # xUnit test suite
```

Both services are started together with `.\run.ps1` (for Windows PowerShell) and `./run.sh` (for macOS/Linux bash) from the repository root.

---

## 🧪 Step 1: Verify the Baseline Application

Let's ensure the baseline service builds, tests pass, and the server runs properly.

### 1. Run Automated Tests
Open your terminal in the repository root and execute:

```bash
dotnet test
```

🔍 **Expected Output:**
```text
Test summary: total: 40; failed: 0; succeeded: 40; skipped: 0; duration: 2,6s
Build succeeded in 6,4s
```

To see if the API is working the above tests contain 3 baseline tests which check the actual behavior of the health endpoint on the API. See `tests/SpaceRockIT.Reviews.Api.Tests/ApiTests.cs` if you want to learn more.
1. `Health_responds` — `GET /health` returns `200 OK`.
2. `Health_leaks_nothing_internal` — the health response never echoes connection strings, file paths, or machine names.
3. `No_review_endpoints_exist_yet` — `/reviews`, `/api/reviews`, and `/sessions/x/reviews` all return `404 Not Found`, pinning down the seam we build next.

> 📌 **Note:** These test counts track only the Reviews API project (`tests/SpaceRockIT.Reviews.Api.Tests/`). The separate `SpaceRockIT.Web` project has its own, larger, pre-existing test suite that isn't part of this workshop's feature build.

### 2. Start Both Services
Start the Reviews API and the website together:

**Windows (PowerShell):**
```powershell
.\run.ps1
```

**macOS/Linux (bash):**
```bash
./run.sh
```

This launches the Reviews API at `http://localhost:5081` and the website at `http://localhost:5080`.

> [!NOTE]
> **In a Codespace or dev container**, use the **macOS/Linux (bash)** commands throughout the
> workshop — the container runs Linux regardless of your own operating system. Both ports are
> forwarded automatically; open the website from the **Ports** panel rather than typing
> `localhost:5080` into your browser.

### 3. Verify Baseline Endpoints
Open a second terminal window and test the health endpoint:

**macOS/Linux (bash):**
```bash
curl http://localhost:5081/health
```

**Windows (PowerShell):**

```powershell
Invoke-WebRequest -Uri "http://localhost:5081/health" -Method Get
```

🔍 **Expected Output:**
```json
{"status":"ok","service":"reviews"}
```

### 4. View a Session Detail Page
Open your browser and navigate to:
`http://localhost:5080/schedule`

You will see the SpaceRockIT session schedule. Select any session to open its detail page.
The detail page contains the placeholder **"Session reviews belong here"**, because **no review
endpoint exists on the Reviews API yet**.

### VS Code chat-session rule

> [!IMPORTANT]
> **Start a new session in Copilot Chat in VS Code** (`Ctrl+Shift+I`, then select **New Chat** or
> `+`) unless a step explicitly says to continue a conversation. A new session prevents earlier
> prompts from affecting the result. Keep the repository open in VS Code when a step requires
> durable context, but still start a new session so the result demonstrates repository
> instructions, MCP, agents, and skills rather than chat history.

### Choose the Copilot Chat mode for the task

> [!IMPORTANT]
> **Select the Copilot Chat mode before sending each prompt.** Use the mode picker in Copilot
> Chat:

| Task | Mode | Use it for |
|---|---|---|
| Understand, inspect, or discuss without changing files | **Ask** | Stage 0 observation, context reviews, MCP smoke tests, and reviewer audits |
| Turn requirements into an implementation approach without editing | **Plan** | Planning prompts and the Stage 4 plan phase |
| Implement changes, edit files, and run tests | **Agent** | Stage 1 implementation and the Stage 4 full-loop implementation |

If a step says “plan only,” use **Plan** mode and do not apply edits. If a step asks Copilot to
implement or test code, use **Agent** mode and review the proposed file changes before accepting
them. Use **Ask** mode for read-only questions and observations.

---

## 💡 What's Missing in This Baseline?

Notice what the baseline is currently lacking:
1. **No Reviews API:** There is no `POST /reviews` or `GET /reviews` endpoint to receive or display attendee reviews.
2. **No Rating Validation:** When we build it, ratings must be constrained to a 1–5 integer scale.
3. **No Privacy/PII Filtering:** Free-text comments must be sanitized so attendee email addresses are never logged in plain text.
4. **No Aggregations:** Festival organizers need average ratings and total counts per workshop session.
5. **No Idempotency:** Duplicate submissions from the same attendee must update previous ratings rather than creating duplicates.

In the next module, we will start by experiencing what happens when we ask Copilot to build this review endpoint without proper guardrails.

> [!IMPORTANT]
> Before moving to Stage 0, stop the applications you started for this setup check. Return to each
> terminal running `run.ps1`, `run.sh`, or `dotnet run` and press **Ctrl+C**. This releases ports
> 5080 and 5081 so the next stage can start the applications cleanly when needed.

---

**Workshop Navigation:**  
[Workshop Roadmap](../README.md) | **Current: Module 00** | [Next Step: Stage 0 — The Undirected Prompt →](01-stage-0-the-undirected-prompt.md)
