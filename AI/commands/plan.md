# Plan Command

Create a detailed implementation plan for a feature, fix, or change. The plan is saved to `.plan/<slug>.md` for iterative refinement through review cycles.

## Usage

```
/plan <description>      # Create plan from description
/plan <github-issue-url> # Create plan from GitHub issue
```

## Workflow

### 1. **Create Initial Plan**

   **IMPORTANT: This command ONLY creates the plan file. DO NOT implement anything. DO NOT write code. ONLY create the plan document.**

   - Parse the input (description or GitHub issue URL)
   - If GitHub issue URL, fetch the issue content using `gh issue view <number>`
   - Generate a suitable slug from the main topic (lowercase, hyphenated)
   - Create `.plan/` directory if it doesn't exist
   - Write plan to `.plan/<slug>.md` with:
     - **Overview**: High-level description of what needs to be done and why
     - **Phases**: Determine number of phases based on complexity:
       - Each phase must be self-contained and easily implementable by Claude
       - Each phase must be easily reviewable by user before next phase
       - If task is trivial, use single phase or omit phases section entirely
       - For each phase include:
         - Phase number and name
         - Specific tasks/steps within that phase
         - Expected outcomes
         - Any dependencies or prerequisites
   - **STOP after creating the plan file. Tell user the plan is ready for review.**

### 2. **Plan Review Cycle**
   - User reviews the plan file
   - User adds comments prefixed with `ME: ` right below the specific item/section they're commenting on
   - User asks Claude to "review comments" or "address comments"
   - Claude:
     - Reads the plan file
     - Reviews all `ME: ` comments
     - Adjusts the plan based on feedback
     - **Removes the `ME: ` comments** that have been addressed
     - Writes the updated plan back to the file
   - Repeat until user is satisfied

### 3. **Implementation**
   - User typically asks to implement one phase at a time (e.g., "implement phase 1")
   - Claude implements that specific phase
   - User reviews the implementation
   - User asks for next phase when ready
   - Repeat until all phases complete
   - Can reference the plan file throughout implementation

## Plan File Format

```markdown
# Plan: <Title>

## Overview

<High-level description of the change, including context and motivation>

## Phases

### Phase 1: <Name>

- Task or step description
- Another task
- Expected outcome: <what this phase achieves>

### Phase 2: <Name>

- Task or step description
- Another task
- Expected outcome: <what this phase achieves>

### Phase 3: <Name>

...

## Notes

- Any additional considerations
- Risks or gotchas
- References or links
```

## Example Flow

```markdown
User: /plan Add dark mode support to the application

Claude: Created plan at .plan/dark-mode-support.md

User: [Reviews file, adds comments]
ME: Should we also handle system preference detection?
ME: What about persisting user choice?

User: Review the comments

Claude: [Updates plan to address both comments, removes the ME: lines]
Updated plan at .plan/dark-mode-support.md

User: Looks good, implement it

Claude: [Proceeds with Phase 1 implementation...]
```

## Requirements

- If input is a GitHub issue URL, `gh` CLI must be available (use `nix run nixpkgs#gh` if not installed)
- Write permission in the repository root for creating `.plan/` directory

## Notes

- Plan files are iterative - expect multiple review cycles
- Number of phases depends on task complexity - trivial tasks may have one or no phases
- Keep phases sequential and logical
- Each phase should be self-contained, easily implementable, and easily reviewable
- Each phase should have clear entry and exit criteria
- Remove `ME: ` comments only after addressing them in the plan
- The plan file is the source of truth for implementation
