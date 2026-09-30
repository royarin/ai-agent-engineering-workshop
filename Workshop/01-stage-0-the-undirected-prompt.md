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

## 📝 Step 3: The Opposite Failure — Too Many Rules at Once

The obvious reaction to Step 2 is *"fine, I'll be more specific"*. So let's be maximally
specific and see what that costs.

> [!IMPORTANT]
> **Start another new session** in **Ask** mode. A fresh context matters here — this step is
> measuring what a single request can carry.

```text
Add a review endpoint to our festival API. Follow all of these rules:

1. Use ASP.NET Core controllers, not minimal APIs.
2. Keep all persistence in memory. Do not add a database engine of any kind.
3. Ratings are integers from 1 to 5 inclusive; anything else returns 400.
4. WorkshopId and AttendeeId are required; a missing one returns 400.
5. Comments are optional, maximum 500 characters.
6. Reject a comment that is whitespace only with 400.
7. Redact any email address in a comment to [redacted-email] before it is stored.
8. Never write a raw attendee comment to the logs.
9. Log every accepted review at Information level using structured placeholders.
10. A resubmission from the same AttendeeId for the same WorkshopId updates the existing
    rating instead of creating a second one.
11. Expose GET /reviews?workshopId= returning average rating, total count and comments.
12. Add one xUnit test per rule above, using synthetic email fixtures only.

Do not edit any files. Just show me the implementation you would write.
```

**Now count.** Go through the twelve rules against the response and tick off the ones that
are actually honoured.

**What to expect:** typically eight or nine. Rules 1 to 4 and 11 almost always survive — they
are structural and stated positively. The ones that tend to disappear are the negatives
(rule 8, "never write a raw comment") and the ones needing a second pass over code the agent
has already written (rule 10, idempotency; rule 12, a test per rule).

The exact set varies between runs, and **that variation is the finding.** Run it twice if you
have time.

> [!WARNING]
> Nothing in the response tells you a rule was dropped. There is no error, no "I could not
> apply rule 10", no confidence score. The rules that fall out are precisely the ones you
> would never think to check, because you already wrote them down.

### Why this happens

Research on instruction following shows adherence and accuracy degrading once a single task
carries roughly **7 to 10 instructions**, and it is complexity and count that bite, not the
size of the context window. A larger window does not raise this ceiling.

The same body of work finds that multi-turn performance drops substantially against
single-turn on identical tasks, and that the loss is mostly **unreliability** rather than
lost capability — models make an early assumption, commit to it, and do not recover.

> [!NOTE]
> If the agent honours all twelve on your run, that is worth seeing too. You had no way to
> know in advance which run you would get, and no signal afterwards telling you which rules
> were applied. Reliability you cannot verify is not reliability.

---

## 🧠 Key Takeaways from Stage 0

> **Key Takeaway:** *"The model isn't the problem — the objective was unconstrained."*

When you provide a vague prompt, LLMs act as **noise machines**: they generate plausible-sounding generic software patterns (like EF Core and SQLite) rather than the precise, lightweight solution your project requires.

And piling every rule into one message does not fix it — it just moves the failure somewhere
harder to see. Step 2 fails loudly, with a database engine you did not ask for. Step 3 fails
silently, with four rules quietly missing.

The way out is neither a vaguer nor a longer prompt. It is **fewer instructions per task**,
carried by files rather than messages, and **applied in more than one pass**. That is what
the rest of this workshop builds.

In the next module, we start with a formal **Product Objective and Acceptance Criteria**.

---

**Workshop Navigation:**  
[← Previous Step: Module 00 — Setup](00-introduction-and-setup.md) | **Current: Module 01 (Stage 0)** | [Next Step: Stage 1 — Objective & AC →](02-stage-1-objective-and-acceptance-criteria.md)
