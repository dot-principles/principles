cre# Changelog

All notable changes to `.principles` will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/), and this project adheres to [Semantic Versioning](https://semver.org/).

> **Note:** `.principles` is in its early days — this is an experimental release. The system is being actively used and iterated on, but expect rough edges, evolving formats, and breaking changes as things stabilize.

---

## [Unreleased]

### Added

- **8 new API design principles** in `code/api` namespace — `CODE-API-RATE-LIMITING` (with inspection), `CODE-API-PROBLEM-DETAILS`, `CODE-API-PAGINATION` (with inspection), `CODE-API-HTTP-CACHING` (with inspection), `CODE-API-CONDITIONAL-REQUESTS` (with inspection), `CODE-API-CONTENT-NEGOTIATION` (with inspection), `CODE-API-API-VERSIONING` (with inspection), `CODE-API-GRPC-PROTOBUF` (with inspection). Sources: RFC 6585, RFC 7807/9457, RFC 5988, RFC 9111, RFC 7232, RFC 7231/9110, RFC 8594, Richardson & Ruby *RESTful Web Services*, Indrasiri & Kuruppu *gRPC: Up and Running*, Google API Design Guide.
- **Context files for `code/api`** — `.context-audit.md`, `.context-prime.md`, and `.context-inspect.md` created, covering all 13 API principles (5 existing + 8 new).

---

## [v0.3.2] — 2026-03-22

### Changed

- **`/audit` explicit principle override** — `/audit` now accepts an explicit principle spec to force a specific principle set, bypassing `.principles` files and dynamic detection entirely. Three equivalent syntaxes are supported:
  - `<spec> on <target>` — natural language: `/audit DDD on src/orders`
  - `<target> --with <spec>` — flag syntax: `/audit src/orders --with DDD`
  - `@<group> <target>` — group-prefix syntax: `/audit @ddd src/orders`
  - Multiple groups supported comma-separated: `/audit clean-arch, solid on src/`
  - `principle_source` in `audit-output.json` reports `explicit: <spec>` when override is active.

---

## [v0.3.1] — 2026-03-19

### Added

- **Version metadata in command frontmatter** — `/audit`, `/prime`, and `/scout` source files now carry `version`, `description`, `argument-hint`, and `authors` fields in YAML frontmatter, stamped at install time from `VERSION`.

### Fixed

- **Copilot CLI global skills management** — `install.sh` and `uninstall.sh` now correctly create, update, and remove `~/.copilot/skills/<name>/SKILL.md` entries for global Copilot CLI installations.

---

## [v0.3.0] — 2026-03-18

### Changed

- **Artifact-type layer system** — `layers/artifact-types.yaml` classifies every reviewed file into one of 6 stacks (`code`, `docs`, `config`, `infra`, `pipeline`, `schema`), each with its own `layer-1-universal.md` and `layer-2-contexts.yaml` (plus `layer-3-risk-signals.yaml` for `code` and `infra`). A shared universal set of 6 principles (`SIMPLE-DESIGN-REVEALS-INTENTION`, `CODE-CS-DRY`, `CODE-CS-KISS`, `CODE-CS-YAGNI`, `CODE-DX-NAMING`, `ARCH-DECISION-RECORDS`) applies across all stacks; stack-specific layers add targeted principles on top. Type detection uses file extension, filename, and path-pattern signals, with `infra` evaluated before `config` to resolve ambiguous YAML files (e.g. `Chart.yaml`, `values.yaml`).

### Added

- **11 new continuous delivery principles** in new `cd` namespace — `CD-TRUNK-BASED-DEVELOPMENT`, `CD-KEEP-BUILD-GREEN` (with inspection), `CD-DEPLOY-ON-EVERY-COMMIT`, `CD-FEATURE-FLAGS` (with inspection), `CD-FAST-FEEDBACK-LOOPS`, `CD-GITOPS`, `CD-BLUE-GREEN-DEPLOYMENT`, `CD-CANARY-RELEASE`, `CD-DEPLOYMENT-SMOKE-TESTS`, `CD-PIPELINE-AS-CODE` (with inspection), `CD-BUILD-ONCE-DEPLOY-MANY` (with inspection). New `groups/cd.yaml`, catalog, and context files created.
- **24 new architecture and integration principles** — 15 in `arch` namespace (Hexagonal Architecture, Saga, Strangler Fig, Layered Architecture, Microkernel, Anti-Corruption Layer, BFF, Bulkhead, Service Layer, Unit of Work, MVC, API Gateway, Data Mapper, Active Record, Transaction Script); 4 DDD strategic patterns in `ddd` namespace (Context Map, Shared Kernel, Open Host Service, Published Language); 5 Enterprise Integration Patterns in new `eip` namespace (Correlation Identifier, Content-Based Router, Dead Letter Channel, Message Filter, Claim Check). `eip` catalog, context, and group files created. `groups/microservices.yaml` and `groups/ddd.yaml` updated.
- **7 new observability principles** in `code/ob` — USE Method (Gregg), RED Method (Wilkie), Error Budget burn-rate alerting (with inspection), Four Golden Signals, Health Check API — Richardson (with inspection), Percentile-based latency (Dean & Barroso), Alert on symptoms not causes. `groups/microservices.yaml`, context files, and `catalog.yaml` (242 principles) updated.
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

[v0.3.2]: https://github.com/dot-principles/dot-principles/releases/tag/v0.3.2
[v0.3.1]: https://github.com/dot-principles/dot-principles/releases/tag/v0.3.1
[v0.3.0]: https://github.com/dot-principles/principles/releases/tag/v0.3.0
[v0.2.0]: https://github.com/dot-principles/principles/releases/tag/v0.2.0
[v0.1.0]: https://github.com/dot-principles/principles/releases/tag/v0.1.0
