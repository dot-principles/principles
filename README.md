# .principles

**Select the software engineering principles you want your AI coding agent to focus on.**

A curated catalog of software engineering principles, organized into a `.principles` hierarchy that projects declare to guide AI code generation and review.

> See [DISCLAIMER.md](DISCLAIMER.md) — this is a proof of concept. Groups are opinionated, gaps exist, and adjustments are expected.

## Philosophy

`.principles` does **not** teach the AI anything. Modern AI coding agents already know SOLID, OWASP, DDD, and the rest. The point is to **focus and trigger** that knowledge — to give the AI context about *which* principles matter for *this* codebase, alongside the other AI instructions it receives (AGENTS.md, CLAUDE.md, `.github/copilot-instructions.md`, etc.).

Think of it as: the AI instructions tell the agent *how to behave*; `.principles` tells it *which engineering lens to apply*.

## How it works

Place a `.principles` file in your project root (and optionally in subdirectories) to declare which principles apply:

```
# Activate all Spring Boot principles (includes java)
@spring-boot

# Add a specific principle
CODE-OB-004

# Suppress a principle for this subtree
!CODE-API-012
```

The system walks up from the reviewed file to the git root, collecting `.principles` files and merging them (outermost first, innermost last). The AI then reads the full principle content before coding or reviewing.

### Layer model

| Layer | When | What |
|-------|------|------|
| **Layer 1 — Universal** | Always active | Non-negotiable principles (validate input, single responsibility, fail fast, etc.) |
| **Layer 2 — Contextual** | Based on what you're building | API design, concurrency, data modeling, etc. |
| **Layer 3 — Risk-elevated** | Based on risk signals | Security, performance, backward compatibility |

### Three commands

- **`/scout`** — Analyses your project, detects language/framework/domain, and creates `.principles` files.
- **`/prime`** — Resolves your `.principles` hierarchy, reads full principle guidance, prepares your coding frame.
- **`/audit`** — Resolves your `.principles` hierarchy, reads principle content, reviews code, and groups findings by severity (Critical / High / Medium / Low).

## Quick start

```bash
# Clone the repo
git clone https://github.com/flemming-n-larsen/.principles.git

# Install Claude Code slash commands
./install.sh claude

# Use it — in Claude Code:
#   /scout         → detect profile and create .principles files
#   /prime         → before writing code
#   /audit <file>  → after writing code
```

## Principle catalog

150+ principles across 13 categories:

| ID Prefix | Category |
|-----------|----------|
| `CODE-SD-` | Software Design (SOLID, GoF, composition, simplicity) |
| `CODE-SEC-` | Security (OWASP Top 10, input validation, secrets) |
| `CODE-CS-` | Code Smells & Refactoring |
| `CODE-API-` | API Design |
| `CODE-CC-` | Concurrency |
| `CODE-DM-` | Domain Modeling |
| `CODE-AR-` | Architecture |
| `CODE-RL-` | Reliability & Error Handling |
| `CODE-PF-` | Performance |
| `CODE-TS-` | Testing Strategy |
| `CODE-OB-` | Observability & Operations |
| `CODE-DX-` | Developer Experience |
| `CODE-TP-` | Type & Pattern Safety |

Shipped groups (e.g., `@spring-boot`, `@react`, `@microservices`, `@security-focused`) bundle related principles for common stacks. See [DESIGN.md](DESIGN.md#5-groups) for the full list.

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

## Low
- CODE-DX-002: Boolean parameter obscures intent
  OrderService.java:89 — processOrder(true) is unclear at call site.
  → Replace with enum or separate methods.

## Summary
Findings: 1 critical, 1 high, 1 low
Active principles: CODE-SEC-001..011, CODE-CC-001..008, CODE-SD-001..007
Principle source: .principles hierarchy (2 files)
```

## Extending with your own principles

Fork this repo and add a `principles/corp/` namespace (or any name) for corporate or domain-specific principles. Reference them with `CORP-0001` in your `.principles` files. See [DESIGN.md](DESIGN.md#8-adding-a-new-namespace) for the full process.

## Contributing

Every contribution requires a clear principle description, at least one verifiable published source (book with ISBN, paper with DOI, or authoritative URL), and correct layer assignment. See [DESIGN.md](DESIGN.md#10-contributing-principles) for the full process.

## License

- **Principle texts:** [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/) — use freely, credit required, share-alike
- **Scripts and tooling:** [MIT](https://opensource.org/licenses/MIT)
- **How to apply this in practice:** see [LICENSE-INTERPRETATION.md](LICENSE-INTERPRETATION.md) (including `internal use` vs `distribution`, and what users/developers may do and must do)
- **Ownership boundary:** see [Ownership and curation scope](LICENSE-INTERPRETATION.md#10-ownership-and-curation-scope)
