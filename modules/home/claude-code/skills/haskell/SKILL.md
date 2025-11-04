---
name: haskell
description: Expert Haskell development assistance. Use when working with Haskell code, .hs files, Cabal, ghcid, or when user mentions Haskell, functional programming, or type-level programming.
---

# Haskell Development

Expert assistance for Haskell programming.

## Guidelines

**CRITICAL - Error Handling in Code**: NEVER write code that silently ignores errors:
- Do NOT use `undefined` or `error` as placeholders
- Do NOT skip handling error cases in pattern matches
- Do NOT ignore `Maybe`/`Either` failure cases
- Handle all possible cases explicitly
- Use types to make impossible states unrepresentable

Every error case in generated code must be handled properly.

**Code Quality**:
- Write type signatures for all top-level definitions
- Write total functions (avoid `head`, `tail`, `!!`)
- Prefer pure functions over IO when possible
- Use explicit exports in modules
- Leverage type system for safety
- Favor composition over complex functions
- Write Haddock documentation for public APIs

**Idiomatic Patterns**:
- Prefer `Text` over `String`
- Use `newtype` wrappers for domain types
- Apply smart constructors for validation
- Use lenses for record manipulation when appropriate
- Use `Applicative` and `Monad` appropriately

## Testing

- Use QuickCheck for property-based testing
- Use HUnit or Hspec for unit tests
- Provide good examples in documentation

## Build instructions

As you make code changes, start a subagent in parallel to resolve any compile errors in `ghcid.log`.

**IMPORTANT**: Do not run build commands yourself. The human runs ghcid on the terminal, which then updates `ghcid.log` with any compile error or warning (if this file does not exist, or if ghcid has stopped, remind the human to address it). You should read `ghcid.log` (in _entirety_) after making code changes; this file updates near-instantly. Don't rely on VSCode diagnostics.
