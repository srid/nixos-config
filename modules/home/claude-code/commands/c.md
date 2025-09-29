---
name: c
description: Commit current changes
---

This command commits the current changes to git.

**Usage**: `/c [summary]`

**Parameters**:
- `summary` (optional): A brief description of the changes being committed. This will be used alongside the git diff analysis to generate a more accurate commit message.

**What it does**:
1. Runs a single `git add` command with all modified/new files as arguments (never on directories or '.')
2. Runs `git commit` to commit the staged changes
3. Never runs `git push` automatically

**Important constraints**:
- Claude should NEVER automatically commit changes unless this command is explicitly invoked
- Only adds individual files, never uses `git add .` or `git add <directory>`
- Use a single `git add` command with all files as arguments instead of multiple separate commands
- Never automatically pushes changes
- Never rewrites git history (no rebase, amend, reset --hard, etc.)
- Only commits when user explicitly runs this command

**Workflow**:
1. Check git status to identify modified and new files
2. Add all files in a single command using `git add <file1> <file2> <file3>...`
3. Analyze git diff to understand the changes made
4. Generate a meaningful commit message based on the actual changes
5. Run `git commit` with the generated message
6. Confirm successful commit

**Commit Message Generation**:
- Analyze the git diff to understand what changed
- If a user summary is provided, use it as context to better understand the intent behind the changes
- Create a concise, descriptive commit message that explains the purpose of the changes
- Focus on the "what" and "why" rather than generic descriptions
- Prefix the commit message with component (and subcomponent if it exists, separated by /), e.g., `claude-code/command/c: Include component path in commit message`
- Examples of good vs bad messages:
  - Good: "tmux: Add configuration with custom key bindings"
  - Bad: "Update home configuration"
  - Good: "ssh: Fix broken agent forwarding in development environment"
  - Bad: "Update configuration files"
  - Good: "claude-code/command/c: Add commit message generation guidelines"

**Prerequisites**:
- Must be in a git repository
- Must have changes to commit

**Examples**:
```
/c
```
This will stage individual files and commit all current changes with an auto-generated commit message.

```
/c "Fix authentication bug"
```
This will commit changes with a message based on both the git diff analysis and the provided summary about fixing an authentication bug.