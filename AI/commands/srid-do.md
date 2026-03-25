---
description: Execute a task end-to-end — implement, PR, CI loop, elegance, ship
argument-hint: "<github-issue-url | prompt>"
---

# srid-do Command

Take a GitHub issue, prompt, or task description and execute it top-to-bottom: implement, open a draft PR, pass CI, refine with elegance, and push.

**Do NOT use `AskUserQuestion` at any point.** Make sensible default choices and keep moving. If a sub-command (like `/elegance`) would normally ask a question, provide the sensible default answer automatically.

## Usage

```
/srid-do <github-issue-url or prompt>
```

## Workflow

### 1. **Understand the Task**

   - If given a GitHub issue URL, fetch it with `gh issue view` to get full context.
   - Research the codebase thoroughly before writing code. Use Explore subagents, Grep, Glob, Read.
   - **Never assume** how something works. Read the code. Check the config.
   - If the prompt involves external tools/libraries, use WebSearch/WebFetch to get current info.
   - If anything is ambiguous, make a sensible default choice and proceed.

### 2. **Simplicity Check (Hickey)** *(skip if invoked from `/srid-plan`)*

   - Before implementing, evaluate your approach using the `hickey` skill.
   - Ask: does this approach complect independent concerns? Are there simpler structural alternatives?
   - Flag any accidental complexity — entanglement from the approach, not the problem.
   - If introducing new abstractions, verify each earns its place. Prefer composing simple parts over braiding concerns.
   - Revise your approach to eliminate any identified complecting before proceeding.

### 3. **Implement**

   - Create a new branch from the current branch (name it descriptively).
   - Implement the changes. Prefer simplicity. Keep it focused on what was asked.
   - If the project has e2e tests, add or update tests for new features or bugs being fixed.
   - Commit with a clear message describing what was done. Each commit must be a NEW commit (never amend).

### 4. **Open Draft PR**

   - Push the branch and open a **draft** pull request using `gh pr create --draft`.
   - **MANDATORY**: Load the `github-pr` skill (via `Skill` tool) BEFORE writing the PR title/body. Follow it exactly — paragraph-based descriptions, no bullet-list dumps.

### 5. **CI Loop**

   - Run `just ci`.
   - If CI fails:
     1. Read the failure output carefully.
     2. Fix the issue.
     3. Create a NEW commit (never amend) with a message describing the fix.
     4. Push.
     5. Run `just ci` again.
   - Repeat until CI passes. Max 5 attempts — if still failing after 5, stop and ask the user.

### 6. **Elegance Pass**

   - Run the `/elegance` (*NOT* `/simplify`) command targeting the relevant technology, for **3 iterations**.
   - When `/elegance` asks about scope (via `AskUserQuestion`), answer: **changes in the current branch/PR only**.
   - After elegance completes, create a NEW commit for the elegance improvements.

### 7. **Final CI**

   - Push all elegance changes.
   - Run `just ci` again.
   - If it fails, enter the CI fix loop from step 5 again.

### 8. **Update PR Description**

   - After all changes (elegance, CI fixes), re-check the PR title/body.
   - If scope changed, update via `gh pr edit` per the `github-pr` skill.

### 9. **Done**

   - Report the PR URL and a brief summary of what was done.

## Principles

- **Every commit is NEW**: Never amend. Never rebase. Never force-push.
- **CI must pass**: Don't move to the next phase until CI is green.
- **Simple over clever**: Do the boring obvious thing.
- **Autonomous**: Never ask. Pick sensible defaults and keep moving.
