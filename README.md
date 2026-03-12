# .principles

**Expert knowledge as code — portable AI lenses for writing and reviewing software.**

A curated catalog of software engineering principles with proper academic citations, designed to be loaded by AI coding agents (Claude Code, GitHub Copilot, Cursor, etc.) to improve code generation and review.

## What is this?

A collection of **150+ numbered, citable software engineering principles** organized by category, with a `.principles` hierarchy system that encodes which principles apply per directory — eliminating repeated detection on every command run.

Each principle has:
- A unique ID (e.g., `CODE-SD-001`, `CODE-SEC-003`, `CODE-CS-007`)
- A clear description of the principle
- What violations look like
- Good practices to follow
- Full source citations (ISBN, DOI, URL)

See [DESIGN.md](DESIGN.md) for the full system design.

## How it works

### The Layer Model

| Layer | When | What |
|-------|------|------|
| **Layer 1 — Universal** | Always active | 14 non-negotiable principles (validate input, single responsibility, fail fast, etc.) |
| **Layer 2 — Contextual** | Based on what you're building | API design, concurrency, data modeling, etc. — activated by `.principles` files or signal detection |
| **Layer 3 — Risk-elevated** | Based on risk signals | Security, performance, backward compatibility — escalated when auth, payments, PII, or hot paths are detected |

### The `.principles` File

Place a `.principles` file in your project to declare which principles apply:

```
# Activate all Spring Boot principles (includes java)
@spring-boot

# Add a specific principle
CODE-OB-004

# Suppress a principle for this subtree
!CODE-API-012
```

The system walks up from the reviewed file to the git root, collecting `.principles` files and merging them (outermost first, innermost last).

### Three commands

- **`/scout`** — Analyses your project, detects language/framework/domain, and creates `.principles` files for you.
- **`/prime`** — Resolves your `.principles` hierarchy, reads full principle guidance, then prepares your coding frame.
- **`/audit`** — Resolves your `.principles` hierarchy, reads principle content, reviews code, and groups findings by severity (Critical / High / Medium / Low).

## Quick start

```bash
# Clone the repo
git clone https://github.com/flemming-n-larsen/.principles.git

# Install Claude Code slash commands
./install.sh claude

# Use it — in Claude Code:
#   /scout    → detect profile and create .principles files
#   /prime             → before writing code
#   /audit <file>         → after writing code
```

## Principle categories

| ID Prefix | Category | Examples |
|-----------|----------|----------|
| `CODE-SD-` | Software Design | SOLID, GoF patterns, composition, simplicity |
| `CODE-SEC-` | Security | OWASP Top 10, input validation, secrets management |
| `CODE-CS-` | Code Smells & Refactoring | Feature envy, long method, primitive obsession |
| `CODE-API-` | API Design | Backward compatibility, idempotency, REST constraints |
| `CODE-CC-` | Concurrency | Thread safety, structured concurrency, shared-nothing |
| `CODE-DM-` | Domain Modeling | Bounded contexts, aggregates, value objects |
| `CODE-AR-` | Architecture | 12-Factor, clean architecture, integration patterns |
| `CODE-RL-` | Reliability & Error Handling | Fail fast, circuit breakers, idempotent operations |
| `CODE-PF-` | Performance | Mechanical sympathy, data locality, backpressure |
| `CODE-TS-` | Testing Strategy | TDD, test isolation, behavior-driven specs |
| `CODE-OB-` | Observability & Operations | Structured logging, distributed tracing, SLOs |
| `CODE-DX-` | Developer Experience | Naming, readability, cognitive load, UX heuristics |
| `CODE-TP-` | Type & Pattern Safety | Type-driven design, exhaustive matching, nullability |

## Shipped groups

Pre-built groups for common stacks. Reference them with `@name` in `.principles` files.

| Group | Includes | Purpose |
|-------|----------|---------|
| `java` | — | Java OOP and concurrency |
| `typescript` | — | TypeScript type safety |
| `python` | — | Python readability |
| `go` | — | Go composition and concurrency |
| `csharp` | — | C# OOP and async |
| `rust` | — | Rust ownership and safety |
| `spring-boot` | java | Spring Boot REST and DI |
| `spring-data-jpa` | spring-boot | JPA repositories and aggregates |
| `react` | typescript | React components and hooks |
| `angular` | typescript | Angular components and DI |
| `django` | python | Django models and views |
| `fastapi` | python | FastAPI async endpoints |
| `microservices` | — | Resilience and observability |
| `security-focused` | — | Full security principle set |

## Example review output

```
## Critical
- CODE-SEC-004: SQL query built with string concatenation
  UserRepository.java:47 — user input interpolated directly into query string.
  → Use parameterized queries (PreparedStatement).

## High
- CODE-CC-003: Shared mutable state without synchronization
  OrderService.java:23 — counter field modified across request threads.
  → Use AtomicInteger or move state into request scope.

## Medium
- CODE-CS-004: Feature envy
  OrderService.java:61 — accesses 4 fields from Customer but lives in OrderService.
  → Move method to Customer or extract a domain method.

## Low
- CODE-DX-002: Boolean parameter obscures intent
  OrderService.java:89 — processOrder(true) is unclear at call site.
  → Replace with enum or separate methods.

## Summary
Findings: 1 critical, 1 high, 1 medium, 1 low
Active principles: CODE-SEC-001..011, CODE-CC-001..008, CODE-CS-DRY, CODE-CS-YAGNI, CODE-SD-001..007
Principle source: .principles hierarchy (2 files)
```

## Adding a company namespace

Add your own principles alongside the shipped catalog:

```bash
mkdir -p principles/corp
```

```yaml
# principles/corp/catalog.yaml
namespace: corp
id-prefix: CORP
description: "Acme Corp engineering standards"
```

Then reference `CORP-0001` in your `.principles` files. See [DESIGN.md](DESIGN.md#8-adding-a-new-namespace) for full details.

## Contributing

Every contribution requires:
- A clear principle description in your own words
- At least one verifiable published source (book with ISBN, paper with DOI, or authoritative URL)
- Categorization and layer assignment

See [DESIGN.md](DESIGN.md#10-contributing-principles) for the full process.

## License

- **Principle texts:** [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/) — use freely, credit required, share-alike
- **Scripts and tooling:** [MIT](https://opensource.org/licenses/MIT)
