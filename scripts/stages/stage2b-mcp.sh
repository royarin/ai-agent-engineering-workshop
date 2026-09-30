#!/usr/bin/env bash
# Stage 2B - two hosted read-only GitHub MCP servers.
#
# Content is identical to Module 04 (Stage 2B), Step 2 - recommitted as Level 3 in Module 06, which is where it is explained.
#
# SHORTCUT WARNING: if you are working through the workshop, write these by hand
# the first time. Understanding what is in them is the exercise.

set -euo pipefail
cd "$(dirname "$0")/../.."

mkdir -p ".vscode"

cat > ".vscode/mcp.json" <<'___WORKSHOP_CONTENT___'
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
___WORKSHOP_CONTENT___
echo "wrote:   .vscode/mcp.json"

echo
cat <<'NOTE'
Shortcut used. This wrote content the workshop has you write yourself in
  Module 04 (Stage 2B), Step 2 - recommitted as Level 3 in Module 06

If you are following the workshop, open that module and read what you just
skipped. Knowing what is in these files, and why each line is there, is the
point of the exercise - having the files is not.
NOTE
