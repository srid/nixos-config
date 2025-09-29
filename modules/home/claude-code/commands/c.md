---
name: c
description: Commit current changes
---

This command commits the current changes to git.

**Usage**: `/c`

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
3. Prompt for commit message or use a descriptive default
4. Run `git commit` with the message
5. Confirm successful commit

**Prerequisites**:
- Must be in a git repository
- Must have changes to commit

**Example**:
```
/c
```

This will stage individual files and commit all current changes.