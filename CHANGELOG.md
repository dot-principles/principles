# Changelog

All notable changes to `.principles` will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/), and this project adheres to [Semantic Versioning](https://semver.org/).

> **Note:** `.principles` is in its early days — this is an experimental release. The system is being actively used and iterated on, but expect rough edges, evolving formats, and breaking changes as things stabilize.

---

## [Unreleased]

### Added

- **`principles/AUDIT-SCOPE.md`** — central document explaining which principles are fully excluded or partially limited for `/audit`, with rationale for each
- **`**Audit-scope:**` metadata field** — 8 principle files annotated:
  - Fully excluded (snapshot cannot detect violations): `CODE-CS-BOY-SCOUT`, `ARCH-CONWAYS-LAW`, `CODE-PF-PROFILE-FIRST`, `SEC-ARCH-THREAT-MODELLING`
  - Partially limited (some violations detectable from code): `CODE-TS-TEST-FIRST`, `12FACTOR-10-DEV-PROD-PARITY`, `12FACTOR-09-DISPOSABILITY`, `DDD-UBIQUITOUS-LANGUAGE`
- **`CONTRIBUTING.md`** — two new requirements: code auditability (every principle needs at least one code-detectable violation) and no redundancy (no duplicate principles, check `catalog.yaml` first)
- **`principles/TEMPLATE.md`** — optional `**Audit-scope:**` field added as a commented line with usage guidance

---

## [v0.2.0] — 2026-03-17

### Changed

- **Installer now copies principle data to `~/.principles`** — `install.sh` creates a fixed well-known data directory (`~/.principles` on Linux/macOS/Windows Git Bash; `%USERPROFILE%\.principles` on Windows) and copies `groups/` and `principles/` into it on every install. The directory is refreshed (old files removed, new files copied) on every run, so updates are always in sync.
- **`{{PRINCIPLES_DIRECTORY}}` placeholder resolved at installation time** — The Claude Code command files (`audit.md`, `prime.md`, `scout.md`) contain `{{PRINCIPLES_DIRECTORY}}` as a placeholder for the data directory. `install.sh` now substitutes this with the actual `~/.principles` path via `sed` when writing to `~/.claude/commands/`. The placeholder remains in the source files; only the installed copies are rewritten.
- **`uninstall.sh` removes `~/.principles` on global uninstall** — Running `./uninstall.sh` (no argument) now deletes `~/.principles` in addition to the command files. Local uninstalls (`./uninstall.sh <dir>`) leave the data directory intact, since it is shared across all installations.

### Added

- **14 new database / persistence principles** — new namespace `db`:
  - **Layer 1 (universal):** `DB-ACID` (Gray & Reuter 1992 / Haerder & Reuter 1983), `DB-SCHEMA-MIGRATIONS-AS-CODE` (Humble & Farley 2010)
  - **Layer 2 (contextual):** `DB-CAP-THEOREM` (Brewer 2000 / Gilbert & Lynch 2002), `DB-AVOID-N-PLUS-ONE` (Kleppmann 2017 / Fowler PEAA), `DB-INDEX-FOR-ACCESS-PATTERNS` (Kleppmann 2017 / Winand 2012), `DB-THIRD-NORMAL-FORM` (Codd 1970 / Date 2003), `DB-CQRS` (Young 2010 / Fowler 2011), `DB-OUTBOX-PATTERN` (Richardson 2018), `DB-EVENTUAL-CONSISTENCY` (Vogels 2008 / Pritchett 2008), `DB-EVENT-SOURCING` (Young 2010 / Fowler 2005), `DB-OPTIMISTIC-CONCURRENCY` (Kung & Robinson 1981), `DB-TWO-PHASE-LOCKING` (Gray 1978), `DB-POLYGLOT-PERSISTENCE` (Fowler & Sadalage 2012), `DB-DENORMALIZE-INTENTIONALLY` (Fowler PEAA / Date 2003)
  - `DB-AVOID-N-PLUS-ONE` includes an `## Inspection` section with a grep heuristic for queries inside loops
  - `groups/db.yaml` added — bundles all 14 principles for the `@db` group
  - `principles/db/.context-prime.md` and `.context-audit.md` added for `/prime` and `/audit` support
  - `principles/catalog.yaml` updated: 228 principles across 16 namespaces

- **7 new security principles** across two namespaces:
  - **`code/sec/`** (4 new) — `CODE-SEC-DEFENSE-IN-DEPTH` (NIST SP 800-53 / NSA), `CODE-SEC-FAIL-SAFE-DEFAULTS` (Saltzer & Schroeder 1975), `CODE-SEC-COMPLETE-MEDIATION` (Saltzer & Schroeder 1975), `CODE-SEC-PRIVACY-BY-DESIGN` (Cavoukian / ISO/IEC 29101 / GDPR Art 25)
  - **`sec-arch/`** (new namespace, 3 principles) — `SEC-ARCH-THREAT-MODELLING` (Shostack / OWASP), `SEC-ARCH-ZERO-TRUST` (NIST SP 800-207 / Kindervag), `SEC-ARCH-SUPPLY-CHAIN-SECURITY` (SLSA / NIST SP 800-218)
  - `CODE-SEC-FAIL-SAFE-DEFAULTS` includes an `## Inspection` section and a new grep pattern in `code/.context-inspect.md`
  - `SEC-ARCH-SUPPLY-CHAIN-SECURITY` includes inspection patterns for floating CI action refs and undigested Docker base images
  - `groups/security-focused.yaml` updated with all 7 new principle IDs
  - `principles/catalog.yaml` updated: 214 principles across 15 namespaces

- **27 new OOP/object-design principles** across 6 namespaces:
  - **`pkg/` namespace** (new) — Robert Martin's 6 Package/Component Principles: `PKG-REP`, `PKG-CCP`, `PKG-CRP`, `PKG-ADP`, `PKG-SDP`, `PKG-SAP`; new `@pkg` group
  - **`gof/`** — `GOF-LAW-OF-DEMETER` (Law of Demeter, IEEE 1989), `GOF-NULL-OBJECT` (Woolf / Fowler)
  - **`code/cs/`** — `CODE-CS-DESIGN-BY-CONTRACT` (Meyer), `CODE-CS-TELL-DONT-ASK` (Hunt & Thomas), `CODE-CS-INFORMATION-HIDING` (Parnas 1972), `CODE-CS-UNIFORM-ACCESS` (Meyer)
  - **`code-smells/`** — 9 missing Fowler smells: `CODE-SMELLS-LONG-PARAMETER-LIST`, `CODE-SMELLS-DIVERGENT-CHANGE`, `CODE-SMELLS-SHOTGUN-SURGERY`, `CODE-SMELLS-REFUSED-BEQUEST`, `CODE-SMELLS-INSIDER-TRADING`, `CODE-SMELLS-DATA-CLASS`, `CODE-SMELLS-TEMPORARY-FIELD`, `CODE-SMELLS-ALTERNATIVE-CLASSES`, `CODE-SMELLS-GLOBAL-DATA`
  - **`effective-java/`** — 5 new items: `EFFECTIVE-JAVA-PREFER-DEPENDENCY-INJECTION` (Item 5), `EFFECTIVE-JAVA-OVERRIDE-EQUALS-CONTRACT` (Items 10/11), `EFFECTIVE-JAVA-DESIGN-FOR-INHERITANCE` (Item 19), `EFFECTIVE-JAVA-PREFER-INTERFACES` (Item 20), `EFFECTIVE-JAVA-DESIGN-INTERFACES-FOR-POSTERITY` (Item 21)
  - **`ddd/`** — `DDD-SPECIFICATION` (Evans / Fowler)
- All affected `.context-audit.md` and `.context-prime.md` files updated
- All affected `groups/` YAML files updated

- **`fp` namespace** — 20 functional programming principles covering the full FP spectrum:
  - **Layer 1 (universal):** `FP-PURE-FUNCTIONS`, `FP-REFERENTIAL-TRANSPARENCY`, `FP-IMMUTABILITY`, `FP-AVOID-SHARED-MUTABLE-STATE`
  - **Layer 2 (contextual):** `FP-FUNCTION-COMPOSITION`, `FP-HIGHER-ORDER-FUNCTIONS`, `FP-ALGEBRAIC-DATA-TYPES`, `FP-CURRYING`, `FP-PATTERN-MATCHING`, `FP-FUNCTIONAL-CORE-IMPERATIVE-SHELL`, `FP-LAZY-EVALUATION`, `FP-EQUATIONAL-REASONING`, `FP-OPTION-EITHER-TYPES`, `FP-RECURSION`, `FP-TAIL-CALL-OPTIMISATION`, `FP-FUNCTOR-MONAD`, `FP-PERSISTENT-DATA-STRUCTURES`, `FP-POINT-FREE-STYLE`, `FP-TOTALITY`, `FP-MONOIDS-SEMIGROUPS`
- **`@fp` group** — `groups/fp.yaml` bundles all 20 FP principles for functional-first projects
- **11 new language groups** — `@javascript`, `@swift`, `@ruby`, `@php`, `@scala`, `@cpp`, `@c`, `@dart`, `@elixir`, `@haskell`, `@fsharp`; FP principles included where the language has native/idiomatic support
- **Pre-compiled context files** — `principles/fp/.context-prime.md`, `.context-audit.md`, `.context-inspect.md` for fast `/prime` and `/audit` loading
- **Catalog updated** — `principles/catalog.yaml` now covers 207 principles across 14 namespaces

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
