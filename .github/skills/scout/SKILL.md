---
name: scout
description: Analyse the project, detect language/framework/domain, and create or update .principles files. Use this skill when asked to scout, detect project profile, or set up principles.
license: MIT
---

# Scout

You are analysing a project to determine which principles apply and creating or updating `.principles` files to encode that. Follow these five phases exactly.

## Phase 1 — Resolve Target

Determine the target directory:

- If `$ARGUMENTS` is a **directory path**: use it as the target.
- If `$ARGUMENTS` is **empty**: use the current working directory.
- If `$ARGUMENTS` is a **file path**: use its containing directory.

Confirm the target exists. If not, report an error and stop.

Walk up from the target to find the **git root** (directory containing `.git/`). Record both the target directory and the git root — the hierarchy spans between them.

## Phase 2 — Detect Profile

Analyse the target directory (and subdirectories) to build a profile per directory. For each directory, detect:

### Code artifact signals

| Signal | Language / Framework |
|--------|---------------------|
| `*.java`, `pom.xml`, `build.gradle` | Java |
| `*.ts`, `tsconfig.json` | TypeScript |
| `*.py`, `pyproject.toml`, `requirements.txt` | Python |
| `*.go`, `go.mod` | Go |
| `*.cs`, `*.csproj`, `*.sln` | C# |
| `*.rs`, `Cargo.toml` | Rust |
| `*.rb`, `Gemfile` | Ruby |
| `*.php`, `composer.json` | PHP |
| `@SpringBootApplication`, `spring-boot` in build file | Spring Boot |
| `@Entity`, `spring-data-jpa` dependency | Spring Data JPA |
| `react`, `jsx`, `tsx` imports | React |
| `@NgModule`, `@Component` | Angular |
| `django` in requirements | Django |
| `fastapi` import | FastAPI |
| `express` in package.json | Express |

### Domain signals (for code artifact type)

| Signal | Domain |
|--------|--------|
| `payment`, `billing`, `invoice`, `stripe`, `checkout` | Financial |
| `auth`, `login`, `oauth`, `jwt`, `session` | Authentication |
| `user`, `profile`, `email`, `address`, `PII` | Personal data |
| `microservice`, `service-mesh`, `saga` | Distributed systems |

### Non-code artifact type signals

| Directory / files | Artifact type | Group |
|-------------------|---------------|-------|
| `docs/`, `*.md` files (README, DESIGN, ADR, CONTRIBUTING) | docs | `@docs` |
| `.github/workflows/`, `Jenkinsfile`, `*.gitlab-ci.yml`, `azure-pipelines.yml` | pipeline | `@pipeline` |
| `*.tf`, `*.tfvars`, `Dockerfile`, `docker-compose.*`, `Chart.yaml`, `k8s/`, `infra/`, `terraform/` | infra | `@infra` |
| `*.proto`, `*.graphql`, `openapi.yaml`, `swagger.yaml`, `schema.sql` | schema | `@schema` |
| `.env`, `application.yaml`, `appsettings.json`, `*.properties` | config | `@config` |

### Per-directory profiling

For projects with multiple subdirectories, detect profiles per directory:
- `src/main/` vs `src/test/` — different testing principles for test dirs
- `src/security/`, `src/auth/` — security-focused principles
- `frontend/`, `ui/`, `web/` — UI interaction principles
- `docs/`, `doc/` — documentation principles (`@docs`)
- `infra/`, `terraform/`, `k8s/`, `deploy/` — infrastructure principles (`@infra`)
- `.github/workflows/` — pipeline principles (`@pipeline`)

Record a profile map: `{ directory → [detected groups] }`

## Phase 3 — Propose .principles Placements

Based on the profile map from Phase 2, propose where to place `.principles` files and what to put in each.

### Placement strategy

1. **Git root `.principles`**: Activate groups that apply to the whole project
2. **Subdirectory `.principles`**: Activate additional groups or exclude principles that don't apply to that subtree

### Available groups (from `{{PRINCIPLES_DIRECTORY}}/groups/`)

Reference these groups by their filename (without `.yaml`):

**Language groups:** `java`, `typescript`, `python`, `go`, `csharp`, `rust`
**Framework groups:** `spring-boot`, `spring-data-jpa`, `react`, `angular`, `django`, `fastapi`
**Cross-cutting code groups:** `microservices`, `security-focused`
**Artifact-type groups:** `docs`, `infra`, `config`, `schema`, `pipeline`

Also list any custom groups found in `{{PRINCIPLES_DIRECTORY}}/groups/` that aren't listed above.

### Proposal format

For each proposed file, show:
```
[path]/.principles
  @group1          ← reason
  @group2          ← reason
  CODE-OB-SERVICE-LEVEL-OBJECTIVES      ← specific principle for this directory
  !CODE-TS-TEST-FIRST     ← exclusion and why
```

Ask for confirmation before writing: "I propose creating/updating N .principles files. Proceed? (yes to write, no to review proposals)"

Wait for user confirmation. If the user says no or requests changes, adjust proposals and ask again.

## Phase 4 — Check Existing .principles Files

Before writing, check for existing `.principles` files at the proposed paths.

For each existing file:
- Read its current contents
- Preserve all existing entries (including `!exclusions` and comments)
- Only **add** new entries that aren't already present
- **Never remove** existing entries — that is the human's decision
- If the file already has all proposed additions, mark it as **unchanged**

Determine final action per file: `created` | `updated` | `unchanged`

## Phase 5 — Write Files and Report

Write or update each file as determined in Phase 4.

### File format

```
# Generated by /scout
# Detected: [artifact-type] / [language/framework/domain]
# Last analysed: [date]

@group1
@group2

# Direct includes
CODE-OB-SERVICE-LEVEL-OBJECTIVES
```

Do not add comments to lines that were already present in an existing file — only add comments to newly added entries.

### Report

After writing, output:

```
.principles analysis complete

Files written:
  ✓ created   /path/to/.principles         (@spring-boot, @security-focused)
  ✓ created   /path/to/docs/.principles    (@docs)
  ✓ updated   /path/to/src/.principles     (added @react)
  — unchanged /path/to/infra/.principles   (no changes needed)

Active groups resolved:
  @spring-boot → @java, CODE-API-STANDARD-HTTP-METHODS, DDD-REPOSITORY, OWASP-03-INJECTION ... (N principles)
  @docs → DOC-PURPOSE, DOC-MINIMAL, DOC-AUDIENCE, DOC-ACCURACY, DOC-EXAMPLES, DOC-PROGRESSIVE-DISCLOSURE ... (N principles)

Next steps:
  - Run /prime to activate principles before writing
  - Run /audit <file> to review against these principles
  - Edit .principles files manually to add !exclusions or direct principle IDs
```
