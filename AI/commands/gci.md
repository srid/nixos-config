---
description: Stage, commit, and push changes
subtask: true
---

# GCI Command

Stage all changes, generate a commit message, commit, and push after user approval.

## Usage

```
/gci           # Normal mode - prompts for approval, then commits and pushes
/gci yes       # Auto mode - commits and pushes without prompting
```

## Workflow

1. **Stage All Changes**
   - Run `git add -A` to stage all changes (new files, modifications, deletions)

2. **Show Status and Generate Commit Message**
   - Run `git status` to show what will be committed
   - Analyze the staged changes using `git diff --cached`
   - Generate a concise, descriptive commit message that:
     - Summarizes WHAT changed in a single line (50-72 characters)
     - If needed, adds a brief description of WHY in the body
     - Uses imperative mood (e.g., "Add feature" not "Added feature")
     - Follows conventional commit style if appropriate

3. **Present to User for Approval** (skip if 'yes' argument provided)
   - Display the generated commit message
   - Show the `git status` output of what will be committed
   - **Use the question tool** to ask for approval with options:
     - "Commit" - proceed with the commit
     - "Edit message" - user wants to modify the message (use custom option)
     - "Cancel" - abort the commit
   - **If 'yes' argument was provided**: Skip this step entirely and proceed directly to commit

4. **Commit Changes**
   - Once approved (or if 'yes' argument provided), run `git commit -m "MESSAGE"` (or `git commit -F -` with multi-line message)
   - Report the commit hash and summary to the user

5. **Push Changes**
   - After successful commit, run `git push` to push to remote
   - Report push status to user

## Important Constraints

- **NEVER auto-commit**: ALWAYS ask user for approval before running `git commit` - NEVER commit without explicit user confirmation (UNLESS the 'yes' argument is provided)
- **Single commit only**: This command creates exactly ONE new commit on top of the current branch
- **No history rewriting**: Never use `--amend`, `--fixup`, rebase, or reset operations
- **No other mutations**: The only git operations are `git commit` and `git push`

## Requirements

- Must be in a git repository
- There must be changes to commit (either unstaged or already staged)

## Example Output Format

### Normal Mode (`/gci`)
```markdown
Staged changes:
M  src/app.ts
A  src/utils/helper.ts
D  old-file.js

Proposed commit message:
Add helper utilities and refactor app

Removes deprecated old-file.js and introduces new helper functions
for data validation. Updates app.ts to use the new utilities.

[Uses question tool with options: Commit, Edit message, Cancel]
```

### Auto Mode (`/gci yes`)
```markdown
Staged changes:
M  src/app.ts
A  src/utils/helper.ts
D  old-file.js

Generated commit message:
Add helper utilities and refactor app

Removes deprecated old-file.js and introduces new helper functions
for data validation. Updates app.ts to use the new utilities.

Creating commit...
[master abc1234] Add helper utilities and refactor app

Pushing to remote...
Done. Pushed to origin/master.
```

## Notes

- Use the question tool for approval in normal mode - this provides a structured UI for the user
- If user selects "Edit message", use the question tool's custom option to let them type a new message
- If there are already staged changes, ask the user if they want to add unstaged changes too
- If there are no changes at all, inform the user and exit
- Keep the commit message clear and focused on the user-facing impact
- The default branch of the commit message should be concise (50-72 chars)
