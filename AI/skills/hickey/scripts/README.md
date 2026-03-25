# complect-detect

Structural simplicity checks for TypeScript projects, based on Rich Hickey's "Simple Made Easy" framework. Detects accidental complexity that tests can't catch.

## Install

```sh
npm install -D ts-morph tsx
```

## Usage

```sh
npx tsx complect-detect.ts --project ./tsconfig.json --threshold 3
```

- `--project` — path to `tsconfig.json` (default: `./tsconfig.json`)
- `--threshold` — minimum mutable ops per function to report (default: 3)

JSON report goes to stdout, human-readable summary to stderr. Exit 0 = clean, exit 1 = findings.

## Checks

### 1. Mutable state density

Counts `let` declarations + reassignments (`=`, `+=`, `++`, etc.) per exported function and async generator. Functions at or above the threshold are flagged. Each mutable binding is a temporal entanglement — correctness depends on *when*, not just *what*.

### 2. Closure over mutable state

Finds inner functions (arrows, function expressions) that reference a `let`-declared variable from an enclosing scope. Reports the variable name and both locations. These closures braid the inner function's behavior with the outer function's timeline.

### 3. Circular event flow

Finds functions that both subscribe to an EventEmitter event (`.on`, `.addEventListener`, `for await...of subscribeAndYield(...)`) AND emit on the same event. Catches feedback loops that no test suite surfaces — the producer/consumer distinction collapses.

### 4. Module concern mixing

Classifies each export as `pure-function`, `async-generator`, `stateful`, or `side-effect`. Reports files mixing categories. A module that exports both pure queries and stateful watchers is braiding two concerns.

### 5. Lifecycle nesting

Finds `new AbortController()`, `fs.watch(`, `setTimeout(`, `setInterval(` inside async generator bodies. Reports generators with 2+ lifecycle constructs — each nested lifecycle is a "when" concern braided into existing control flow.

## CI integration

### GitHub Actions

```yaml
name: Structural Simplicity
on: [pull_request]

jobs:
  complect-detect:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 20
      - run: npm ci
      - name: Run complect-detect
        run: |
          npx tsx path/to/complect-detect.ts \
            --project ./tsconfig.json \
            --threshold 3 \
            > complect-report.json
      - name: Upload report
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: complect-report
          path: complect-report.json
```

The script exits 1 when findings exist, failing the CI step. Adjust `--threshold` to control sensitivity. Start permissive and tighten over time.
