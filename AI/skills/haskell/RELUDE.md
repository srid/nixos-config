# Relude Best Practices

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
