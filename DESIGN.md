# .principles — System Design

This document describes the full architecture of the `.principles` hierarchy system for contributors and adopters.

---

## 1. Overview

**What it is:** A portable, project-local configuration system that tells AI coding agents which software engineering principles apply to your codebase — similar in spirit to `.gitignore`, but for coding guidance.

**Who it is for:**
- **Developers** who want consistent, principle-driven code review and generation across all their projects
- **Teams** who want shared principle sets tailored to their stack (e.g., Spring Boot, React, microservices)
- **Organizations** who want to add company-specific principles alongside the shipped catalog

**How it works:**
1. A catalog of principles lives in `principles/code/` (shipped with this repo)
2. Companies add their own catalogs in `principles/<namespace>/`
3. Projects place `.principles` files in their directories to declare which principles apply
4. The AI resolves a hierarchy of `.principles` files (innermost overrides outermost) and reads the full principle content before coding or reviewing

---

## 2. Catalog Structure

The `principles/` directory is a **namespace container**. Each subdirectory is a namespace with its own catalog.

```
principles/
  code/                  ← shipped catalog (148+ principles)
    catalog.yaml         ← declares namespace: code, id-prefix: CODE
    sd/
      sd-001.md
      sd-002.md
    sec/
      sec-001.md
    api/
      api-001.md
    ...
  solid/                 ← SOLID principles (5 principles)
    catalog.yaml         ← declares namespace: solid, id-prefix: SOLID
    srp.md               → SOLID-SRP
    ocp.md               → SOLID-OCP
    lsp.md               → SOLID-LSP
    isp.md               → SOLID-ISP
    dip.md               → SOLID-DIP
  grasp/                 ← GRASP patterns (9 principles)
    catalog.yaml         ← declares namespace: grasp, id-prefix: GRASP
    information-expert.md → GRASP-INFORMATION-EXPERT
    low-coupling.md       → GRASP-LOW-COUPLING
    ...
  12factor/              ← Twelve-Factor App (12 principles)
    catalog.yaml         ← declares namespace: 12factor, id-prefix: 12FACTOR
    01-codebase.md       → 12FACTOR-01-CODEBASE
    02-dependencies.md   → 12FACTOR-02-DEPENDENCIES
    ...
  owasp/                 ← OWASP Top 10 (10 principles)
    catalog.yaml         ← declares namespace: owasp, id-prefix: OWASP
    a01.md               → OWASP-A01
    a02.md               → OWASP-A02
    ...
  corp/                  ← example: company-added namespace
    catalog.yaml         ← declares namespace: corp, id-prefix: CORP
    corp-0001.md
  arch/                  ← example: architecture principles
    catalog.yaml         ← declares namespace: arch, id-prefix: ARCH
    xx/
      yy/
        yy-01.md
```

### `catalog.yaml` Schema

Each namespace root must have a `catalog.yaml`:

```yaml
namespace: code
id-prefix: CODE
description: "Software engineering principles — design, security, architecture, testing, and more"
```

| Field | Required | Description |
|-------|----------|-------------|
| `namespace` | Yes | Directory name (lowercase) |
| `id-prefix` | Yes | Uppercase prefix for all IDs in this namespace |
| `description` | No | Human-readable description |

The system reads all `principles/*/catalog.yaml` files to route any given ID to its file.

---

## 3. ID Derivation

IDs are **derived from file path** — no separate ID field is needed in the file itself.

### Algorithm

1. Take the path **relative to `principles/`**
2. Split by `/`, drop `.md` extension from the last segment
3. Each **directory** segment → uppercased ID part
4. **Filename** → strip the `<parent-dir-name>-` prefix (case-insensitive), use the remainder as the final ID part
5. Join all parts with `-`

### Examples

| File path (relative to `principles/`) | ID |
|---|---|
| `solid/srp.md` | `SOLID-SRP` |
| `grasp/low-coupling.md` | `GRASP-LOW-COUPLING` |
| `12factor/01-codebase.md` | `12FACTOR-01-CODEBASE` |
| `owasp/a01.md` | `OWASP-A01` |
| `code/api/api-001.md` | `CODE-API-001` |
| `code/sd/sd-001.md` | `CODE-SD-001` |
| `code/sec/sec-001.md` | `CODE-SEC-001` |
| `corp/corp-0001.md` | `CORP-0001` |
| `arch/xx/yy/yy-01.md` | `ARCH-XX-YY-01` |

### Step-by-step: `code/api/api-001.md`

1. Segments: `code`, `api`, `api-001`
2. Dir segments uppercased: `CODE`, `API`
3. Filename `api-001` → strip `api-` prefix → `001`
4. Join: `CODE-API-001`

### Step-by-step: `arch/xx/yy/yy-01.md`

1. Segments: `arch`, `xx`, `yy`, `yy-01`
2. Dir segments: `ARCH`, `XX`, `YY`
3. Filename `yy-01` → strip `yy-` prefix → `01`
4. Join: `ARCH-XX-YY-01`

---

## 4. Principle File Schema

Every principle file follows this template:

```markdown
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

## Good practice

```[language]
// Example showing correct application
```

## Sources

- [Author, *Title*, Publisher, Year. ISBN/DOI/URL]
```

### Fields

| Field | Description |
|-------|-------------|
| `Layer` | 1 = always active, 2 = context-dependent, 3 = risk-elevated |
| `Categories` | Semantic tags for detection (e.g., `api-design`, `security`, `testing`) |
| `Applies-to` | `all` or specific languages, platforms, domains, or architectural contexts |
| `Violations to detect` | Concrete patterns for AI to look for during review |
| `Good practice` | Positive example (AI uses this for generation guidance) |
| `Sources` | At least one verifiable published source |

---

## 5. Groups

Groups bundle related principles under a reusable name. They enable one-line activation of a full principle set for a technology.

### Group File Schema (`groups/<name>.yaml`)

```yaml
name: spring-boot
description: "Spring Boot REST APIs and dependency injection"

includes:
  - java              # resolved from groups/java.yaml

principles:
  - CODE-API-011
  - CODE-API-012
  - CODE-SEC-002
  - CODE-AR-003
```

| Field | Description |
|-------|-------------|
| `name` | Must match filename (without `.yaml`) |
| `description` | Human-readable summary |
| `includes` | Other group names to compose (resolved recursively) |
| `principles` | List of principle IDs this group activates |

### Composition

`includes` is resolved recursively. `spring-data-jpa` includes `spring-boot`, which includes `java` — the result is the full union of all three groups' principles.

**Cycle detection:** The system detects cycles in `includes` chains and raises an error rather than looping infinitely.

### Shipped Groups

| Group | Includes | Purpose |
|-------|----------|---------|
| `solid` | — | All five SOLID principles |
| `grasp` | — | All nine GRASP responsibility patterns |
| `12factor` | — | All twelve Twelve-Factor App practices |
| `owasp` | — | OWASP Top 10 (2021) security risks |
| `java` | — | Java language fundamentals |
| `typescript` | — | TypeScript type safety and patterns |
| `python` | — | Python readability and Pythonic patterns |
| `go` | — | Go composition and concurrency |
| `csharp` | — | C# OOP and async patterns |
| `rust` | — | Rust ownership and type safety |
| `spring-boot` | java | Spring Boot REST and DI |
| `spring-data-jpa` | spring-boot | JPA repositories and aggregates |
| `react` | typescript | React components and hooks |
| `angular` | typescript | Angular components and DI |
| `django` | python | Django models and views |
| `fastapi` | python | FastAPI async endpoints |
| `microservices` | — | Inter-service resilience and observability |
| `security-focused` | — | Security-heavy codebases |

### Rules

- Groups are **additive only** — no exclusions inside groups
- Exclusion is a per-project human decision in `.principles` files
- Groups ship in `groups/` at repo root

---

## 6. `.principles` File Format

Plain text. One entry per line. Filesystem mtime is the implicit last-modified timestamp.

### Syntax

```
# This is a comment (ignored)

# Groups — prefixed with @
@spring-boot
@company-arch

# Bare IDs — direct includes
CODE-OB-004
CORP-0001

# Exclusions — suppresses even if a group activates it
!CODE-API-012
!CODE-TS-001
```

| Syntax | Meaning |
|--------|---------|
| `# ...` | Comment (ignored) |
| `@name` | Include all principles from `groups/name.yaml` (recursive) |
| `ID` | Include a specific principle by ID |
| `!ID` | Exclude a principle (takes final precedence over everything, including Layer 1) |
| blank line | Ignored |

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
    .principles        ← adds CODE-OB-004, !CODE-API-012
    payments/
      .principles      ← adds @security-focused
```

When reviewing `/repo-root/src/payments/PaymentService.java`:
1. Seed with Layer 1 universals
2. Apply `/repo-root/.principles` → expand `@spring-boot` (→ includes `java`)
3. Apply `/repo-root/src/.principles` → add `CODE-OB-004`, mark `CODE-API-012` excluded
4. Apply `/repo-root/src/payments/.principles` → expand `@security-focused`
5. Subtract exclusion set: remove `CODE-API-012`

---

## 7. Commands

### `/prime`

Activates principles before writing code. Run it before starting work on a task.

**Phases:**

| Phase | Name | Description |
|-------|------|-------------|
| 1 | Scan Context | Examines the coding context: language, framework, domain, risk signals |
| 2 | Resolve .principles Hierarchy | Walks to git root, expands groups, builds active ID set |
| 3 | Dynamic Detection (fallback) | Only runs if Phase 2 found no `.principles` files; uses signal-based detection |
| 4 | Read Principle Content | Reads actual `.md` files; extracts full guidance (Violations + Good Practice) |
| 5 | Output | Presents active principles table with source column; states coding frame |

### `/audit`

Reviews code against activated principles. Outputs findings grouped by severity.

**Phases:**

| Phase | Name | Description |
|-------|------|-------------|
| 1 | Resolve Input | Determines what code to review (file, directory, inline) |
| 2 | Resolve .principles Hierarchy | Same walk algorithm as prime |
| 3 | Dynamic Detection (fallback) | Only if no `.principles` files found |
| 4 | Read Principle Content | Reads `.md` files; uses "Violations to detect" sections |
| 5 | Review | Applies each principle; groups findings by severity (Critical/High/Medium/Low) |
| 6 | Summary | Reports findings count; states principle source (hierarchy vs. dynamic detection) |

### `/scout`

Analyses a project directory and creates or updates `.principles` files.

**Phases:**

| Phase | Name | Description |
|-------|------|-------------|
| 1 | Resolve Target | Resolves `$ARGUMENTS` or CWD as the target directory |
| 2 | Detect Profile | Detects language, framework, domain; analyses per-directory profiles |
| 3 | Propose Placements | Proposes `.principles` placements — root + overrides for test dirs, security dirs, submodules |
| 4 | Check Existing | Merges additions only; never removes or touches `!exclusions` |
| 5 | Write Files | Creates or updates files; reports created/updated/unchanged per path |

---

## 8. Adding a New Namespace

To add a company-specific namespace alongside the shipped `code` catalog:

1. **Create the namespace directory:**
   ```bash
   mkdir -p principles/corp
   ```

2. **Create `principles/corp/catalog.yaml`:**
   ```yaml
   namespace: corp
   id-prefix: CORP
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

The system discovers all `principles/*/catalog.yaml` files automatically to route IDs to their files.

---

## 9. ID Format Guidance

### Naming Conventions

- Namespace prefix: uppercase, short (2-6 chars) — `CODE`, `CORP`, `ARCH`
- Category segment: 2-4 uppercase chars — `SD`, `API`, `SEC`, `AR`
- Numeric suffix: zero-padded to 3 digits for top-level (`001`), fewer digits acceptable for deep nesting
- Named files: when a file name does not start with the parent directory name followed by `-`, the full filename is used verbatim as the final ID segment (e.g., `solid/srp.md` → `SOLID-SRP`, `owasp/a01.md` → `OWASP-A01`). Numeric prefixes work the same way (e.g., `12factor/01-codebase.md` → `12FACTOR-01-CODEBASE`).
- Avoid: special characters, spaces, mixed case

### Depth Recommendations

| Depth | Use when | Example |
|-------|---------|---------|
| 2 levels: `NS/CAT` | ≤20 principles per category | `CODE-SD-001` |
| 3 levels: `NS/CAT/SUB` | Large category needing sub-grouping | `ARCH-CLOUD-K8S-001` |

Keep paths shallow. Deep nesting makes IDs hard to read and reference.

### When to Add a New Category

Add a new category directory when:
- The topic is distinct enough to warrant its own group (e.g., `security`, `testing`)
- You have at least 3 principles in the category
- Existing categories don't fit well

---

## 10. Contributing Principles

### Requirements

Every new principle must have:
- A clear principle description in your own words
- At least one verifiable published source (book with ISBN, paper with DOI, or authoritative URL)
- Correct layer assignment (1 = universal, 2 = contextual, 3 = risk-elevated)
- At least one "Violations to detect" entry

### Process

1. Copy `principles/code/TEMPLATE.md` to the appropriate category directory
2. Fill in all fields
3. Derive the ID from the file path (Section 3)
4. Add the principle to relevant groups in `groups/`
5. Submit a pull request with:
   - The principle file
   - Group file updates
   - A brief rationale for the source choice

### Source Requirements

Acceptable sources:
- Books: full citation with ISBN (e.g., *Effective Java* by Bloch, 3rd ed., ISBN 978-0134685991)
- Papers: DOI or stable URL
- Authoritative specifications: RFC, OWASP, IEEE standard with URL

Not acceptable:
- Blog posts without named authors
- Stack Overflow answers
- Undated sources
