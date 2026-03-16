# Changelog

All notable changes to `.principles` will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/), and this project adheres to [Semantic Versioning](https://semver.org/).

> **Note:** `.principles` is in its early days — this is an experimental release. The system is being actively used and iterated on, but expect rough edges, evolving formats, and breaking changes as things stabilize.

---

## [Unreleased]

### Added

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

[v0.1.0]: https://github.com/code-principles/principles/releases/tag/v0.1.0
