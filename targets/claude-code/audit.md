# Audit

You are reviewing code against activated coding principles. Follow these six phases exactly.

## Phase 1 — Resolve Input

Determine what code to review based on `$ARGUMENTS`:

- If `$ARGUMENTS` is **empty**: respond with "What code would you like me to review?" and stop.
- If `$ARGUMENTS` is a **file path**: read that file and use its contents as the code under review.
- If `$ARGUMENTS` is a **directory path**: recursively glob all source files in that directory. Exclude binaries, lock files, `node_modules`, `vendor`, `dist`, `build`, `.git`, and other build artifacts. Combine the contents of all remaining files as the code under review.
- If `$ARGUMENTS` is **inline code or text**: use it directly as the code under review.

Record the **target path** (file or directory) for use in Phase 2.

## Phase 2 — Resolve .principles Hierarchy

Walk **up** from the target path to the git repo root (directory containing `.git/`) or a maximum of 10 levels, collecting every `.principles` file found along the way. Order them **root → target** (outermost first, innermost last).

**If no `.principles` files are found, skip to Phase 3.**

Otherwise, resolve the active principle set as follows:

### Layer 1 — Always Seeded

Seed the active set with these universally-active principles:

| ID | Title |
|----|-------|
| CODE-SD-001 | Single Responsibility Principle |
| CODE-SD-006 | Favor Composition over Inheritance |
| CODE-SD-007 | Program to an Interface, Not an Implementation |
| CODE-SD-029 | Passes all tests |
| CODE-SD-030 | Reveals intention |
| CODE-SD-031 | No duplication |
| CODE-SD-032 | Fewest elements |
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

For each `.principles` file encountered:

1. Skip blank lines and `#` comment lines
2. For each `@group` entry: read `{{CODE_PRINCIPLES_REPO}}/groups/<group>.yaml`, expand its `principles` list into the active set. Recursively process any `includes` entries (detect and abort on cycles).
3. For each bare `ID` entry: add the ID to the active set (case-insensitive)
4. For each `!ID` entry: add the ID to an exclusion set

After processing all files: `final_active = active_set MINUS exclusion_set`

Record source as: `.principles hierarchy (N files)`

## Phase 3 — Dynamic Detection (fallback)

**Only run this phase if Phase 2 found no `.principles` files.**

Analyze the code under review and identify:

- **Language**: Which programming language(s) are present?
- **Framework**: Which frameworks or libraries are in use?
- **Domain**: What problem domain does this code serve?
- **Architectural style**: What patterns are in use?

Detect the following **risk signals** — note which ones are present:

- Authentication or authorization logic
- Payment processing or financial calculations
- Personally identifiable information (PII) handling
- Public-facing API surfaces
- Concurrency, parallelism, or shared mutable state
- High-throughput or latency-sensitive paths

Seed the active set with Layer 1 universals (same as Phase 2), then apply:

### Layer 2 — Context-Dependent

Based on the code under review, activate ALL principles from matching contexts below.

**api-design** — REST/HTTP API endpoints, controllers, route handlers
Signals: @RestController, @GetMapping, @PostMapping, @RequestMapping, app.get(, app.post(, router., HttpResponse, status_code, REST, endpoint, controller, FastAPI, flask, express, OpenAPI, swagger
Activate: CODE-API-STANDARD-HTTP-METHODS, CODE-API-HATEOAS, CODE-API-RESOURCE-NOUNS, CODE-API-BACKWARD-COMPATIBILITY, CODE-API-HTTP-STATUS-CODES, CODE-SEC-VALIDATE-INPUT, CODE-SEC-004

**concurrency** — Concurrent or parallel code using threads, async, or locks
Signals: async, await, Thread, Lock, Mutex, Semaphore, synchronized, concurrent, parallel, atomic, volatile, CompletableFuture, Promise.all, asyncio, tokio, goroutine, channel
Activate: CODE-CC-SYNC-SHARED-STATE through CODE-CC-STRUCTURED-CONCURRENCY

**domain-modeling** — Domain-driven design with entities, value objects, aggregates
Signals: Entity, ValueObject, Aggregate, Repository, DomainEvent, BoundedContext, domain, aggregate_root, repository, specification, factory
Activate: CODE-DM-001 through CODE-DM-008

**data-pipeline** — Streaming, ETL, batch processing, message-driven data flows
Signals: stream, pipeline, ETL, transform, batch, kafka, rabbitmq, message_queue, producer, consumer, subscriber, publisher, spark, flink, airflow, dag
Activate: CODE-AR-ASYNC-MESSAGING, CODE-AR-PIPES-AND-FILTERS, CODE-AR-MESSAGE-BROKER, CODE-RL-IDEMPOTENCY, CODE-RL-BACKPRESSURE, CODE-RL-SCHEMA-EVOLUTION

**testing** — Test files, test frameworks, test utilities
Signals: test_, _test.go, .test.ts, .test.js, .spec.ts, .spec.js, @Test, describe(, it(, expect(, assert, pytest, unittest, JUnit, jest, mocha, vitest, mock, stub, fixture
Activate: CODE-TS-TEST-FIRST through CODE-TS-TEST-NAMING

**object-oriented** — Class hierarchies, interfaces, inheritance, OOP patterns
Signals: class, extends, implements, interface, abstract, override, virtual, protected, super(, base., inheritance, polymorphism
Activate: CODE-SD-001 through CODE-SD-007, CODE-CS-DRY, CODE-CS-YAGNI

**cloud-native** — Cloud deployment, containers, twelve-factor app patterns
Signals: Dockerfile, docker-compose, kubernetes, k8s, helm, env_var, process.env, os.environ, ConfigMap, Secret, health_check, readiness, liveness, twelve-factor, 12-factor, container, pod, service mesh
Activate: CODE-AR-001 through CODE-AR-012

**infrastructure** — Infrastructure-as-code and provisioning configurations
Signals: terraform, resource, provider, CloudFormation, ansible, playbook, pulumi, cdk, .tf, module, variable, output, data, stack
Activate: CODE-AR-INFRASTRUCTURE-AS-CODE through CODE-AR-COMPOSABLE-MODULES

**ui-interaction** — User interface components, forms, navigation, interaction
Signals: Component, useState, useEffect, render, onClick, onChange, form, input, button, modal, dialog, navigation, route, template, view, directive, v-model, ngModel, @Component, JSX, TSX
Activate: CODE-DX-SYSTEM-STATUS-VISIBILITY through CODE-DX-DATA-INK-RATIO

**library-api** — Public libraries, SDKs, packages consumed by external users
Signals: export, public API, SDK, package, library, @api, @public, module.exports, __init__.py, setup.py, package.json, Cargo.toml, *.gemspec, nuget, npm publish
Activate: CODE-API-001 through CODE-API-010, CODE-API-BACKWARD-COMPATIBILITY

**functional** — Functional programming patterns with immutability and pure functions
Signals: map(, filter(, reduce(, flatMap, immutable, readonly, const, val, pure, lambda, fn, pipe, compose, curry, monad, functor, fold, pattern match
Activate: CODE-SD-006, CODE-CC-PREFER-IMMUTABLE, CODE-TP-MAKE-ILLEGAL-STATES-UNREPRESENTABLE through CODE-TP-BRANDED-TYPES

**typed-language** — Statically typed languages with expressive type systems
Signals: TypeScript, Kotlin, Rust, Haskell, C#, Scala, F#, .ts, .kt, .rs, .hs, .cs, .scala, type, interface, generic, enum, struct, trait
Activate: CODE-TP-MAKE-ILLEGAL-STATES-UNREPRESENTABLE through CODE-TP-BRANDED-TYPES

### Layer 3 — Risk-Elevated

Based on risk signals detected, elevate principles from matching risks. Elevated principles are treated with higher severity — a violation of an elevated principle is promoted one severity level (Low→Medium, Medium→High, High→Critical).

**authentication** — User authentication, sessions, identity verification
Signals: password, login, logout, OAuth, JWT, token, session, authenticate, credential, sign_in, sign_up, bcrypt, hash, salt, OIDC, SAML, bearer, refresh_token
Elevate: CODE-SEC-002, CODE-SEC-STRONG-CRYPTOGRAPHY, CODE-SEC-008

**financial** — Payments, billing, currency, financial transactions
Signals: payment, billing, invoice, currency, transaction, charge, refund, stripe, paypal, ledger, account_balance, decimal, money, price, checkout, subscription
Elevate: CODE-SEC-VALIDATE-INPUT, CODE-SEC-004, CODE-RL-IDEMPOTENCY, CODE-CC-SYNC-SHARED-STATE

**personal-data** — Personally identifiable information, privacy-sensitive data
Signals: PII, GDPR, email, SSN, social_security, address, phone_number, date_of_birth, passport, driver_license, personal_data, consent, data_subject, anonymize, pseudonymize, encryption, CCPA, HIPAA
Elevate: CODE-SEC-VALIDATE-INPUT, CODE-SEC-STRONG-CRYPTOGRAPHY, CODE-SEC-SECURITY-BY-DESIGN, CODE-SEC-SECURITY-LOGGING

**public-api** — Versioned or published APIs consumed by third-party clients
Signals: versioned, v1, v2, published, third-party, external, consumer, backward_compatible, deprecat, changelog, breaking_change, semver, api_version, public_api
Elevate: CODE-API-BACKWARD-COMPATIBILITY, CODE-API-001, CODE-API-004, CODE-RL-SCHEMA-EVOLUTION

**high-throughput** — Performance-critical code paths requiring low latency
Signals: hot_path, hot path, real-time, realtime, low-latency, low_latency, performance, benchmark, throughput, cache, pool, buffer, batch_size, optimization, critical_path, microsecond, nanosecond
Elevate: CODE-PF-PROFILE-FIRST through CODE-PF-PREDICTABLE-LATENCY, CODE-CC-AVOID-LOCKS-IN-HOT-PATHS

**distributed-system** — Inter-service communication, eventual consistency
Signals: microservice, RPC, gRPC, event-driven, event_bus, saga, choreography, orchestration, circuit_breaker, retry, timeout, idempotent, eventual_consistency, distributed, service_mesh, message_broker, outbox, dead_letter
Elevate: CODE-RL-FAULT-TOLERANCE through CODE-RL-CONSISTENCY-MODELS, CODE-OB-STRUCTURED-TELEMETRY through CODE-OB-DISTRIBUTED-TRACING, CODE-AR-ASYNC-MESSAGING through CODE-AR-MESSAGE-BROKER

**legacy-codebase** — Refactoring, migration, brownfield work
Signals: refactor, migration, brownfield, legacy, technical_debt, tech_debt, deprecated, backward_compat, strangler, anti-corruption, modernize, rewrite, upgrade
Elevate: CODE-CS-DRY, CODE-CS-YAGNI, CODE-SD-029 through CODE-SD-032

## Phase 4 — Load Principle Content

Determine the namespaces present in the active ID set (e.g. `CODE`, `CORP` → namespaces `code`, `corp`).

For each namespace, read its single pre-compiled context file:
```
{{CODE_PRINCIPLES_REPO}}/principles/<namespace>/.context-audit.md
```

Each entry in the file has this form:
```
### CODE-SD-001 — Single Responsibility Principle
<principle statement>

Violations to detect:
- <pattern>
- <pattern>
```

Filter to only the entries whose `### ID` is in the final active set. Do not load entries for inactive principles.

Use the **Principle** and **Violations to detect** content in Phase 5 to produce accurate, principle-grounded findings. This is one file read per namespace, not one read per principle.

## Phase 5 — Review

Apply every activated principle against the code under review. For each issue found:

1. Identify which principle ID it violates.
2. Determine the severity: Critical, High, Medium, or Low.
3. Pinpoint the location (file and line number when available).
4. Describe what is wrong in one line.
5. Provide a concrete fix grounded in the principle's guidance.

If a principle was elevated via Layer 3, promote the finding one severity level.

Present findings grouped by severity using this exact format. Omit any severity section that has no findings.

## Critical

Issues that will cause security vulnerabilities, data loss, or crashes in production.

- [ ] [PRINCIPLE-ID]: one-line title
  /absolute/path/to/file:line — what's wrong
  → concrete fix

## High

Issues affecting correctness, concurrency safety, or API contracts.

- [ ] [PRINCIPLE-ID]: one-line title
  /absolute/path/to/file:line — what's wrong
  → concrete fix

## Medium

Issues affecting maintainability, design quality, or readability.

- [ ] [PRINCIPLE-ID]: one-line title
  /absolute/path/to/file:line — what's wrong
  → concrete fix

## Low

Minor improvements — naming, style, minor smells.

- [ ] [PRINCIPLE-ID]: one-line title
  /absolute/path/to/file:line — what's wrong
  → concrete fix

Rules:
- Each finding is exactly three lines: the `- [ ]` line, the `/absolute/path/to/file:line` line, and the `→` line. No blank lines within a finding.
- The `- [ ]` line format is: hyphen, space, open-bracket, space, close-bracket, then exactly ONE space before `[PRINCIPLE-ID]` — never two spaces.
- Always use forward slashes in file paths (e.g. `C:/Code/project/src/file.py:42`). Never use backslashes — they are markdown escape characters and will corrupt filenames containing underscores (e.g. `__init__.py`).
- Separate consecutive findings with exactly one blank line.

## Phase 6 — Summary

After all findings, output a summary block:

## Summary

Findings: X critical, Y high, Z medium, W low
Active principles: [comma-separated list of all principle IDs that were checked]
Principle source: .principles hierarchy (N files) | dynamic detection

If no issues were found at all, output:

## Summary

No issues found.
Active principles: [comma-separated list of all principle IDs that were checked]
Principle source: .principles hierarchy (N files) | dynamic detection

Then, if there are any findings, output a Fix Checklist — a flat, agent-ready task list with one line per finding, ordered by file path then line number. This gives an AI agent a self-contained work queue to iterate through and tick off without cross-referencing the sections above.

## Fix Checklist

- [ ] /absolute/path/to/file:line · SEVERITY · PRINCIPLE-ID — what's wrong → concrete fix

Rules:
- Each entry is exactly one line — no line breaks or blank lines within or between entries.
- The format is: `- [ ] ` (hyphen, space, open-bracket, space, close-bracket, then exactly ONE space) before the path — never two spaces.
- Always use forward slashes in file paths (e.g. `C:/Code/project/src/file.py:42`). Never use backslashes — they are markdown escape characters and will corrupt filenames containing underscores (e.g. `__init__.py`).
- Order by severity (CRITICAL first, then HIGH, MEDIUM, LOW), then by file path alphabetically, then by line number.
- SEVERITY in ALL CAPS: CRITICAL, HIGH, MEDIUM, or LOW.
- Omit the file path if no location is available (inline code review).
- Omit this section entirely if there are no findings.
