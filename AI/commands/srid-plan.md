---
description: Plan a task factually — research first, ask when unsure, keep it simple
---

# srid-plan Command

Respond to the user's prompt using Plan mode, grounded in thorough research rather than assumptions.

## Usage

```
/srid-plan <prompt>
```

## Workflow

### 1. **Enter Plan Mode**

   - Use the `EnterPlanMode` tool to enter planning mode before doing anything else.

### 2. **Research Thoroughly**

   - Before forming any plan, investigate the codebase, docs, and relevant context deeply.
   - Use Explore subagents, Grep, Glob, Read — whatever it takes to ground your understanding in facts.
   - **Parallelize**: When multiple independent things need researching, launch parallel subagents (via the `Agent` tool) to investigate them concurrently. Don't serialize what can be done simultaneously.
   - **Never assume** how something works. Read the code. Check the config. Verify the dependency.
   - If the prompt involves external tools/libraries, use WebSearch/WebFetch to get current info.

### 3. **Clarify Ambiguities**

   - If anything in the user's prompt is ambiguous or could be interpreted multiple ways, **ask immediately** using the `AskUserQuestion` tool.
   - Don't guess intent. Don't pick a default interpretation silently.
   - Be liberal with questions — better to ask 3 questions upfront than to plan around a wrong assumption.

### 4. **Draft a High-Level Plan**

   - Keep the plan at a **high level**: what to do and why, not how to implement each step.
   - No code snippets, no line-by-line changes, no implementation minutiae.
   - Focus on **architecture and approach** — the "shape" of the solution.
   - **Prefer simplicity**: if two approaches exist and one is simpler, choose it. Justify complexity only when necessary.
   - Call out trade-offs and alternatives considered, briefly.
   - **Include an Architecture section** in the plan that covers:
     - What modules/components are affected and how they relate
     - Architectural-level changes, impact, and considerations
     - Any new abstractions, interfaces, or boundaries being introduced or modified
     - Potential ripple effects on the rest of the system

### 5. **Split Non-Trivial Plans into Phases**

   - If the plan is non-trivial, break it into small, sequential phases.
   - **MVP first**: Phase 1 should deliver the minimum viable version. Later phases layer on.
   - Each phase should be small enough for the human to review every line of code.
   - **Each phase must be functionally self-sufficient**: after completing any phase, the system should work end-to-end. Don't split by layer (e.g., client/server/tests separately) — instead split by feature slice so each phase delivers a working whole.
   - One phase = one focused concern. Don't mix unrelated changes.

### 6. **Present Plan for Feedback**

   - Use the `ExitPlanMode` tool to present the plan and solicit user feedback.
   - Iterate based on feedback before exiting plan mode.

### 7. **Execute on Approval**

   - Once the user approves the plan, execute it using the `/srid-do` command.
   - Pass the plan context as the prompt so `/srid-do` has full understanding of what to implement.

## Principles

- **Facts over assumptions**: Every claim in the plan should be backed by something you read or verified.
- **Ask over guess**: When in doubt, ask the user. Silence is not consent to assume.
- **Simple over clever**: Prefer the boring, obvious solution. Complexity must earn its place.
- **High-level over detailed**: The plan is a map, not turn-by-turn directions.
