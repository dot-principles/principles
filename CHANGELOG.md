# Changelog

All notable changes to `.principles` will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/), and this project adheres to [Semantic Versioning](https://semver.org/).

> **Note:** `.principles` is in its early days — this is an experimental release. The system is being actively used and iterated on, but expect rough edges, evolving formats, and breaking changes as things stabilize.

---

## [Unreleased]

### Added

- **7 new observability principles** in `code/ob` — USE Method (Gregg), RED Method (Wilkie), Error Budget burn-rate alerting, Four Golden Signals, Health Check API (Richardson), Percentile-based latency (Dean & Barroso), Alert on symptoms not causes. `CODE-OB-ERROR-BUDGET` and `CODE-OB-HEALTH-CHECK-API` include `## Inspection` grep patterns. `CODE-OB-ALERT-ON-SYMPTOMS` is `Audit-scope: limited`. `groups/microservices.yaml`, context files, and `catalog.yaml` (242 principles) updated.
- **7 new testing principles** in `code/ts` — Test Data Builder, Humble Object, No Test Logic in Production (with inspection), Characterization Tests (`Audit-scope: limited`), Test Pyramid, Consumer-Driven Contracts, Property-Based Testing.
- **Audit-scope metadata** — `principles/AUDIT-SCOPE.md` added; 8 principle files annotated (4 excluded, 4 limited).
- **`CONTRIBUTING.md`** — code auditability and no-redundancy requirements added.
- **`principles/TEMPLATE.md`** — optional `**Audit-scope:**` field documented.

---

## [v0.2.0] — 2026-03-17

### Changed

- **Installer copies principle data to `~/.principles`** — created on install, refreshed on every run; `{{PRINCIPLES_DIRECTORY}}` placeholder substituted at install time in command files. Global uninstall removes `~/.principles`; local uninstalls leave it intact.

### Added

- **14 new database principles** in new `db` namespace — `DB-ACID`, `DB-SCHEMA-MIGRATIONS-AS-CODE`, `DB-CAP-THEOREM`, `DB-AVOID-N-PLUS-ONE` (with inspection), `DB-INDEX-FOR-ACCESS-PATTERNS`, `DB-THIRD-NORMAL-FORM`, `DB-CQRS`, `DB-OUTBOX-PATTERN`, `DB-EVENTUAL-CONSISTENCY`, `DB-EVENT-SOURCING`, `DB-OPTIMISTIC-CONCURRENCY`, `DB-TWO-PHASE-LOCKING`, `DB-POLYGLOT-PERSISTENCE`, `DB-DENORMALIZE-INTENTIONALLY`. New `@db` group and context files.
- **7 new security principles** — 4 in `code/sec` (`DEFENSE-IN-DEPTH`, `FAIL-SAFE-DEFAULTS` with inspection, `COMPLETE-MEDIATION`, `PRIVACY-BY-DESIGN`) and 3 in new `sec-arch` namespace (`THREAT-MODELLING`, `ZERO-TRUST`, `SUPPLY-CHAIN-SECURITY` with inspection). `groups/security-focused.yaml` updated.
- **27 new OOP/object-design principles** — `pkg` namespace (6 Package Principles, Martin); `gof` additions (Law of Demeter, Null Object); `code/cs` additions (Design by Contract, Tell Don't Ask, Information Hiding, Uniform Access); 9 Fowler code smells; 5 Effective Java items; `DDD-SPECIFICATION`.
- **20 functional programming principles** in new `fp` namespace — 4 universal (pure functions, referential transparency, immutability, no shared mutable state), 16 contextual. New `@fp` group and 11 new language groups (`@javascript`, `@swift`, `@ruby`, `@php`, `@scala`, `@cpp`, `@c`, `@dart`, `@elixir`, `@haskell`, `@fsharp`).

---

## [v0.1.0] — 2026-03-15

**Initial release.**

### Highlights

- **187 principle files** across **13 top-level namespaces** — `12factor`, `arch`, `clean-arch`, `code`, `code-smells`, `ddd`, `effective-java`, `gof`, `grasp`, `infra`, `owasp`, `simple-design`, `solid`
- **30 pre-defined groups** — `@spring-boot`, `@react`, `@angular`, `@django`, `@fastapi`, `@microservices`, `@security-focused`, `@clean-arch`, `@solid`, `@typescript`, and more
- **3 AI commands** — `/scout`, `/prime`, `/audit`
- **3-layer model** — Universal, Contextual, and Risk-Elevated principles
- **Hierarchical `.principles` file resolution** — project-level overrides with inheritance
- **Cross-platform installer** — Bash, PowerShell, and CMD wrapper scripts
- **3 target platforms** — Claude Code, GitHub Copilot, Cursor
- **Full documentation suite** — README, DESIGN.md, INSTALL.md, REQUIREMENTS.md, and more
- **Inspection sections** — `.context-inspect.md` files and inline `## Inspection` sections with `grep` patterns for automated principle verification across `code/` and `solid/` namespaces
- **Improved catalog** — restructured `principles/catalog.yaml` with expanded metadata
- **Enhanced audit command** — richer inspection-driven audit flow in `targets/claude-code/audit.md`
- **CONTRIBUTING.md** — contributor guidelines added
- **Layer refinements** — updated universal layer, context mappings, and risk signals

### What's Next

See [TODO.md](TODO.md) for the roadmap.

---

[v0.2.0]: https://github.com/code-principles/principles/releases/tag/v0.2.0
[v0.1.0]: https://github.com/code-principles/principles/releases/tag/v0.1.0
