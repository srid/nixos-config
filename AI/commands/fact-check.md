---
description: Fact-check code changes for rigor — catch silent error swallowing, bogus fallbacks, and wishful thinking
---

# Fact-Check Command

Audit code for **correctness and rigor**. This is not a style review — it's a logic review. Find places where the code lies to itself.

## 0. Determine Scope

- Before starting, use the `AskUserQuestion` tool to ask: should this operate on the **whole codebase** or only on **changes in the current branch/PR**?
- If scoped to current branch/PR, use `git diff main...HEAD` (or the appropriate base branch) to identify changed files and limit all subsequent steps to those files only.

## What to flag

### 1. Silent error swallowing
- Bare `try/except: pass`, empty `catch {}`, `|| true` hiding real failures.
- Errors caught and logged but not propagated when callers depend on failure signals.
- `Result`/`Option`/`Maybe` types silently defaulted without justification.

### 2. Inaccurate fallbacks
- Default values that mask misconfiguration (e.g., falling back to `""` or `null` when the real fix is to fail loud).
- "Sensible defaults" that aren't actually sensible for the failure case.
- Fallback paths that silently degrade correctness (e.g., returning stale data without indicating staleness).

### 3. Wishful thinking
- Assumptions about input shape/type without validation at system boundaries.
- Code that "can't fail" but actually can (network, filesystem, permissions).
- Race conditions papered over with comments like "this should be fine".

### 4. Logic errors
- Conditions that are always true/false.
- Off-by-one errors, wrong comparison operators.
- Variables shadowed or unused in a way that changes behavior.

## Workflow

1. Read the diff.
2. For each changed file, read enough surrounding context to understand intent.
3. List every finding with file, line, and a one-line explanation of the risk.
4. For each finding, propose a concrete fix (code snippet or direction).
5. If no issues found, say so — don't invent problems.

## Principles

- **Fail loud over fail silent**: Code should scream when something is wrong, not quietly do the wrong thing.
- **No wishful thinking**: If it can fail, handle the failure explicitly.
- **Fallbacks must be justified**: Every default/fallback needs a reason why that value is correct for the failure case, not just convenient.
- **Precision over coverage**: Better to catch 3 real issues than flag 20 maybes.
