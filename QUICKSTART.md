# Quickstart

## You have 5 minutes

**Windows (PowerShell):**
```powershell
dotnet test          # 20 green
.\run.ps1            # both apps
```

**macOS/Linux (bash):**
```bash
dotnet test          # 20 green
./run.sh             # both apps
```

Open <http://localhost:5080>, go to **Schedule**, click any session.
That page is where reviews belong — and there are none. That gap is the workshop.

## Requirements

- **.NET 10 SDK** — pinned in `global.json`. Check with `dotnet --list-sdks`.
- Nothing else. The SQLite databases are created and seeded on first run.

## Ports

| | | |
|---|---|---|
| Web | <http://localhost:5080> | the festival site |
| Reviews API | <http://localhost:5081> | separate system; `/health` only, for now |

Fixed on purpose — every prompt, doc and slide refers to them.

## No .NET installed, and not going to install it?

You still get the whole lesson. Read `solutions/` for the expected diff at each stage, and watch
the recorded run. The concepts are stack-independent; the C# is incidental.

## Troubleshooting

| Symptom | Cause |
|---------|-------|
| `SDK not found` | Install .NET 10, or edit `global.json` to your version |
| Site loads, review widget says unavailable | The Reviews API is not running. Expected — the site degrades on purpose |
| Schedule is empty | Delete `site.db` and restart; it re-seeds from `wwwroot/seed/` |
| A test about `DbContext` fails | Someone put data access in a controller. That is the guardrail working |
