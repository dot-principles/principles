# .principles — System Design

This document describes the full architecture of the `.principles` hierarchy system for contributors and adopters.

---

## 🗺️ 1. Overview

**What it is:** A portable, project-local configuration system that tells AI coding agents which software engineering principles apply to your codebase — similar in spirit to `.gitignore`, but for coding guidance.

**Philosophy:** `.principles` does not teach the AI anything — the AI already knows SOLID, OWASP, DDD, and the rest. It *focuses and triggers* that knowledge: giving the AI context about which principles matter for this codebase, alongside other AI instructions (AGENTS.md, CLAUDE.md, `.github/copilot-instructions.md`). The AI instructions tell the agent how to behave; `.principles` tells it which engineering lens to apply.

> See [DISCLAIMER.md](DISCLAIMER.md) — this is a proof of concept. Groups are opinionated, gaps exist, and the catalog is not exhaustive.

**Who it is for:**
- **Developers** who want consistent, principle-driven code review and generation across all their projects
- **Teams** who want shared principle sets tailored to their stack (e.g., Spring Boot, React, microservices)
- **Organizations** who want to add company-specific principles alongside the shipped catalog

**How it works:**
1. A catalog of principles lives in `principles/code/` (shipped with this repo)
2. Companies add their own catalogs in `principles/<namespace>/`
3. Projects place `.principles` files in their directories to declare which principles apply
4. The AI resolves a hierarchy of `.principles` files (innermost overrides outermost) and reads the full principle content before coding or reviewing

**Plain-Text-as-Code:** This repo is a **Plain-Text-as-Code** system. Every artefact is plain text in version control — diffable, composable, portable, and natively readable by both humans and AI tools. Principle files are Markdown, group files are YAML, and the catalog is YAML. No binary formats, no generated code, no lock-in.

---

## 📁 2. Catalog Structure

The `principles/` directory is a **namespace container**. Each subdirectory is a namespace with its own catalog.

```
principles/
  code/                  ← general catalog (~88 principles)
    catalog.yaml         ← description only
    sec/
      validate-input.md
    api/
      standard-http-methods.md
    ...
  solid/                 ← SOLID principles (5 principles)
    catalog.yaml         ← description only
    srp.md               → SOLID-SRP
    ocp.md               → SOLID-OCP
    lsp.md               → SOLID-LSP
    isp.md               → SOLID-ISP
    dip.md               → SOLID-DIP
  gof/                   ← Gang of Four (25 entries)
    catalog.yaml         ← description only
    strategy.md          → GOF-STRATEGY
    observer.md          → GOF-OBSERVER
    ...
  ddd/                   ← Domain-Driven Design (8 principles)
    catalog.yaml         ← description only
    aggregate.md         → DDD-AGGREGATE
    repository.md        → DDD-REPOSITORY
    ...
  simple-design/         ← Kent Beck's 4 Rules (4 principles)
    catalog.yaml         ← description only
    passes-tests.md      → SIMPLE-DESIGN-PASSES-TESTS
    ...
  clean-arch/            ← Clean Architecture (4 principles)
    catalog.yaml         ← description only
    dependency-rule.md   → CLEAN-ARCH-DEPENDENCY-RULE
    ...
  effective-java/        ← Effective Java (10 principles)
    catalog.yaml         ← description only
    static-factory.md    → EFFECTIVE-JAVA-STATIC-FACTORY
    ...
  code-smells/           ← Fowler code smells (9 principles)
    catalog.yaml         ← description only
    long-method.md       → CODE-SMELLS-LONG-METHOD
    feature-envy.md      → CODE-SMELLS-FEATURE-ENVY
    ...
  grasp/                 ← GRASP patterns (9 principles)
    catalog.yaml         ← description only
    information-expert.md → GRASP-INFORMATION-EXPERT
    low-coupling.md       → GRASP-LOW-COUPLING
    ...
  12factor/              ← Twelve-Factor App (12 principles)
    catalog.yaml         ← description only
    01-codebase.md       → 12FACTOR-01-CODEBASE
    02-dependencies.md   → 12FACTOR-02-DEPENDENCIES
    ...
  owasp/                 ← OWASP Top 10 (10 principles)
    catalog.yaml         ← description only
    01-broken-access-control.md  → OWASP-01-BROKEN-ACCESS-CONTROL
    02-cryptographic-failures.md → OWASP-02-CRYPTOGRAPHIC-FAILURES
    ...
  corp/                  ← example: company-added namespace
    catalog.yaml         ← description only
    corp-0001.md
  arch/                  ← example: architecture principles
    catalog.yaml         ← description only
    xx/
      yy/
        yy-01.md
```

### Pre-compiled context files

Each namespace contains two pre-compiled files that consolidate all its principle guidance into a single read per command invocation:

| File | Used by | Contains |
|------|---------|----------|
| `.context-prime.md` | `/prime` Phase 4 | Principle statement, Why it matters, Good practice — for all principles in the namespace |
| `.context-audit.md` | `/audit` Phase 4 | Principle statement, Violations to detect — for all principles in the namespace |
| `.context-inspect.md` | `/audit` Phase 5 | Machine-executable pre-scan patterns (grep/awk/find commands) — for principles with deterministic inspection patterns |

The command reads one file per namespace and filters to only the entries in the final active set. This avoids reading N individual principle files.

### `.context-inspect.md` Format

Pre-compiled inspection patterns for `/audit` Phase 5 (Pre-Scan). Each principle's entry contains bash commands that produce `file:line:match` output:

```markdown
# .principles inspect context — <namespace>
# Machine-executable pre-scan patterns per principle

### CODE-SEC-VALIDATE-INPUT

- `grep -rnE 'eval\(|exec\(' --include="*.py" $TARGET` | HIGH | Direct eval/exec calls
- `grep -rnE '\.query\(.*\+' --include="*.py" $TARGET` | HIGH | String concat in queries
```

Format: `` - `command` | SEVERITY_HINT | description ``

- `$TARGET` is replaced with the actual scan path at runtime
- Commands must use only POSIX + bash 4+ tools: `grep`, `find`, `wc`, `awk`, `sort`
- Principles without inspection patterns are absent from this file and are handled by LLM-only reasoning

### `catalog.yaml` Schema

Each namespace root must have a `catalog.yaml` with a single field:

```yaml
# principles/<namespace>/catalog.yaml
description: "Human-readable description of this namespace"
```

| Field | Required | Description |
|-------|----------|-------------|
| `description` | Yes | Human-readable description of the namespace |

The namespace is the directory name. IDs are derived from file paths (see Section 3) — no explicit `namespace` or `id-prefix` fields are needed. The system discovers all `principles/*/catalog.yaml` files automatically.

---

## 🔑 3. ID Derivation

IDs are **derived from file path** — no separate ID field is needed in the file itself.

### Algorithm

1. Take the path **relative to `principles/`**
2. Split by `/`, drop `.md` extension from the last segment
3. Each **directory** segment → uppercased ID part
4. **Filename** → strip the `<parent-dir-name>-` prefix (case-insensitive), use the remainder as the final ID part
5. Join all parts with `-`

### Examples

| File path (relative to `principles/`) | ID                               |
|---------------------------------------|----------------------------------|
| `solid/srp.md`                        | `SOLID-SRP`                      |
| `gof/strategy.md`                     | `GOF-STRATEGY`                   |
| `ddd/aggregate.md`                    | `DDD-AGGREGATE`                  |
| `code-smells/feature-envy.md`         | `CODE-SMELLS-FEATURE-ENVY`       |
| `grasp/low-coupling.md`               | `GRASP-LOW-COUPLING`             |
| `12factor/01-codebase.md`             | `12FACTOR-01-CODEBASE`           |
| `owasp/01-broken-access-control.md`   | `OWASP-01-BROKEN-ACCESS-CONTROL` |
| `code/api/standard-http-methods.md`   | `CODE-API-STANDARD-HTTP-METHODS` |
| `code/sec/validate-input.md`          | `CODE-SEC-VALIDATE-INPUT`        |
| `corp/corp-0001.md`                   | `CORP-0001`                      |
| `arch/xx/yy/yy-01.md`                 | `ARCH-XX-YY-01`                  |

### Step-by-step: `code/api/standard-http-methods.md`

1. Segments: `code`, `api`, `standard-http-methods`
2. Dir segments uppercased: `CODE`, `API`
3. Filename `standard-http-methods` → does not start with `api-`, use verbatim: `STANDARD-HTTP-METHODS`
4. Join: `CODE-API-STANDARD-HTTP-METHODS`

### Step-by-step: `arch/xx/yy/yy-01.md`

1. Segments: `arch`, `xx`, `yy`, `yy-01`
2. Dir segments: `ARCH`, `XX`, `YY`
3. Filename `yy-01` → strip `yy-` prefix → `01`
4. Join: `ARCH-XX-YY-01`

---

## 📄 4. Principle File Schema

Every principle file follows this template:

````markdown
# [ID]: [Title]

**Layer**: [1 | 2 | 3]
**Categories**: [comma-separated]
**Applies-to**: [all | comma-separated — languages, platforms, domains, or contexts]

## Principle

[Clear, authoritative statement of the principle in 1-3 sentences.]

## Why it matters

[Explanation of the consequences of ignoring this principle — bugs, maintenance debt, security risks, etc.]

## Violations to detect

- [Specific code pattern that violates this principle]
- [Another violation pattern]

## Inspection

<!-- Optional — see "Inspection" field guidance below. -->

## Good practice

```[language]
// Example showing correct application
```

## Sources

- [Author, *Title*, Publisher, Year. ISBN/DOI/URL]
````

### Fields

| Field                  | Description                                                                |
|------------------------|----------------------------------------------------------------------------|
| `Layer`                | 1 = always active, 2 = context-dependent, 3 = risk-elevated                |
| `Categories`           | Semantic tags for detection (e.g., `api-design`, `security`, `testing`)    |
| `Applies-to`           | `all` or specific languages, platforms, domains, or architectural contexts |
| `Violations to detect` | Concrete patterns for AI to look for during review                         |
| `Inspection`           | Optional. Machine-executable pre-scan commands for `/audit` Phase 5. See guidance below |
| `Good practice`        | Positive example (AI uses this for generation guidance)                    |
| `Sources`              | At least one verifiable published source                                   |

**Diagrams:** Include a `mermaid` code block in the *Good practice* section whenever the concept has a structural form (class hierarchies, relationships, flows). Mermaid adds machine-readable semantics. If you can draw it, draw it.

### `## Inspection` — When to Add

The `## Inspection` section is **optional**. It contains bash commands that `/audit` Phase 5 runs to flag likely violations *before* the LLM reads the code. Not every principle is a good fit.

**Add inspection patterns when** the violation has a textual signature that grep/awk/find can match reliably — e.g., `eval(`, empty `catch {}` blocks, files over 300 lines. These are surface-level patterns that narrow the search space for the LLM.

**Do not add inspection patterns when** the violation requires understanding intent, context, or design — e.g., whether a class has too many responsibilities (SRP beyond line count), whether an abstraction is premature (YAGNI), whether naming reveals intent, or whether a system follows Postel's Law. These are **semantic-only** principles that only an LLM can evaluate.

**Rule of thumb:** if you cannot write a grep pattern that produces fewer than ~30% false positives on a typical codebase, leave the section empty. A noisy pre-scan is worse than none.

**Format:** each entry is a fenced command, a severity hint, and a short description:

```
- `grep -rnE 'eval\(' --include="*.py" $TARGET` | HIGH | Direct eval calls
```

- `$TARGET` is replaced with the scan path at runtime
- Commands must use only POSIX + bash 4+ tools: `grep`, `find`, `wc`, `awk`, `sort`
- Output should be `file:line:match` format (`grep -rn` default)
- When adding patterns, also add the entry to the namespace's `.context-inspect.md`

---

## 🗂️ 5. Groups

Groups bundle related principles under a reusable name. They enable one-line activation of a full principle set for a technology.

### Group File Schema (`groups/<name>.yaml`)

```yaml
name: spring-boot
description: "Spring Boot REST APIs and dependency injection"

includes:
  - java              # resolved from groups/java.yaml

principles:
  - CODE-API-STANDARD-HTTP-METHODS
  - CODE-API-HATEOAS
  - CODE-SEC-VALIDATE-INPUT
  - ARCH-STATELESS-FIRST
```

| Field         | Description                                         |
|---------------|-----------------------------------------------------|
| `name`        | Must match filename (without `.yaml`)               |
| `description` | Human-readable summary                              |
| `includes`    | Other group names to compose (resolved recursively) |
| `principles`  | List of principle IDs this group activates          |

### Composition

`includes` is resolved recursively. `spring-data-jpa` includes `spring-boot`, which includes `java` — the result is the full union of all three groups' principles.

**Cycle detection:** The system detects cycles in `includes` chains and raises an error rather than looping infinitely.

### Shipped Groups

| Group              | Includes         | Purpose                                         |
|--------------------|------------------|-------------------------------------------------|
| `solid`            | —                | All five SOLID principles                       |
| `gof`              | —                | All 25 GoF entries (2 principles + 23 patterns) |
| `gof-creational`   | —                | 5 GoF creational patterns                       |
| `gof-structural`   | —                | 7 GoF structural patterns                       |
| `gof-behavioral`   | —                | 11 GoF behavioral patterns                      |
| `ddd`              | —                | 8 Domain-Driven Design building blocks          |
| `simple-design`    | —                | Kent Beck's 4 Rules of Simple Design            |
| `clean-arch`       | —                | 4 Clean Architecture principles                 |
| `effective-java`   | —                | 10 Effective Java best practices                |
| `code-smells`      | —                | 9 Fowler code smells                            |
| `grasp`            | —                | All nine GRASP responsibility patterns          |
| `12factor`         | —                | All twelve Twelve-Factor App practices          |
| `owasp`            | —                | OWASP Top 10 (2021) security risks              |
| `java`             | effective-java   | Java language fundamentals                      |
| `typescript`       | —                | TypeScript type safety and patterns             |
| `python`           | —                | Python readability and Pythonic patterns        |
| `go`               | —                | Go composition and concurrency                  |
| `csharp`           | solid            | C# OOP and async patterns                       |
| `rust`             | —                | Rust ownership and type safety                  |
| `spring-boot`      | java             | Spring Boot REST and DI                         |
| `spring-data-jpa`  | spring-boot, ddd | JPA repositories and aggregates                 |
| `react`            | typescript       | React components and hooks                      |
| `angular`          | typescript       | Angular components and DI                       |
| `django`           | python           | Django models and views                         |
| `fastapi`          | python           | FastAPI async endpoints                         |
| `microservices`    | —                | Inter-service resilience and observability      |
| `security-focused` | owasp            | Security-heavy codebases                        |

### Rules

- Groups are **additive only** — no exclusions inside groups
- Exclusion is a per-project human decision in `.principles` files
- Groups ship in `groups/` at repo root

---

## 📝 6. `.principles` File Format

Plain text. One entry per line. Filesystem mtime is the implicit last-modified timestamp.

### Syntax

```
# This is a comment (ignored)

# Groups — prefixed with @
@spring-boot
@company-arch

# Bare IDs — direct includes
CODE-OB-SERVICE-LEVEL-OBJECTIVES
CORP-0001

# Exclusions — suppresses even if a group activates it
!CODE-API-HATEOAS
!CODE-TS-TEST-FIRST
```

| Syntax     | Meaning                                                                         |
|------------|---------------------------------------------------------------------------------|
| `# ...`    | Comment (ignored)                                                               |
| `:directive value` | Configuration directive (see below)                                    |
| `@name`    | Include all principles from `groups/name.yaml` (recursive)                      |
| `ID`       | Include a specific principle by ID                                              |
| `!ID`      | Exclude a principle (takes final precedence over everything, including Layer 1) |
| blank line | Ignored                                                                         |

### Directives

Lines starting with `:` are configuration directives:

| Directive | Example | Description |
|-----------|---------|-------------|
| `:max_principles` | `:max_principles 15` | Cap the total number of active principles. When trimming: Layer 1 is always retained, then Layer 3 risk-elevated, then Layer 2 context-dependent (dropped first). If Layer 1 alone exceeds the cap, the cap applies only to non-Layer-1 principles. |

IDs are matched case-insensitively.

### Hierarchy Walk Algorithm

Walk **up** from the file or directory being reviewed to the git repo root (detected by `.git/` presence) or a maximum of 10 levels.

Collect all `.principles` files encountered, ordered **root → target** (outermost first, innermost last).

**Resolution:**

1. `active = { Layer 1 universals }` — always seeded
2. For each `.principles` file (root → target):
   - Expand each `@group` recursively → union into active
   - Union bare IDs into active
   - Union `!ID` into exclusion set
3. `final = active MINUS exclusions`
4. Read full content of each ID's `.md` file from its catalog

**Key properties:**
- Inner `.principles` files extend (not replace) outer ones
- `!ID` exclusions suppress even Layer 1 principles
- The algorithm terminates at the git root, not the filesystem root

### Example Hierarchy

```
/repo-root/
  .principles          ← root file: @spring-boot
  src/
    .principles        ← adds CODE-OB-SERVICE-LEVEL-OBJECTIVES, !CODE-API-HATEOAS
    payments/
      .principles      ← adds @security-focused
```

When reviewing `/repo-root/src/payments/PaymentService.java`:
1. Seed with Layer 1 universals
2. Apply `/repo-root/.principles` → expand `@spring-boot` (→ includes `java`)
3. Apply `/repo-root/src/.principles` → add `CODE-OB-SERVICE-LEVEL-OBJECTIVES`, mark `CODE-API-HATEOAS` excluded
4. Apply `/repo-root/src/payments/.principles` → expand `@security-focused`
5. Subtract exclusion set: remove `CODE-API-HATEOAS`

---

## 🛠️ 7. Commands

### ⚡ `/prime`

Activates principles before writing code. Run it before starting work on a task.

**Phases:**

| Phase | Name                          | Description                                                                                    |
|-------|-------------------------------|------------------------------------------------------------------------------------------------|
| 1     | Scan Context                  | Examines the coding context: language, framework, domain, risk signals                         |
| 2     | Resolve .principles Hierarchy | Walks to git root, expands groups, builds active ID set                                        |
| 3     | Dynamic Detection (fallback)  | Only runs if Phase 2 found no `.principles` files; uses signal-based detection                 |
| 4     | Load Principle Content        | Reads one `.context-prime.md` per namespace (pre-compiled); filters to active IDs              |
| 5     | Output                        | Presents active principles table with source column; states coding frame                       |

### 🔎 `/audit`

Reviews code against activated principles. Outputs findings grouped by severity.

**Phases:**

| Phase | Name                          | Description                                                                                    |
|-------|-------------------------------|------------------------------------------------------------------------------------------------|
| 1     | Resolve Input                 | Determines what code to review (file, directory, inline)                                       |
| 2     | Resolve .principles Hierarchy | Same walk algorithm as prime; supports `:max_principles` directive                             |
| 3     | Dynamic Detection (fallback)  | Only if no `.principles` files found                                                           |
| 4     | Load Principle Content        | Reads one `.context-audit.md` per namespace (pre-compiled); filters to active IDs             |
| 5     | Pre-Scan                      | Reads `.context-inspect.md` per namespace; runs bash commands to build pre-scan manifest       |
| 6     | Review                        | Guided review (hits) + semantic-only review + opportunistic findings                           |
| 7     | Output                        | Compact text report + `audit-output.json` written to repo root; reports principle source       |

### 🔍 `/scout`

Analyses a project directory and creates or updates `.principles` files.

**Phases:**

| Phase | Name               | Description                                                                                   |
|-------|--------------------|-----------------------------------------------------------------------------------------------|
| 1     | Resolve Target     | Resolves `$ARGUMENTS` or CWD as the target directory                                          |
| 2     | Detect Profile     | Detects language, framework, domain; analyses per-directory profiles                          |
| 3     | Propose Placements | Proposes `.principles` placements — root + overrides for test dirs, security dirs, submodules |
| 4     | Check Existing     | Merges additions only; never removes or touches `!exclusions`                                 |
| 5     | Write Files        | Creates or updates files; reports created/updated/unchanged per path                          |

---

## 📦 8. Installer Targets

`install.sh` deploys the three commands (`/scout`, `/prime`, `/audit`) to three AI tool families. Each target writes different files because each tool family has its own discovery mechanism.

**Prerequisites:** Bash 4+. See [REQUIREMENTS.md](REQUIREMENTS.md). On Windows, use `install.ps1` (PowerShell) or `install.cmd` (CMD) — thin wrappers that detect bash and forward all arguments to `install.sh`. See [INSTALL.md](INSTALL.md) for platform-specific instructions.

Every target supports two scopes — **global** (no directory argument) applies across all projects, **local** (with a directory argument) applies to a single project:

| Command | Scope | Where |
|---|---|---|
| `./install.sh claude` | Global | `~/.claude/commands/` |
| `./install.sh claude <dir>` | Local | `<dir>/.claude/commands/` |
| `./install.sh copilot` | Global | `~/.copilot/copilot-instructions.md` |
| `./install.sh copilot <dir>` | Local | `<dir>/.github/` |
| `./install.sh cursor` | — | Not supported (see below) |
| `./install.sh cursor <dir>` | Local | `<dir>/.cursor/rules/code-principles.mdc` |
| `./install.sh all` | Global | Claude + Copilot globally; Cursor message |
| `./install.sh all <dir>` | Local | All three tools in `<dir>` |
| `./install.sh --list` | — | Reports what is currently installed globally |

### 🤖 Claude Code (`./install.sh claude [dir]`)

Copies `targets/claude-code/*.md` to the commands directory, substituting the `{{PRINCIPLES_DIRECTORY}}` placeholder with the data directory path.

**Data directory (`~/.principles`):** Every Claude install (global or local) also copies `groups/` and `principles/` from the repo into `~/.principles` (`%USERPROFILE%\.principles` on Windows). This is done via `install_data()` before the command files are written. The data directory is refreshed on every install — old files are removed and current repo files are copied in.

**Placeholder substitution:** The source files in `targets/claude-code/` contain the literal string `{{PRINCIPLES_DIRECTORY}}` wherever they reference the data catalog. `install.sh` runs `sed "s|{{PRINCIPLES_DIRECTORY}}|$DATA_DIR|g"` when writing to the commands directory, so the installed copies always reference the correct absolute path. The placeholder is left untouched in the source files.

Claude Code discovers slash commands by scanning `~/.claude/commands/` (global) or `<dir>/.claude/commands/` (local) for `.md` files. The file body is the full prompt. No frontmatter is required.

### 🐙 GitHub Copilot (`./install.sh copilot [dir]`)

**Global** (`copilot` with no argument): writes `~/.copilot/copilot-instructions.md` with the Layer 1–3 principle summary. This is consumed by all Copilot clients as always-on background context.

**Local** (`copilot <dir>`): writes three sets of files:

| File | Location | Consumed by |
|------|----------|-------------|
| `copilot-instructions.md` | `.github/copilot-instructions.md` | All Copilot clients (always-on context) |
| `SKILL.md` | `.github/skills/<name>/SKILL.md` | **Copilot CLI** (terminal slash commands) |
| `<name>.prompt.md` | `.github/prompts/<name>.prompt.md` | **VS Code / JetBrains / Visual Studio** (IDE chat) |

**Skills** (`.github/skills/<name>/SKILL.md`) are the CLI mechanism. The Copilot CLI scans `.github/skills/` at startup, reads each `SKILL.md`, and exposes the skill as a `/skill-name` slash command. Skills require a YAML frontmatter with `name` and `description`; the `description` is also used by Copilot to decide when to invoke the skill automatically.

**Prompt files** (`.github/prompts/<name>.prompt.md`) are the IDE mechanism. Copilot Chat in VS Code, JetBrains, and Visual Studio discovers `.prompt.md` files in `.github/prompts/` and exposes them as slash commands in the chat panel. They use YAML frontmatter with `description:` and `mode: agent` — agent mode enables file reading, tool use, and shell execution, which `/audit` (pre-scan commands, writing `audit-output.json`) and `/scout` (writing `.principles` files) require.

This repo ships with pre-populated `.github/prompts/` and `.github/skills/` directories so that contributors working in this repo itself get `/scout`, `/prime`, and `/audit` in Copilot without running the installer.

### 🖱️ Cursor (`./install.sh cursor <dir>`)

Writes to `<dir>/.cursor/rules/code-principles.mdc`.

Cursor discovers rules by scanning `.cursor/rules/` for `.mdc` files. The frontmatter `alwaysApply: true` makes the rule active in all contexts.

**Cursor limitation:** Cursor has no file-based user-level config. Global principles require manual setup via **Cursor → Settings → General → Rules for AI**.

### 🗑️ Uninstall (`./uninstall.sh [dir]`)

Removes the assets written by `install.sh`. Without an argument, removes global assets — command files from `~/.claude/commands/` and the `~/.principles` data directory. With a directory argument, removes local assets from that project only; the shared data directory is left intact. On Windows, use `uninstall.ps1` or `uninstall.cmd`.

---

## ➕ 9. Adding a New Namespace

To add a company-specific namespace alongside the shipped `code` catalog:

1. **Create the namespace directory:**
   ```bash
   mkdir -p principles/corp
   ```

2. **Create `principles/corp/catalog.yaml`:**
   ```yaml
   description: "Acme Corp engineering standards"
   ```

3. **Add principle files** following the file schema (Section 4):
   ```
   principles/corp/corp-0001.md    → CORP-0001
   principles/corp/infra/infra-001.md → CORP-INFRA-001
   ```

4. **Reference in `.principles` files:**
   ```
   CORP-0001
   CORP-INFRA-001
   ```

The system discovers all `principles/*/catalog.yaml` files automatically. The namespace is the directory name and IDs are derived from file paths.

---

## 🏷️ 10. ID Format Guidance

### Naming Conventions

- Namespace prefix: uppercase, short (2-6 chars) — `CODE`, `CORP`, `ARCH`
- Category segment: 2-4 uppercase chars — `SD`, `API`, `SEC`, `AR`
- Named files: the full filename is used verbatim as the final ID segment (e.g., `solid/srp.md` → `SOLID-SRP`, `code/api/standard-http-methods.md` → `CODE-API-STANDARD-HTTP-METHODS`, `owasp/01-broken-access-control.md` → `OWASP-01-BROKEN-ACCESS-CONTROL`). Numeric prefixes work the same way (e.g., `12factor/01-codebase.md` → `12FACTOR-01-CODEBASE`).
- Prefer descriptive slugs to opaque numbers — `validate-input.md` is immediately clear; `sec-001.md` is not.
- Avoid: special characters, spaces, mixed case

### Depth Recommendations

| Depth                  | Use when                            | Example              |
|------------------------|-------------------------------------|----------------------|
| 2 levels: `NS/CAT`     | ≤20 principles per category         | `SOLID-SRP`          |
| 3 levels: `NS/CAT/SUB` | Large category needing sub-grouping | `CODE-API-STANDARD-HTTP-METHODS` |

Keep paths shallow. Deep nesting makes IDs hard to read and reference.

### When to Add a New Category

Add a new category directory when:
- The topic is distinct enough to warrant its own group (e.g., `security`, `testing`)
- You have at least 3 principles in the category
- Existing categories don't fit well

---

## 🤝 11. Contributing Principles

See [CONTRIBUTING.md](CONTRIBUTING.md) for requirements, process, and source guidelines.
