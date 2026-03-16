# Prime

You are activating your coding principles before writing code. Follow these five phases exactly.

## Phase 1 — Scan Context

Examine the current coding context to understand what you are about to work on.

If `$ARGUMENTS` is provided, use it as the context (file path, directory, or description). If `$ARGUMENTS` is empty, scan the current working directory — look at open files, recent edits, and the project structure.

Identify the following:

- **Language**: Which programming language(s) are in use?
- **Framework**: Which frameworks or libraries are present (e.g., React, Django, Spring, Express)?
- **Domain**: What problem domain does this code serve (e.g., e-commerce, healthcare, developer tooling)?
- **Architectural style**: What patterns are in use (e.g., microservices, monolith, event-driven, serverless, MVC)?

Detect the following **risk signals** — note which ones are present:

- Authentication or authorization logic
- Payment processing or financial calculations
- Personally identifiable information (PII) handling
- Public-facing API surfaces
- Concurrency, parallelism, or shared mutable state
- High-throughput or latency-sensitive paths

Record the **target path** for use in Phase 2.

## Phase 2 — Resolve .principles Hierarchy

Walk **up** from the target path to the git repo root (directory containing `.git/`) or a maximum of 10 levels, collecting every `.principles` file found along the way. Order them **root → target** (outermost first, innermost last).

**If no `.principles` files are found, skip to Phase 3.**

Otherwise, resolve the active principle set as follows:

### Layer 1 — Always Seeded

Seed the active set with these universally-active principles:

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

For each `.principles` file encountered:

1. Skip blank lines and `#` comment lines
2. For each `@group` entry: read `{{PRINCIPLES_DIRECTORY}}/groups/<group>.yaml`, expand its `principles` list into the active set. Recursively process any `includes` entries (detect and abort on cycles).
3. For each bare `ID` entry: add the ID to the active set (case-insensitive)
4. For each `!ID` entry: add the ID to an exclusion set

After processing all files: `final_active = active_set MINUS exclusion_set`

Record source as: `.principles hierarchy (N files)`

## Phase 3 — Dynamic Detection (fallback)

**Only run this phase if Phase 2 found no `.principles` files.**

Based on the context detected in Phase 1, activate principles across three layers.

### Layer 1 — Always Active

Seed the active set with the 25 Layer 1 universals from Phase 2.

### Layer 2 — Context-Dependent

Based on the context detected in Phase 1, activate ALL principles from matching contexts below. Multiple contexts can match simultaneously.

**api-design** — REST/HTTP API endpoints, controllers, route handlers
Signals: @RestController, @GetMapping, @PostMapping, @RequestMapping, app.get(, app.post(, router., HttpResponse, status_code, REST, endpoint, controller, FastAPI, flask, express, OpenAPI, swagger
Activate: CODE-API-STANDARD-HTTP-METHODS, CODE-API-HATEOAS, CODE-API-RESOURCE-NOUNS, CODE-API-BACKWARD-COMPATIBILITY, CODE-API-HTTP-STATUS-CODES, CODE-SEC-VALIDATE-INPUT, OWASP-03-INJECTION

**concurrency** — Concurrent or parallel code using threads, async, or locks
Signals: async, await, Thread, Lock, Mutex, Semaphore, synchronized, concurrent, parallel, atomic, volatile, CompletableFuture, Promise.all, asyncio, tokio, goroutine, channel
Activate: CODE-CC-SYNC-SHARED-STATE through CODE-CC-STRUCTURED-CONCURRENCY

**domain-modeling** — Domain-driven design with entities, value objects, aggregates
Signals: Entity, ValueObject, Aggregate, Repository, DomainEvent, BoundedContext, domain, aggregate_root, repository, specification, factory
Activate: DDD-AGGREGATE-ROOT, DDD-AGGREGATE, DDD-ENTITY, DDD-VALUE-OBJECT, DDD-REPOSITORY, DDD-DOMAIN-EVENT, DDD-BOUNDED-CONTEXT, DDD-UBIQUITOUS-LANGUAGE

**data-pipeline** — Streaming, ETL, batch processing, message-driven data flows
Signals: stream, pipeline, ETL, transform, batch, kafka, rabbitmq, message_queue, producer, consumer, subscriber, publisher, spark, flink, airflow, dag
Activate: CODE-AR-ASYNC-MESSAGING, CODE-AR-PIPES-AND-FILTERS, CODE-AR-MESSAGE-BROKER, CODE-RL-IDEMPOTENCY, CODE-RL-BACKPRESSURE, CODE-RL-SCHEMA-EVOLUTION

**testing** — Test files, test frameworks, test utilities
Signals: test_, _test.go, .test.ts, .test.js, .spec.ts, .spec.js, @Test, describe(, it(, expect(, assert, pytest, unittest, JUnit, jest, mocha, vitest, mock, stub, fixture
Activate: CODE-TS-TEST-FIRST through CODE-TS-TEST-NAMING

**object-oriented** — Class hierarchies, interfaces, inheritance, OOP patterns
Signals: class, extends, implements, interface, abstract, override, virtual, protected, super(, base., inheritance, polymorphism
Activate: SOLID-SRP, SOLID-OCP, SOLID-LSP, SOLID-ISP, SOLID-DIP, GOF-COMPOSITION-OVER-INHERITANCE, GOF-PROGRAM-TO-INTERFACE, CODE-CS-DRY, CODE-CS-YAGNI

**cloud-native** — Cloud deployment, containers, twelve-factor app patterns
Signals: Dockerfile, docker-compose, kubernetes, k8s, helm, env_var, process.env, os.environ, ConfigMap, Secret, health_check, readiness, liveness, twelve-factor, 12-factor, container, pod, service mesh
Activate: 12FACTOR-01-CODEBASE through 12FACTOR-12-ADMIN-PROCESSES

**infrastructure** — Infrastructure-as-code and provisioning configurations
Signals: terraform, resource, provider, CloudFormation, ansible, playbook, pulumi, cdk, .tf, module, variable, output, data, stack
Activate: CODE-AR-INFRASTRUCTURE-AS-CODE through CODE-AR-COMPOSABLE-MODULES

**ui-interaction** — User interface components, forms, navigation, interaction
Signals: Component, useState, useEffect, render, onClick, onChange, form, input, button, modal, dialog, navigation, route, template, view, directive, v-model, ngModel, @Component, JSX, TSX
Activate: CODE-DX-SYSTEM-STATUS-VISIBILITY through CODE-DX-DATA-INK-RATIO

**library-api** — Public libraries, SDKs, packages consumed by external users
Signals: export, public API, SDK, package, library, @api, @public, module.exports, __init__.py, setup.py, package.json, Cargo.toml, *.gemspec, nuget, npm publish
Activate: CODE-API-STANDARD-HTTP-METHODS, CODE-API-HATEOAS, CODE-API-RESOURCE-NOUNS, CODE-API-HTTP-STATUS-CODES, CODE-API-BACKWARD-COMPATIBILITY

**functional** — Functional programming patterns with immutability and pure functions
Signals: map(, filter(, reduce(, flatMap, immutable, readonly, const, val, pure, lambda, fn, pipe, compose, curry, monad, functor, fold, pattern match
Activate: GOF-COMPOSITION-OVER-INHERITANCE, CODE-CC-PREFER-IMMUTABLE, CODE-TP-MAKE-ILLEGAL-STATES-UNREPRESENTABLE through CODE-TP-BRANDED-TYPES

**typed-language** — Statically typed languages with expressive type systems
Signals: TypeScript, Kotlin, Rust, Haskell, C#, Scala, F#, .ts, .kt, .rs, .hs, .cs, .scala, type, interface, generic, enum, struct, trait
Activate: CODE-TP-MAKE-ILLEGAL-STATES-UNREPRESENTABLE through CODE-TP-BRANDED-TYPES

### Layer 3 — Risk-Elevated

Based on the risk signals detected in Phase 1, elevate principles from matching risks below. Elevated principles carry extra weight — violations are treated as higher severity.

**authentication** — User authentication, sessions, identity verification
Signals: password, login, logout, OAuth, JWT, token, session, authenticate, credential, sign_in, sign_up, bcrypt, hash, salt, OIDC, SAML, bearer, refresh_token
Elevate: OWASP-07-AUTHENTICATION-FAILURES, CODE-SEC-STRONG-CRYPTOGRAPHY, OWASP-01-BROKEN-ACCESS-CONTROL

**financial** — Payments, billing, currency, financial transactions
Signals: payment, billing, invoice, currency, transaction, charge, refund, stripe, paypal, ledger, account_balance, decimal, money, price, checkout, subscription
Elevate: CODE-SEC-VALIDATE-INPUT, CODE-SEC-DATA-INTEGRITY, CODE-RL-IDEMPOTENCY, CODE-CC-SYNC-SHARED-STATE

**personal-data** — Personally identifiable information, privacy-sensitive data
Signals: PII, GDPR, email, SSN, social_security, address, phone_number, date_of_birth, passport, driver_license, personal_data, consent, data_subject, anonymize, pseudonymize, encryption, CCPA, HIPAA
Elevate: CODE-SEC-VALIDATE-INPUT, CODE-SEC-STRONG-CRYPTOGRAPHY, CODE-SEC-SECURITY-BY-DESIGN, CODE-SEC-SECURITY-LOGGING

**public-api** — Versioned or published APIs consumed by third-party clients
Signals: versioned, v1, v2, published, third-party, external, consumer, backward_compatible, deprecat, changelog, breaking_change, semver, api_version, public_api
Elevate: CODE-API-BACKWARD-COMPATIBILITY, CODE-API-STANDARD-HTTP-METHODS, CODE-API-HTTP-STATUS-CODES, CODE-RL-SCHEMA-EVOLUTION

**high-throughput** — Performance-critical code paths requiring low latency
Signals: hot_path, hot path, real-time, realtime, low-latency, low_latency, performance, benchmark, throughput, cache, pool, buffer, batch_size, optimization, critical_path, microsecond, nanosecond
Elevate: CODE-PF-PROFILE-FIRST through CODE-PF-PREDICTABLE-LATENCY, CODE-CC-AVOID-LOCKS-IN-HOT-PATHS

**distributed-system** — Inter-service communication, eventual consistency
Signals: microservice, RPC, gRPC, event-driven, event_bus, saga, choreography, orchestration, circuit_breaker, retry, timeout, idempotent, eventual_consistency, distributed, service_mesh, message_broker, outbox, dead_letter
Elevate: CODE-RL-FAULT-TOLERANCE through CODE-RL-CONSISTENCY-MODELS, CODE-OB-STRUCTURED-TELEMETRY through CODE-OB-DISTRIBUTED-TRACING, CODE-AR-ASYNC-MESSAGING through CODE-AR-MESSAGE-BROKER

**legacy-codebase** — Refactoring, migration, brownfield work
Signals: refactor, migration, brownfield, legacy, technical_debt, tech_debt, deprecated, backward_compat, strangler, anti-corruption, modernize, rewrite, upgrade
Elevate: CODE-CS-DRY, CODE-CS-YAGNI, SIMPLE-DESIGN-PASSES-TESTS, SIMPLE-DESIGN-REVEALS-INTENTION, SIMPLE-DESIGN-NO-DUPLICATION, SIMPLE-DESIGN-FEWEST-ELEMENTS

## Phase 4 — Load Principle Content

Determine the namespaces present in the active ID set (e.g. `CODE`, `CORP` → namespaces `code`, `corp`).

For each namespace, read its single pre-compiled context file:
```
{{PRINCIPLES_DIRECTORY}}/principles/<namespace>/.context-prime.md
```

Each entry in the file has this form:
```
### SOLID-SRP — Single Responsibility Principle
<principle statement>

Why it matters:
<explanation>

Good practice:
<actionable recommendations>
```

Filter to only the entries whose `### ID` is in the final active set. Do not load entries for inactive principles.

Use the **Principle**, **Why it matters**, and **Good practice** content as your active coding frame in Phase 5. This is one file read per namespace, not one read per principle.

## Phase 5 — Output

Present your results in this format:

### Active Principles

| Layer | ID | Title | Source |
|-------|----|-------|--------|
| 1 — Always | SOLID-SRP | Single Responsibility Principle | Layer 1 universal |
| 2 — Context | CODE-API-STANDARD-HTTP-METHODS | Use standard HTTP methods... | api-design context |
| 3 — Risk | CODE-SEC-STRONG-CRYPTOGRAPHY | Use strong cryptography correctly | authentication risk |

Omit Layer 2 and Layer 3 rows if none were activated.

Then state:

> **Principle source:** .principles hierarchy (N files) | dynamic detection
>
> I will write code with these N principles as my active frame. I have read the full guidance for each. Proceed with your request.
