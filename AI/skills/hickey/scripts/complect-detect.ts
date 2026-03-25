#!/usr/bin/env npx tsx
/**
 * complect-detect — structural simplicity checks for TypeScript projects.
 *
 * Implements five checks from the Hickey "Simple Made Easy" framework:
 *   1. Mutable state density per function
 *   2. Closure-over-mutable-state
 *   3. Circular event flow
 *   4. Module concern mixing
 *   5. Lifecycle nesting in async generators
 *
 * Usage: npx tsx complect-detect.ts [--project ./tsconfig.json] [--threshold 3]
 */

import { Project, SyntaxKind, Node, SourceFile, ts } from "ts-morph";
import { parseArgs } from "node:util";

// ---------------------------------------------------------------------------
// CLI
// ---------------------------------------------------------------------------

const { values: args } = parseArgs({
  options: {
    project: { type: "string", default: "./tsconfig.json" },
    threshold: { type: "string", default: "3" },
  },
  strict: true,
});

const tsconfigPath = args.project!;
const mutableThreshold = parseInt(args.threshold!, 10);

// ---------------------------------------------------------------------------
// Types
// ---------------------------------------------------------------------------

interface MutableStateFinding {
  file: string;
  function: string;
  line: number;
  letCount: number;
  reassignmentCount: number;
  total: number;
}

interface ClosureMutableFinding {
  file: string;
  outerFunction: string;
  innerFunction: string;
  variable: string;
  outerLine: number;
  innerLine: number;
}

interface CircularEventFinding {
  file: string;
  function: string;
  line: number;
  event: string;
}

type ExportKind = "pure-function" | "async-generator" | "stateful" | "side-effect";

interface ModuleConcernFinding {
  file: string;
  kinds: ExportKind[];
  exports: Array<{ name: string; kind: ExportKind }>;
}

interface LifecycleNestingFinding {
  file: string;
  generator: string;
  line: number;
  constructs: string[];
  count: number;
}

interface Report {
  mutableStateDensity: MutableStateFinding[];
  closureOverMutable: ClosureMutableFinding[];
  circularEventFlow: CircularEventFinding[];
  moduleConcernMixing: ModuleConcernFinding[];
  lifecycleNesting: LifecycleNestingFinding[];
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

const filePath = (sf: SourceFile): string => sf.getFilePath();

const isFunctionLike = (node: Node): boolean =>
  Node.isFunctionDeclaration(node) ||
  Node.isFunctionExpression(node) ||
  Node.isArrowFunction(node) ||
  Node.isMethodDeclaration(node);

const functionName = (node: Node): string => {
  if (Node.isFunctionDeclaration(node) || Node.isMethodDeclaration(node)) {
    return (node as any).getName?.() ?? "<anonymous>";
  }
  // arrow / expression assigned to a variable
  const parent = node.getParent();
  if (parent && Node.isVariableDeclaration(parent)) {
    return parent.getName();
  }
  return "<anonymous>";
};

const isAsyncGenerator = (node: Node): boolean => {
  if (
    Node.isFunctionDeclaration(node) ||
    Node.isFunctionExpression(node) ||
    Node.isMethodDeclaration(node)
  ) {
    const decl = node as any;
    return !!decl.isAsync?.() && !!decl.isGenerator?.();
  }
  return false;
};

// ---------------------------------------------------------------------------
// Check 1: Mutable state density
// ---------------------------------------------------------------------------

const countMutableState = (fn: Node): { lets: number; reassigns: number } => {
  let lets = 0;
  let reassigns = 0;

  fn.forEachDescendant((child) => {
    // Skip nested function-like nodes (they get their own count)
    if (isFunctionLike(child) && child !== fn) return;

    if (Node.isVariableDeclaration(child)) {
      const stmt = child.getParent();
      if (stmt && Node.isVariableDeclarationList(stmt)) {
        if (stmt.getDeclarationKind() === ts.NodeFlags.None) {
          // "let" shows up as None in some ts-morph versions; check text
        }
        const kindText = stmt.getFlags();
        // More reliable: check the keyword directly
        const text = stmt.getText();
        if (text.startsWith("let ")) lets++;
      }
    }

    // Count binary assignments that aren't initializers
    if (Node.isBinaryExpression(child)) {
      const op = child.getOperatorToken().getKind();
      if (
        op === SyntaxKind.EqualsToken ||
        op === SyntaxKind.PlusEqualsToken ||
        op === SyntaxKind.MinusEqualsToken
      ) {
        reassigns++;
      }
    }

    // Prefix/postfix increment/decrement
    if (
      Node.isPrefixUnaryExpression(child) ||
      Node.isPostfixUnaryExpression(child)
    ) {
      const op = (child as any).getOperatorToken?.() ?? child.getChildAtIndex(0);
      const opKind = child.compilerNode.operator;
      if (
        opKind === ts.SyntaxKind.PlusPlusToken ||
        opKind === ts.SyntaxKind.MinusMinusToken
      ) {
        reassigns++;
      }
    }
  });

  return { lets, reassigns };
};

const checkMutableStateDensity = (
  sourceFiles: SourceFile[],
  threshold: number,
): MutableStateFinding[] =>
  sourceFiles.flatMap((sf) => {
    const findings: MutableStateFinding[] = [];
    sf.forEachDescendant((node) => {
      if (!isFunctionLike(node)) return;
      // Only check exported functions and async generators at top level
      const isExported =
        Node.isFunctionDeclaration(node) && node.isExported();
      const isTopLevelVar =
        node.getParent() &&
        Node.isVariableDeclaration(node.getParent()!) &&
        (node.getParent()!.getParent()?.getParent() as any)?.isExported?.();

      if (!isExported && !isTopLevelVar && !isAsyncGenerator(node)) return;

      const { lets, reassigns } = countMutableState(node);
      const total = lets + reassigns;
      if (total >= threshold) {
        findings.push({
          file: filePath(sf),
          function: functionName(node),
          line: node.getStartLineNumber(),
          letCount: lets,
          reassignmentCount: reassigns,
          total,
        });
      }
    });
    return findings;
  });

// ---------------------------------------------------------------------------
// Check 2: Closure over mutable state
// ---------------------------------------------------------------------------

const checkClosureOverMutable = (
  sourceFiles: SourceFile[],
): ClosureMutableFinding[] =>
  sourceFiles.flatMap((sf) => {
    const findings: ClosureMutableFinding[] = [];

    sf.forEachDescendant((outer) => {
      if (!isFunctionLike(outer)) return;

      // Collect let-declared variables in this scope
      const letVars = new Map<string, number>();
      outer.forEachChild((child) => {
        if (Node.isVariableStatement(child)) {
          const decl = child.getDeclarationList();
          if (decl.getText().startsWith("let ")) {
            for (const v of decl.getDeclarations()) {
              letVars.set(v.getName(), v.getStartLineNumber());
            }
          }
        }
      });

      if (letVars.size === 0) return;

      // Find inner functions that reference these variables
      outer.forEachDescendant((inner) => {
        if (!isFunctionLike(inner) || inner === outer) return;
        inner.forEachDescendant((ref) => {
          if (Node.isIdentifier(ref)) {
            const name = ref.getText();
            if (letVars.has(name)) {
              findings.push({
                file: filePath(sf),
                outerFunction: functionName(outer),
                innerFunction: functionName(inner),
                variable: name,
                outerLine: letVars.get(name)!,
                innerLine: ref.getStartLineNumber(),
              });
            }
          }
        });
      });
    });
    return findings;
  });

// ---------------------------------------------------------------------------
// Check 3: Circular event flow
// ---------------------------------------------------------------------------

const extractEventName = (callExpr: Node): string | undefined => {
  if (!Node.isCallExpression(callExpr)) return undefined;
  const args = callExpr.getArguments();
  if (args.length === 0) return undefined;
  const first = args[0];
  if (Node.isStringLiteral(first)) return first.getLiteralText();
  return undefined;
};

const checkCircularEventFlow = (
  sourceFiles: SourceFile[],
): CircularEventFinding[] =>
  sourceFiles.flatMap((sf) => {
    const findings: CircularEventFinding[] = [];

    sf.forEachDescendant((fn) => {
      if (!isFunctionLike(fn)) return;

      const subscribedEvents = new Set<string>();
      const emittedEvents = new Set<string>();

      fn.forEachDescendant((node) => {
        if (!Node.isCallExpression(node)) return;
        const expr = node.getExpression();
        if (!Node.isPropertyAccessExpression(expr)) return;

        const methodName = expr.getName();
        const eventName = extractEventName(node);
        if (!eventName) return;

        if (methodName === "on" || methodName === "addEventListener" || methodName === "addListener") {
          subscribedEvents.add(eventName);
        }
        if (methodName === "emit" || methodName === "dispatchEvent") {
          emittedEvents.add(eventName);
        }
      });

      // Also check for subscribeAndYield pattern in for-await
      fn.forEachDescendant((node) => {
        if (Node.isForOfStatement(node) && node.isAwaited()) {
          const initializer = node.getInitializer();
          const iterExpr = node.getExpression();
          if (Node.isCallExpression(iterExpr)) {
            const callee = iterExpr.getExpression();
            if (Node.isIdentifier(callee) && callee.getText() === "subscribeAndYield") {
              const eventName = iterExpr.getArguments()[1];
              if (eventName && Node.isStringLiteral(eventName)) {
                subscribedEvents.add(eventName.getLiteralText());
              }
            }
          }
        }
      });

      // Find overlap
      for (const event of subscribedEvents) {
        if (emittedEvents.has(event)) {
          findings.push({
            file: filePath(sf),
            function: functionName(fn),
            line: fn.getStartLineNumber(),
            event,
          });
        }
      }
    });
    return findings;
  });

// ---------------------------------------------------------------------------
// Check 4: Module concern mixing
// ---------------------------------------------------------------------------

const SIDE_EFFECT_MODULES = new Set([
  "fs", "node:fs", "fs/promises", "node:fs/promises",
  "net", "node:net", "http", "node:http", "https", "node:https",
  "child_process", "node:child_process",
  "process",
]);

const classifyExport = (node: Node, sf: SourceFile): ExportKind => {
  if (isAsyncGenerator(node)) return "async-generator";

  // Check for class / mutable module-level state
  if (Node.isClassDeclaration(node)) return "stateful";
  if (Node.isVariableDeclaration(node)) {
    const init = node.getInitializer();
    if (init && Node.isNewExpression(init)) return "stateful";
  }

  // Check if function body references side-effect modules
  if (isFunctionLike(node)) {
    const text = node.getText();
    const imports = sf.getImportDeclarations();
    for (const imp of imports) {
      const mod = imp.getModuleSpecifierValue();
      if (SIDE_EFFECT_MODULES.has(mod)) {
        // Check if any imported name is used in this function
        for (const named of imp.getNamedImports()) {
          if (text.includes(named.getName())) return "side-effect";
        }
        const ns = imp.getNamespaceImport();
        if (ns && text.includes(ns.getText())) return "side-effect";
        const def = imp.getDefaultImport();
        if (def && text.includes(def.getText())) return "side-effect";
      }
    }
    return "pure-function";
  }

  return "pure-function";
};

const checkModuleConcernMixing = (
  sourceFiles: SourceFile[],
): ModuleConcernFinding[] =>
  sourceFiles.flatMap((sf) => {
    const exports: Array<{ name: string; kind: ExportKind }> = [];

    for (const decl of sf.getExportedDeclarations()) {
      const [name, nodes] = decl;
      for (const node of nodes) {
        exports.push({ name, kind: classifyExport(node, sf) });
      }
    }

    const kinds = [...new Set(exports.map((e) => e.kind))];
    if (kinds.length > 1) {
      return [{ file: filePath(sf), kinds, exports }];
    }
    return [];
  });

// ---------------------------------------------------------------------------
// Check 5: Lifecycle nesting in async generators
// ---------------------------------------------------------------------------

const LIFECYCLE_PATTERNS = [
  "new AbortController",
  "fs.watch(",
  "setTimeout(",
  "setInterval(",
  "fs.watchFile(",
];

const checkLifecycleNesting = (
  sourceFiles: SourceFile[],
): LifecycleNestingFinding[] =>
  sourceFiles.flatMap((sf) => {
    const findings: LifecycleNestingFinding[] = [];

    sf.forEachDescendant((node) => {
      if (!isAsyncGenerator(node)) return;

      const body = node.getText();
      const constructs: string[] = [];

      for (const pattern of LIFECYCLE_PATTERNS) {
        if (body.includes(pattern)) {
          constructs.push(pattern.replace("(", "").trim());
        }
      }

      // Also check for new AbortController via AST
      node.forEachDescendant((child) => {
        if (
          Node.isNewExpression(child) &&
          child.getExpression().getText() === "AbortController" &&
          !constructs.includes("new AbortController")
        ) {
          constructs.push("new AbortController");
        }
      });

      if (constructs.length >= 2) {
        findings.push({
          file: filePath(sf),
          generator: functionName(node),
          line: node.getStartLineNumber(),
          constructs,
          count: constructs.length,
        });
      }
    });
    return findings;
  });

// ---------------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------------

const run = (tsconfigPath: string, threshold: number): Report => {
  const project = new Project({ tsConfigFilePath: tsconfigPath });
  const sourceFiles = project
    .getSourceFiles()
    .filter((sf) => !sf.isDeclarationFile() && !sf.getFilePath().includes("node_modules"));

  return {
    mutableStateDensity: checkMutableStateDensity(sourceFiles, threshold),
    closureOverMutable: checkClosureOverMutable(sourceFiles),
    circularEventFlow: checkCircularEventFlow(sourceFiles),
    moduleConcernMixing: checkModuleConcernMixing(sourceFiles),
    lifecycleNesting: checkLifecycleNesting(sourceFiles),
  };
};

const summarize = (report: Report): void => {
  const log = (msg: string) => process.stderr.write(msg + "\n");
  log("\n=== Complect Detect — Structural Simplicity Report ===\n");

  const section = (name: string, items: unknown[]) => {
    log(`${name}: ${items.length} finding(s)`);
  };

  section("Mutable state density", report.mutableStateDensity);
  for (const f of report.mutableStateDensity) {
    log(`  ${f.file}:${f.line} — ${f.function} (${f.total} mutable ops: ${f.letCount} lets, ${f.reassignmentCount} reassignments)`);
  }

  section("Closure over mutable state", report.closureOverMutable);
  for (const f of report.closureOverMutable) {
    log(`  ${f.file}:${f.innerLine} — inner fn "${f.innerFunction}" captures \`${f.variable}\` from "${f.outerFunction}" (declared line ${f.outerLine})`);
  }

  section("Circular event flow", report.circularEventFlow);
  for (const f of report.circularEventFlow) {
    log(`  ${f.file}:${f.line} — ${f.function} subscribes and emits "${f.event}"`);
  }

  section("Module concern mixing", report.moduleConcernMixing);
  for (const f of report.moduleConcernMixing) {
    log(`  ${f.file} — mixes: ${f.kinds.join(", ")}`);
    for (const e of f.exports) {
      log(`    ${e.name}: ${e.kind}`);
    }
  }

  section("Lifecycle nesting", report.lifecycleNesting);
  for (const f of report.lifecycleNesting) {
    log(`  ${f.file}:${f.line} — ${f.generator} (${f.count} lifecycle constructs: ${f.constructs.join(", ")})`);
  }

  const total =
    report.mutableStateDensity.length +
    report.closureOverMutable.length +
    report.circularEventFlow.length +
    report.moduleConcernMixing.length +
    report.lifecycleNesting.length;

  log(`\nTotal findings: ${total}`);
  log(total === 0 ? "✓ No structural simplicity issues detected." : "✗ Findings above — review for accidental complexity.");
};

// Run
const report = run(tsconfigPath, mutableThreshold);
process.stdout.write(JSON.stringify(report, null, 2) + "\n");
summarize(report);
process.exit(
  report.mutableStateDensity.length +
  report.closureOverMutable.length +
  report.circularEventFlow.length +
  report.moduleConcernMixing.length +
  report.lifecycleNesting.length > 0
    ? 1
    : 0,
);
