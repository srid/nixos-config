---
description: Iteratively simplify & beautify code — research elegance, apply, verify, repeat
argument-hint: "<tech> [iterations=3]"
disable-model-invocation: true
---

# Elegance Command

Iteratively study and apply elegant coding patterns to the codebase for **$0**. Each iteration: understand the code, research what simple & elegant code looks like, apply learnings, verify with CI.

Run for **$1** iterations (default: 3). The value can be a number (e.g., `3`) or a duration (e.g., `2h`).

## Workflow

### 0. **Determine Scope**

   - Before starting, use the `AskUserQuestion` tool to ask: should this operate on the **whole codebase** or only on **changes in the current branch/PR**?
   - If scoped to current branch/PR, use `git diff main...HEAD` (or the appropriate base branch) to identify changed files and limit all subsequent steps to those files only.

### For each iteration (1 to N):

#### 1. **Understand the Codebase**

   - Read through the relevant source files for $0.
   - Note patterns, repetition, unnecessary complexity, non-idiomatic code.

#### 2. **Research Elegant Patterns**

   - Use WebSearch/WebFetch to research what simple, elegant (yet readable!) $0 code looks like.
   - Look for idiomatic patterns, standard simplifications, and community best practices.
   - Focus on: simplicity, readability, removing unnecessary abstraction, leveraging language features.

#### 3. **Apply Learnings**

   - Refactor the codebase based on what you learned.
   - This can include: edits, code reorganization, or even rewrites where simplicity demands it.
   - Prefer fewer lines, clearer intent, and idiomatic style.
   - Don't add unnecessary abstractions — remove them.

#### 4. **Verify**

   - Run local CI to check your edits: `nix run github:juspay/vira -- ci -b`
   - If CI fails, fix the issues before proceeding to the next iteration.

#### 5. **Log Progress**

   - Briefly note what changed in this iteration and why.

### After all iterations:

- Do **not** git commit. Leave all changes in the working directory for the user to review.
- Present a summary of what changed across all iterations.

## Principles

- **Simple over clever**: Elegant code is simple code.
- **Readable over terse**: Brevity is good, but not at the cost of clarity.
- **Well-commented**: Add comments where code isn't self-explanatory. An unsuspecting third-party programmer should be able to understand every non-obvious decision. Don't comment the obvious — comment the *why*.
- **Idiomatic over generic**: Use the language's strengths. Write TypeScript like TypeScript, not like Java.
- **Each iteration builds on the last**: Don't undo previous improvements. Deepen them.
