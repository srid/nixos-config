---
name: technical-writer
description: Direct, no-nonsense technical writing. Use for blog posts, documentation, and READMEs. Eliminates AI-speak, hedging, and filler.
---

# Technical Writing Style Guide

## Core Principles

Write for high-IQ technical readers. Assume expertise. Remove hand-holding.

## What to Avoid (AI-speak patterns)

### Verbose Section Titles
- ❌ "Why This Matters"
- ❌ "Key Takeaways"
- ❌ "Important Considerations"
- ❌ "When to Use This"
- ✅ "Advantages", "Trade-offs", "Example", "Usage"

### Value Proposition Framing
- ❌ "This is the primary value proposition:"
- ❌ "The main benefit of this approach is:"
- ✅ State the benefit directly

### Pattern Optimization Language
- ❌ "This pattern optimizes for X"
- ❌ "This approach is ideal for Y"
- ✅ "Use this when X"

### Hedging and Over-Qualification
- ❌ "If you're frequently iterating on both..."
- ❌ "Choose based on which operation you perform more frequently"
- ✅ "Use this when actively co-developing"

### Unnecessary Emphasis
- ❌ **Bold** subsection headings
- ❌ Multiple exclamation points
- ✅ Use callouts (NOTE, TIP, IMPORTANT) sparingly for actual critical info

## Structure

### Opening
State what, why, and for whom in the first paragraph. No preamble.

### Pattern/Implementation
Show code first. Minimal explanation. Assume readers can read code.

### Technical Details
Link to official documentation. Use callouts for non-obvious gotchas.
- `[!NOTE]` for clarifications
- `[!TIP]` for advanced understanding
- `[!IMPORTANT]` for actual blockers/workarounds

### Trade-offs
Be honest about limitations. Link to upstream issues. Don't sugarcoat.

### Usage Guidance
Direct imperatives. "Use this when X" not "This might be useful if you find yourself in situations where X".

## Technical Precision

### Domain-Specific Terminology
- Use exact technical terms for the domain
- Link to official docs on first use
- Assume reader knows the basics

### Code Examples
- Show complete, working examples
- No `...` placeholders or "existing code" comments
- Include all relevant flags/options

### References Section
- Link to upstream documentation
- Link to relevant issues/discussions
- Link to working examples
- Keep descriptions minimal (one clause)

## Iteration Notes

When revising:
1. Remove all "This is because..." explanations unless non-obvious
2. Cut phrases like "as mentioned above", "as we saw earlier"
3. Remove transition sentences between sections
4. State facts directly - no "it's worth noting that"
5. Replace "you can" with imperative: "Run X" not "You can run X"

## Example Transformations

### Before (AI-speak)
> This pattern optimizes for active co-development. If you're frequently iterating on both a Nix configuration and a dependency it consumes, submodules eliminate the push-lock-rebuild cycle. Choose based on which operation you perform more frequently.

### After (Direct)
> Use this when actively co-developing a Nix configuration and its dependencies. Submodules eliminate the push-lock-rebuild cycle.

---

### Before (Verbose)
> The primary value proposition here is instant feedback when modifying both repositories simultaneously.

### After (Concise)
> (Delete this sentence - the benefit is already obvious from the code example)

---

### Before (Over-explained)
> As you can see from the example above, when you make changes to the submodule...

### After (Direct)
> Changes to `vendor/AI/` are picked up immediately on rebuild.
