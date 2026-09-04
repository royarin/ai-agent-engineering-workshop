# SpaceRockIT AI Coding Agent Workshop

Welcome to **Taking Control of Your AI Coding Agent(s)**, a hands-on workshop based on the
SpaceRockIT Festival website.

The workshop shows how to move from an informal request to a controlled development workflow.
You will compare different ways of working with an AI coding agent, add useful project context,
connect the agent to sources of truth, and establish reusable ways of working for future tasks.

## What you will learn

By the end of the workshop, you will understand how to:

- turn a vague request into a clear objective and acceptance criteria;
- provide domain and policy context at the right time;
- use GitHub MCP connections to retrieve current project information;
- keep requirements up to date as a ticket changes;
- make important project rules durable across Copilot sessions;
- separate implementation, testing, and review responsibilities;
- verify an agent-produced change with tests and a live application check.

The workshop uses a small review feature as its running example. The feature gives the exercises a
realistic goal, while the main subject is how people and AI agents collaborate safely and
predictably.

## Set up your copy of the repository

Do this before Module 00. It takes a few minutes and shapes the entire workshop.

### 1. Fork the repository with all branches

**Using the GitHub website:**

Select **Fork**. On the fork screen, **clear the "Copy the `main` branch only" checkbox** so that
every branch is copied. This is easy to miss, and the workshop cannot be completed without it — the
working branch you need would simply be absent from your fork.

**Using the GitHub CLI (alternative):**

If you have the [GitHub CLI](https://cli.github.com/) installed and authenticated (`gh auth login`),
one command forks and clones in a single step. The CLI copies every branch by default, so there is no
checkbox to remember:

```bash
gh repo fork royarin/ai-agent-engineering-workshop-working --clone
cd ai-agent-engineering-workshop-working
```

If you use the CLI, you have already cloned — skip straight to step 3.

### 2. Clone your fork

Skip this step if you used the GitHub CLI above.

```bash
git clone https://github.com/<your-username>/ai-agent-engineering-workshop-working.git
cd ai-agent-engineering-workshop-working
```

### 3. Switch to the working branch

```bash
git switch workshop-run
```

You will do all hands-on work here. Confirm with `git branch --show-current`.

> [!TIP]
> If `git switch` reports that the branch does not exist, your fork was created with `main` only.
> Delete the fork on GitHub and repeat step 1, making sure every branch is copied.

### 4. Read the instructions in your browser, not in your editor

Keep the workshop modules open on **github.com**, on the **`main`** branch, in a separate browser
window. Do not open them in the editor you are working in.

### 5. Choose how to run the workshop

You can work locally, or use the prepared container so that nothing has to be installed.

**Option A — Dev container or GitHub Codespace (recommended)**

The repository includes a `.devcontainer/` configuration with the .NET 10 SDK, the GitHub CLI, and
the required VS Code extensions (GitHub Copilot, Copilot Chat, and C#) already set up. Ports 5080
and 5081 are forwarded for you, and the solution is restored when the container is created, so you
can start at Module 00 immediately.

- **GitHub Codespaces:** on your fork, switch to the `workshop-run` branch, then select
  **Code → Codespaces → Create codespace on workshop-run**. Creating it from the correct branch
  matters — a codespace built from `main` would place the workshop instructions in the working tree,
  which is exactly what step 4 avoids.
- **VS Code locally:** install [Docker](https://www.docker.com/products/docker-desktop/) and the
  **Dev Containers** extension, open your clone on the `workshop-run` branch, and choose
  **Reopen in Container**.

The first build takes a few minutes while the SDK and extensions are installed. When it finishes,
run `dotnet --version` in the container terminal to confirm the SDK is available.

**Option B — Local machine**

Install the tools listed under [What you need](#what-you-need) yourself.

> [!NOTE]
> In Codespaces, the forwarded site is served from a generated `*.app.github.dev` address rather
> than `localhost`. Open ports from the **Ports** panel instead of typing the local address. Any
> `curl` command in the modules still works unchanged inside the container terminal, because
> `localhost` resolves correctly there.

### Why the instructions stay out of your working branch

This split is a deliberate part of the workshop, not an administrative detail.

The `main` branch holds the starting code **and** the workshop instructions. The `workshop-run`
branch holds only the starting code. Those instructions describe every exercise in detail: the
prompts to send, the expected output, and the correct solutions.

Copilot reads the repository you have open. If the instruction files sit in your working tree, the
agent can pick them up as context and answer from the workshop's own answer key rather than from
the project. Stage 0 would produce a suspiciously good result, the PII exploit in Stage 2A might
never trigger, and Stage 4 would prove nothing. The failures you are meant to observe would be
quietly papered over.

Controlling exactly what an agent can and cannot see is the core skill this workshop teaches. By
separating the branches, you are applying that principle before the first exercise begins —
and you get to experience firsthand why unmanaged context is a problem worth solving.

## Follow the workshop

Start with [Module 00 — Introduction and setup](Workshop/00-introduction-and-setup.md), then
continue through the modules in order:

| Module | Topic |
|---|---|
| 00 | [Introduction and setup](Workshop/00-introduction-and-setup.md) |
| 01 | [The undirected prompt](Workshop/01-stage-0-the-undirected-prompt.md) |
| 02 | [Objective and acceptance criteria](Workshop/02-stage-1-objective-and-acceptance-criteria.md) |
| 03 | [Context and the PII exploit](Workshop/03-stage-2a-context-and-the-pii-exploit.md) |
| 04 | [MCP-connected context](Workshop/04-stage-2b-mcp-connected-context.md) |
| 05 | [Iterative ticket refinement](Workshop/05-stage-2c-iterative-ticket-refinement.md) |
| 06 | [The durability ladder](Workshop/06-stage-3-the-durability-ladder.md) |
| 07 | [Full-loop redo and verification](Workshop/07-stage-4-full-loop-redo-and-verification.md) |
| 08 | [Wrap-up and challenge exercises](Workshop/08-wrap-up-and-takeaways.md) |

The module files contain the prompts, actions, expected observations, and navigation links for
each part of the workshop.

## What you need

If you use the dev container or a Codespace, everything below except a GitHub Copilot subscription
is already provided — skip to [Follow the workshop](#follow-the-workshop).

- .NET 10 SDK, as specified by `global.json`
- Visual Studio Code
- GitHub Copilot and Copilot Chat
- access to the workshop repository
- a terminal and a REST client such as `curl`

The workshop is written for **Copilot Chat in VS Code**. The modules call out when to start a new
session and which Chat mode to use. GitHub and MCP exercises may also require access to create or
view issues and wiki content in the repository.

## Start the application

From the repository root, use the command for your operating system:

```powershell
dotnet test
.\run.ps1
```

```bash
dotnet test
./run.sh
```

The local applications use these addresses:

| Application | Address |
|---|---|
| Festival website | <http://localhost:5080> |
| Reviews API | <http://localhost:5081> |

For the initial walkthrough, open the website, view the schedule, and select a session. Module 00
explains the starting state and the checks to perform before beginning the first prompt exercise.

## Repository guide

| Location | Contents |
|---|---|
| `Workshop/` | The ordered workshop modules and exercises |
| `src/SpaceRockIT.Web/` | The festival website |
| `src/SpaceRockIT.Reviews.Api/` | The API used by the review exercises |
| `tests/` | Automated verification projects |
| `global.json` | The required .NET SDK version |
| `run.ps1`, `run.sh` | Scripts for starting the local applications |
| `.devcontainer/` | Dev container and Codespaces configuration |

Additional folders such as `docs/`, `.github/`, and `.vscode/` are created as you progress through
the workshop modules and are not part of the initial setup.

## Workshop timing

Working through all modules hands-on, at your own pace, typically takes about 120–135 minutes.
If you're following an abbreviated or guided version of the workshop (for example, in a live
session with a presenter), some of the longer activities may be demonstrated rather than
performed individually, which can fit the workshop into a shorter time slot.

## Contributing

If you spot an issue, have a suggestion, or want to propose an improvement to the workshop,
please [open an issue](../../issues) in this repository.

## Attribution

The website content and visuals are reproduced from the
[SpaceRockIT Festival website](https://www.spacerockitfestival.nl/) for this educational workshop.
No real tickets are sold and no attendee data is real.
