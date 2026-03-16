---
name: audit
description: Resolve the .principles hierarchy, load principle content, review code, and group findings by severity (Critical/High/Medium/Low). Use this skill when asked to audit or review code against principles.
license: MIT
---

# Audit

Review code against activated coding principles in seven phases.

## Phase 1 — Resolve Input

Determine what to review from `$ARGUMENTS`:

- Empty → respond "What code would you like me to review?" and stop.
- File path → read that file.
- Directory path → recursively glob all source files; exclude binaries, lock files, `node_modules`, `vendor`, `dist`, `build`, `.git`, and build artifacts.
- Inline code → use it directly.

## Phase 2 — Resolve .principles Hierarchy

Walk up from the target path to the git repo root (`.git/`) or max 10 levels, collecting every `.principles` file. Order: root → target.

**If no `.principles` files found: skip to Phase 3.**

### Directives

Lines starting with `:` are configuration directives. Parse them before processing IDs:

- `:max_principles N` — cap the total number of active principles to N. When trimming to fit:
  1. Layer 1 principles are **always retained** (never trimmed)
  2. Layer 3 risk-elevated principles — next priority
  3. Layer 2 context-dependent principles — lowest priority, dropped first
  If Layer 1 alone exceeds the cap, the cap applies only to non-Layer-1 principles (Layer 1 is never dropped).

### Layer 1 — Always Seeded

| ID | Title |
|----|-------|
| SOLID-SRP | Single Responsibility Principle |
| GOF-COMPOSITION-OVER-INHERITANCE | Favor Composition over Inheritance |
| GOF-PROGRAM-TO-INTERFACE | Program to an Interface, Not an Implementation |
| SIMPLE-DESIGN-PASSES-TESTS | Passes all tests |
| SIMPLE-DESIGN-REVEALS-INTENTION | Reveals intention |
| SIMPLE-DESIGN-NO-DUPLICATION | No duplication |
| SIMPLE-DESIGN-FEWEST-ELEMENTS | Fewest elements |
| CODE-SEC-VALIDATE-INPUT | Validate input at system boundaries |
| CODE-CS-DRY | DRY: Don't Repeat Yourself |
| CODE-CS-WET | WET: Write Every Time |
| CODE-CS-YAGNI | YAGNI: You Aren't Gonna Need It |
| CODE-CS-KISS | KISS: Keep It Simple |
| CODE-CS-NIH | NIH: Not Invented Here |
| CODE-CS-NO-SILVER-BULLET | No Silver Bullet |
| CODE-CS-CQS | CQS: Command-Query Separation |
| CODE-CS-BOY-SCOUT | The Boy Scout Rule |
| CODE-CS-BROKEN-WINDOWS | Broken Windows |
| CODE-CS-POSTELS-LAW | Postel's Law |
| CODE-CS-HYRUMS-LAW | Hyrum's Law |
| ARCH-CONWAYS-LAW | Conway's Law |
| CODE-DX-NAMING | Name things by what they represent |
| CODE-DX-SMALL-FUNCTIONS | Keep functions small and single-purpose |
| CODE-DX-CODE-FOR-READERS | Write code for the reader, not the writer |
| CODE-DX-DELETE-DEAD-CODE | Delete dead code |
| CODE-CS-FAIL-FAST | Fail fast, fail loudly |

### Process Each .principles File (root → target)

1. Skip blank lines and `#` comments.
2. `:directive value` → parse as a configuration directive (see above).
3. `@group` → read `{{PRINCIPLES_DIRECTORY}}/groups/<group>.yaml`, expand `principles` into the active set; recursively process `includes` (abort on cycles).
4. Bare `ID` → add to an active set (case-insensitive).
5. `!ID` → add to an exclusion set.

`final_active = active_set MINUS exclusion_set` (then apply `:max_principles` cap if set) · Source: `.principles hierarchy (N files)`

## Phase 3 — Dynamic Detection (fallback)

**Only if Phase 2 found no `.principles` files.**

Detect language, framework, domain, and risk signals (auth, payments, PII, public APIs, concurrency, high-throughput). Seed with Layer 1, then apply:

### Layer 2 — Context-Dependent

Activate ALL matching contexts:

**api-design** — REST/HTTP endpoints, controllers
Signals: `@RestController`, `@GetMapping`, `app.get(`, `router.`, `HttpResponse`, `FastAPI`, `flask`, `express`, `swagger`
Activate: CODE-API-STANDARD-HTTP-METHODS, CODE-API-HATEOAS, CODE-API-RESOURCE-NOUNS, CODE-API-BACKWARD-COMPATIBILITY, CODE-API-HTTP-STATUS-CODES, CODE-SEC-VALIDATE-INPUT, OWASP-03-INJECTION

**concurrency** — Threads, async, locks
Signals: `async`, `await`, `Thread`, `Lock`, `Mutex`, `Semaphore`, `synchronized`, `asyncio`, `goroutine`, `channel`
Activate: CODE-CC-SYNC-SHARED-STATE through CODE-CC-STRUCTURED-CONCURRENCY

**domain-modeling** — DDD entities, value objects, aggregates
Signals: `Entity`, `ValueObject`, `Aggregate`, `Repository`, `DomainEvent`, `BoundedContext`
Activate: DDD-AGGREGATE-ROOT, DDD-AGGREGATE, DDD-ENTITY, DDD-VALUE-OBJECT, DDD-REPOSITORY, DDD-DOMAIN-EVENT, DDD-BOUNDED-CONTEXT, DDD-UBIQUITOUS-LANGUAGE

**data-pipeline** — Streaming, ETL, batch, message queues
Signals: `stream`, `pipeline`, `ETL`, `kafka`, `rabbitmq`, `producer`, `consumer`, `airflow`, `dag`
Activate: CODE-AR-ASYNC-MESSAGING, CODE-AR-PIPES-AND-FILTERS, CODE-AR-MESSAGE-BROKER, CODE-RL-IDEMPOTENCY, CODE-RL-BACKPRESSURE, CODE-RL-SCHEMA-EVOLUTION

**testing** — Test files and frameworks
Signals: `test_`, `_test.go`, `.test.ts`, `.spec.ts`, `@Test`, `describe(`, `pytest`, `jest`, `mock`, `fixture`
Activate: CODE-TS-TEST-FIRST through CODE-TS-TEST-NAMING

**object-oriented** — Classes, interfaces, inheritance
Signals: `class`, `extends`, `implements`, `interface`, `abstract`, `override`
Activate: SOLID-SRP, SOLID-OCP, SOLID-LSP, SOLID-ISP, SOLID-DIP, GOF-COMPOSITION-OVER-INHERITANCE, GOF-PROGRAM-TO-INTERFACE, CODE-CS-DRY, CODE-CS-YAGNI

**cloud-native** — Containers, Kubernetes, twelve-factor
Signals: `Dockerfile`, `kubernetes`, `helm`, `process.env`, `os.environ`, `ConfigMap`, `health_check`
Activate: 12FACTOR-01-CODEBASE through 12FACTOR-12-ADMIN-PROCESSES

**infrastructure** — IaC and provisioning
Signals: `terraform`, `CloudFormation`, `ansible`, `pulumi`, `.tf`, `module`, `variable`
Activate: CODE-AR-INFRASTRUCTURE-AS-CODE through CODE-AR-COMPOSABLE-MODULES

**ui-interaction** — UI components, forms, navigation
Signals: `useState`, `useEffect`, `onClick`, `onChange`, `form`, `template`, `v-model`, JSX, TSX
Activate: CODE-DX-SYSTEM-STATUS-VISIBILITY through CODE-DX-DATA-INK-RATIO

**library-api** — Public libraries, SDKs
Signals: `export`, `__init__.py`, `setup.py`, `package.json`, `Cargo.toml`, `npm publish`
Activate: CODE-API-STANDARD-HTTP-METHODS, CODE-API-HATEOAS, CODE-API-RESOURCE-NOUNS, CODE-API-HTTP-STATUS-CODES, CODE-API-BACKWARD-COMPATIBILITY

**functional** — Immutability, pure functions
Signals: `map(`, `filter(`, `reduce(`, `immutable`, `readonly`, `lambda`, `pipe`, `compose`
Activate: GOF-COMPOSITION-OVER-INHERITANCE, CODE-CC-PREFER-IMMUTABLE, CODE-TP-MAKE-ILLEGAL-STATES-UNREPRESENTABLE through CODE-TP-BRANDED-TYPES

**typed-language** — Static type systems
Signals: TypeScript, Kotlin, Rust, Haskell, C#, Scala, `.ts`, `.kt`, `.rs`, `.cs`
Activate: CODE-TP-MAKE-ILLEGAL-STATES-UNREPRESENTABLE through CODE-TP-BRANDED-TYPES

### Layer 3 — Risk-Elevated

Violations of elevated principles are promoted one severity level (Low→Medium, Medium→High, High→Critical).

**authentication** — Signals: `password`, `login`, `OAuth`, `JWT`, `token`, `session`, `bcrypt`, `hash`
Elevate: OWASP-07-AUTHENTICATION-FAILURES, CODE-SEC-STRONG-CRYPTOGRAPHY, OWASP-01-BROKEN-ACCESS-CONTROL

**financial** — Signals: `payment`, `billing`, `invoice`, `currency`, `transaction`, `stripe`, `paypal`
Elevate: CODE-SEC-VALIDATE-INPUT, CODE-SEC-DATA-INTEGRITY, CODE-RL-IDEMPOTENCY, CODE-CC-SYNC-SHARED-STATE

**personal-data** — Signals: `PII`, `GDPR`, `email`, `SSN`, `personal_data`, `HIPAA`, `CCPA`
Elevate: CODE-SEC-VALIDATE-INPUT, CODE-SEC-STRONG-CRYPTOGRAPHY, CODE-SEC-SECURITY-BY-DESIGN, CODE-SEC-SECURITY-LOGGING

**public-api** — Signals: `versioned`, `v1`, `v2`, `third-party`, `backward_compatible`, `deprecat`, `semver`
Elevate: CODE-API-BACKWARD-COMPATIBILITY, CODE-API-STANDARD-HTTP-METHODS, CODE-API-HTTP-STATUS-CODES, CODE-RL-SCHEMA-EVOLUTION

**high-throughput** — Signals: `hot_path`, `realtime`, `low-latency`, `benchmark`, `throughput`, `cache`, `pool`
Elevate: CODE-PF-PROFILE-FIRST through CODE-PF-PREDICTABLE-LATENCY, CODE-CC-AVOID-LOCKS-IN-HOT-PATHS

**distributed-system** — Signals: `microservice`, `gRPC`, `circuit_breaker`, `retry`, `idempotent`, `saga`, `outbox`
Elevate: CODE-RL-FAULT-TOLERANCE through CODE-RL-CONSISTENCY-MODELS, CODE-OB-STRUCTURED-TELEMETRY through CODE-OB-DISTRIBUTED-TRACING, CODE-AR-ASYNC-MESSAGING through CODE-AR-MESSAGE-BROKER

**legacy-codebase** — Signals: `refactor`, `migration`, `legacy`, `tech_debt`, `deprecated`, `strangler`
Elevate: CODE-CS-DRY, CODE-CS-YAGNI, SIMPLE-DESIGN-PASSES-TESTS, SIMPLE-DESIGN-REVEALS-INTENTION, SIMPLE-DESIGN-NO-DUPLICATION, SIMPLE-DESIGN-FEWEST-ELEMENTS

## Phase 4 — Load Principle Content

For each namespace in the active ID set, read one file:

```
{{PRINCIPLES_DIRECTORY}}/principles/<namespace>/.context-audit.md
```

Filter to entries whose `### ID` is in the final active set. Use the **Principle** and **Violations to detect** content in Phase 6.

## Phase 5 — Pre-Scan

**Output nothing during this phase.**

Run deterministic, machine-executable commands to narrow the search space before LLM reasoning. This is the "Search" step of Search-Analyze-Report.

### 5.1 — Load Inspection Patterns

For each namespace in the active ID set, check for:

```
{{PRINCIPLES_DIRECTORY}}/principles/<namespace>/.context-inspect.md
```

Filter to entries whose `### ID` is in the final active set. Each entry contains one or more commands in this format:

```
- `command` | SEVERITY_HINT | description
```

Principles with entries in `.context-inspect.md` are **"inspected"**. Principles without entries are **"semantic-only"** (handled entirely by LLM reasoning in Phase 6 Step 2).

### 5.2 — Execute Commands

For each inspection command:

1. Replace `$TARGET` with the actual path from Phase 1.
2. Run the command using bash.
3. Collect hits as: `{principle_id, severity_hint, file, line, match_text, description}`.
4. If a command produces no output or fails, skip silently.

### 5.3 — Build Pre-Scan Manifest

Group all hits by file. The result is the **pre-scan manifest** — a map of `file → [{principle_id, severity_hint, line, match_text, description}]`.

Track two sets:
- **Inspected principles** — those that had at least one command in `.context-inspect.md` (regardless of whether hits were found)
- **Semantic-only principles** — all remaining active principles

## Phase 6 — Review

**Output nothing during this phase.**

### Step 1 — Guided Review (pre-scan hits)

For each file in the pre-scan manifest:

1. Read the file (or at minimum ±10 lines around each hit).
2. For each hit, evaluate it against the principle's **Violations to detect** from Phase 4.
3. **Confirm** → record as a finding (use the severity hint as a starting point, adjust based on context; elevated → promote one level).
4. **Dismiss** → false positive, do not report.

### Step 2 — Semantic-Only Review

**Read every source file** collected in Phase 1. Apply only the **semantic-only principles** (those without inspection patterns). Do not substitute grep, search, or pattern-matching tools for reading — you must read and understand each file's logic, structure, and intent.

For each file, evaluate design, naming, structure, input handling, duplication, and intent against the semantic-only principle set.

### Step 3 — Opportunistic Findings

While reading files in Steps 1 and 2, if you encounter a clear violation of **any** active principle (including inspected ones not flagged by pre-scan), record it as a finding.

### Recording Findings

For each violation found, record: principle ID, severity (Critical/High/Medium/Low, elevated → promote one level), absolute file path with forward slashes, line number, one sentence describing what is wrong, and a concrete fix grounded in the principle.

## Phase 7 — Output

**Step 1.** Write `audit-output.json` to the **repository root** (where `.git/` is) with this structure:

```json
{
  "findings": [
    {
      "severity":     "HIGH",
      "principle_id": "SOLID-SRP",
      "title":        "one-line description",
      "file":         "C:/absolute/path/to/file.py",
      "line":         42,
      "description":  "what is wrong",
      "fix":          "concrete fix"
    }
  ],
  "summary": {
    "critical": 0,
    "high": 1,
    "medium": 0,
    "low": 0,
    "active_principles": ["SOLID-SRP", "CODE-CS-DRY"],
    "principle_source": ".principles hierarchy (2 files)"
  }
}
```

- `severity`: `CRITICAL`, `HIGH`, `MEDIUM`, or `LOW`
- `file`: absolute path, forward slashes; `""` if unavailable
- `line`: integer; `0` if unavailable
- `findings`: `[]` if no issues found

**Step 2.** Output a compact text report grouped by severity. Use this exact template:

```
Audit complete — {N} findings.

Critical:

- `{absolute/file.py}:{line}` [{PRINCIPLE-ID}] — {description}. → {fix}.

High:

- `{absolute/file.py}:{line}` [{PRINCIPLE-ID}] — {description}. → {fix}.

Medium:

- `{absolute/file.py}:{line}` [{PRINCIPLE-ID}] — {description}. → {fix}.

Low:

- `{absolute/file.py}:{line}` [{PRINCIPLE-ID}] — {description}. → {fix}.

Summary: {critical} critical, {high} high, {medium} medium, {low} low
Principle source: {source}

Generated: {absolute path}/audit-output.json
```

- Group findings by severity (Critical / High / Medium / Low). Omit empty severity groups.
- Use absolute file paths with forward slashes, wrapped in backticks to prevent markdown mangling (e.g. `__init__.py`).
- Principle ID in brackets: `[SOLID-SRP]`.
- One line per finding.
- If no findings: output `Audit complete — 0 findings.` followed by the Summary and Generated lines.
