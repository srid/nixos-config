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
- Write total functions (avoid `head`, `tail`)
- Prefer pure functions over IO when possible
- Use explicit exports in modules
- Leverage type system for safety
- Favor composition over complex functions
- Write Haddock documentation for public APIs

**Idiomatic Patterns**:
- Prefer `Text` over `String`
- Use `newtype` wrappers for domain types
- Apply smart constructors for validation
- Use RecordDotSyntax (`value.field`) instead of manually unpacking data types
- Use lenses for record manipulation when appropriate
- Use `Applicative` and `Monad` appropriately
- Avoid trivial `let` bindings when inlining keeps code simple and readable

## HLint

**IMPORTANT**: Always check if the project has a `.hlint.yaml` file. If it does:
1. Read the `.hlint.yaml` file to understand project-specific style rules
2. Follow all recommendations in that file when writing code
3. After making code changes, run `hlint` to ensure no warnings

## Relude Best Practices

When using relude prelude, follow these HLint recommendations (from https://github.com/kowainik/relude/blob/main/.hlint.yaml):

**Basic Idioms**:
- Use `pass` instead of `pure ()` or `return ()`
- Use `one` instead of `(: [])`, `(:| [])`, or singleton functions
- Use `<<$>>` for double fmap: `f <<$>> x` instead of `fmap (fmap f) x`
- Use `??` (flap) operator: `ff ?? x` instead of `fmap ($ x) ff`

**File I/O**:
- `readFileText`, `writeFileText`, `appendFileText` for Text files
- `readFileLText`, `writeFileLText`, `appendFileLText` for lazy Text
- `readFileBS`, `writeFileBS`, `appendFileBS` for ByteString
- `readFileLBS`, `writeFileLBS`, `appendFileLBS` for lazy ByteString

**Console Output**:
- `putText`, `putTextLn` for Text
- `putLText`, `putLTextLn` for lazy Text
- `putBS`, `putBSLn` for ByteString
- `putLBS`, `putLBSLn` for lazy ByteString

**Maybe/Either Helpers**:
- `whenJust m f` instead of `maybe pass f m`
- `whenJustM m f` for monadic versions
- `whenNothing_ m x` / `whenNothingM_ m x` for Nothing cases
- `whenLeft_ m f`, `whenRight_ m f` for Either
- `whenLeftM_ m f`, `whenRightM_ m f` for monadic Either
- `leftToMaybe`, `rightToMaybe` for conversions
- `maybeToRight l`, `maybeToLeft r` for conversions
- `isLeft`, `isRight` instead of `either (const True/False) (const False/True)`

**List Operations**:
- Use `ordNub` instead of `nub` (O(n log n) vs O(n²))
- Use `sortNub` instead of `Data.Set.toList . Data.Set.fromList`
- Use `sortWith f` instead of `sortBy (comparing f)` for simple cases
- Use `viaNonEmpty f x` instead of `fmap f (nonEmpty x)`
- Use `asumMap f xs` instead of `asum (map f xs)`
- Use `toList` instead of `foldr (:) []`

**Monadic Operations**:
- `andM s` instead of `and <$> sequence s`
- `orM s` instead of `or <$> sequence s`
- `allM f s` instead of `and <$> mapM f s`
- `anyM f s` instead of `or <$> mapM f s`
- `guardM f` instead of `f >>= guard`
- `infinitely` instead of `forever` (better typed)
- `unlessM (not <$> x)` → use `whenM x` instead
- `whenM (not <$> x)` → use `unlessM x` instead

**State/Reader Operations**:
- `usingReaderT` instead of `flip runReaderT`
- `usingStateT` instead of `flip runStateT`
- `evaluatingStateT s st` instead of `fst <$> usingStateT s st`
- `executingStateT s st` instead of `snd <$> usingStateT s st`

**Transformer Lifting**:
- `hoistMaybe m` instead of `MaybeT (pure m)`
- `hoistEither m` instead of `ExceptT (pure m)`

**List Pattern Matching**:
- `whenNotNull m f` for `case m of [] -> pass; (x:xs) -> f (x :| xs)`
- `whenNotNullM m f` for monadic version

**Text/ByteString Conversions**:
- Use relude's `toText`, `toString`, `toLText` instead of pack/unpack
- Use relude's `encodeUtf8`, `decodeUtf8` for UTF-8 encoding
- `fromStrict`, `toStrict` for lazy/strict conversions

## Testing

- Use QuickCheck for property-based testing
- Use HUnit or Hspec for unit tests
- Provide good examples in documentation

## Build instructions

As you make code changes, start a subagent in parallel to resolve any compile errors in `ghcid.log`.

**IMPORTANT**: Do not run build commands yourself. The human runs ghcid on the terminal, which then updates `ghcid.log` with any compile error or warning (if this file does not exist, or if ghcid has stopped, remind the human to address it). You should read `ghcid.log` (in _entirety_) after making code changes; this file updates near-instantly. Don't rely on VSCode diagnostics.

**Adding/Deleting modules**: When a new `.hs` file is added or deleted, the `.cabal` file must be updated accordingly. However, if `package.yaml` exists in the project, run `hpack` instead to regenerate the `.cabal` file with the updated module list. This will trigger `ghcid` to restart automatically.

**HLint warnings**: Once all code changes are made and `ghcid.log` shows success, check if the project has a `.hlint.yaml` file. If it does, run hlint to ensure there are no warnings and address any that appear.
