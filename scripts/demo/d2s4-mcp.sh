#!/usr/bin/env bash
# Demo 2 Step 4 - two hosted read-only GitHub MCP servers.
#
# Writes the file(s) below, overwriting any earlier copy, so the step is repeatable.
# Content is identical to Module 06 (Stage 3), Level 3, which is where it is explained.
#
# SHORTCUT WARNING: if you are working through the workshop, write these by hand the
# first time. Understanding what is in them is the exercise.

set -euo pipefail
cd "$(dirname "$0")/../.."

mkdir -p ".vscode"

cat > ".vscode/mcp.json" <<'___DEMO_CONTENT___'
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
___DEMO_CONTENT___
echo "wrote:   .vscode/mcp.json"

echo
cat <<'NOTE'
Shortcut used. This wrote files the workshop has you write yourself in
  Module 06 (Stage 3), Level 3

If you are following the workshop, open that module and read the content you just
skipped. Knowing what is in these files, and why each line is there, is the whole
point of the exercise - having the files is not.
NOTE
