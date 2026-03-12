#!/usr/bin/env bash
set -euo pipefail

# install.sh — Deploy .principles to AI coding tools
#
# Usage:
#   ./install.sh claude              # Install Claude Code slash commands
#   ./install.sh copilot [project]   # Generate Copilot instructions for a project
#   ./install.sh cursor [project]    # Generate Cursor rules for a project
#   ./install.sh all [project]       # Install all targets
#   ./install.sh --uninstall         # Remove Claude Code commands
#   ./install.sh --list              # Show what's installed

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_COMMANDS_DIR="$HOME/.claude/commands"

# Colors (if terminal supports them)
if [ -t 1 ]; then
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    RED='\033[0;31m'
    BOLD='\033[1m'
    NC='\033[0m'
else
    GREEN='' YELLOW='' RED='' BOLD='' NC=''
fi

print_header() {
    echo ""
    echo -e "${BOLD}.principles installer${NC}"
    echo "─────────────────────────"
}

# ---------------------------------------------------------------------------
# Context file generation
# ---------------------------------------------------------------------------

# Extract a named section from a markdown principle file.
# Prints lines between "## <section>" and the next "## " header.
extract_section() {
    local file="$1"
    local section="$2"
    awk -v sec="## $section" '
        $0 == sec         { found=1; next }
        found && /^## /   { exit }
        found             { print }
    ' "$file"
}

# Derive a principle ID from its path relative to the principles/ directory.
# e.g. code/api/api-001.md → CODE-API-001
derive_id() {
    local relpath="${1%.md}"   # strip .md
    local IFS_BAK="$IFS"
    IFS='/' read -ra segs <<< "$relpath"
    IFS="$IFS_BAK"

    local n=${#segs[@]}
    local result=""

    # Uppercase each directory segment
    for (( i=0; i<n-1; i++ )); do
        local up
        up=$(echo "${segs[$i]}" | tr '[:lower:]' '[:upper:]')
        result="${result:+$result-}$up"
    done

    # Strip parent-dir prefix from filename (e.g. api-001 → 001)
    local last="${segs[$((n-1))]}"
    local parent="${segs[$((n-2))]}"
    local prefix_len=$(( ${#parent} + 1 ))   # parent + "-"
    local lower_last
    lower_last=$(echo "$last" | tr '[:upper:]' '[:lower:]')
    local lower_parent
    lower_parent=$(echo "$parent" | tr '[:upper:]' '[:lower:]')

    local suffix
    if [ "${lower_last:0:$prefix_len}" = "${lower_parent}-" ]; then
        suffix="${last:$prefix_len}"
    else
        suffix="$last"
    fi

    local up_suffix
    up_suffix=$(echo "$suffix" | tr '[:lower:]' '[:upper:]')
    echo "${result}-${up_suffix}"
}

# Build .context-prime.md and .context-audit.md for every namespace under principles/.
# Called automatically by install_claude.
build_context() {
    local principles_dir="$SCRIPT_DIR/principles"
    local total=0

    for catalog in "$principles_dir"/*/catalog.yaml; do
        [ -f "$catalog" ] || continue
        local ns_dir
        ns_dir="$(dirname "$catalog")"
        local ns_name
        ns_name="$(basename "$ns_dir")"

        local prime_file="$ns_dir/.context-prime.md"
        local audit_file="$ns_dir/.context-audit.md"

        printf '# .principles prime context — %s\n' "$ns_name"   > "$prime_file"
        printf '# Sections: Principle · Why it matters · Good practice\n\n' >> "$prime_file"

        printf '# .principles audit context — %s\n' "$ns_name"   > "$audit_file"
        printf '# Sections: Principle · Violations to detect\n\n' >> "$audit_file"

        local count=0

        while IFS= read -r -d '' mdfile; do
            local relpath="${mdfile#$principles_dir/}"
            local id
            id=$(derive_id "$relpath")

            # Title: first line stripped of "# " and any "ID — " prefix
            local title
            title=$(head -1 "$mdfile" | sed 's/^# //')
            [[ "$title" == *" — "* ]] && title="${title#*— }"

            local principle why good violations
            principle=$(extract_section "$mdfile" "Principle")
            why=$(extract_section "$mdfile" "Why it matters")
            good=$(extract_section "$mdfile" "Good practice")
            violations=$(extract_section "$mdfile" "Violations to detect")

            # Prime entry
            {
                echo "### $id — $title"
                [ -n "$principle"  ] && echo "$principle"
                [ -n "$why"        ] && printf '\nWhy it matters:\n%s\n' "$why"
                [ -n "$good"       ] && printf '\nGood practice:\n%s\n' "$good"
                echo ""
            } >> "$prime_file"

            # Audit entry
            {
                echo "### $id — $title"
                [ -n "$principle"  ] && echo "$principle"
                [ -n "$violations" ] && printf '\nViolations to detect:\n%s\n' "$violations"
                echo ""
            } >> "$audit_file"

            count=$(( count + 1 ))
        done < <(find "$ns_dir" -name "*.md" -not -name "TEMPLATE.md" -not -name ".context-*.md" -print0 | sort -z)

        echo -e "  ${GREEN}✓${NC} principles/$ns_name/.context-prime.md ($count principles)"
        echo -e "  ${GREEN}✓${NC} principles/$ns_name/.context-audit.md ($count principles)"
        total=$(( total + count ))
    done

    echo -e "  ${BOLD}$total${NC} principles compiled"
}

# ---------------------------------------------------------------------------

install_claude() {
    echo -e "${BOLD}Installing Claude Code slash commands...${NC}"

    mkdir -p "$CLAUDE_COMMANDS_DIR"

    local count=0
    for file in "$SCRIPT_DIR/targets/claude-code/"*.md; do
        if [ -f "$file" ]; then
            sed "s|{{CODE_PRINCIPLES_REPO}}|$SCRIPT_DIR|g" "$file" \
                > "$CLAUDE_COMMANDS_DIR/$(basename "$file")"
            count=$((count + 1))
            echo -e "  ${GREEN}✓${NC} /$(basename "$file" .md)"
        fi
    done

    echo ""
    echo -e "Installed ${BOLD}$count${NC} commands to $CLAUDE_COMMANDS_DIR"
    echo ""
    echo -e "${BOLD}Building principle context files...${NC}"
    build_context
    echo ""
    echo "Available commands:"
    echo "  /prime   — Load principles into context before coding"
    echo "  /audit   — Audit code against activated principles"
    echo "  /scout   — Detect project profile and write .principles files"
}

install_copilot() {
    local project_dir="${1:-.}"

    if [ ! -d "$project_dir" ]; then
        echo -e "${RED}Error: Directory '$project_dir' does not exist.${NC}"
        exit 1
    fi

    echo -e "${BOLD}Generating Copilot instructions for: $project_dir${NC}"

    local target_dir="$project_dir/.github"
    local target_file="$target_dir/copilot-instructions.md"

    mkdir -p "$target_dir"

    # Check if file exists and has content
    if [ -f "$target_file" ] && [ -s "$target_file" ]; then
        echo -e "${YELLOW}Warning: $target_file already exists.${NC}"
        echo "  Appending .principles section. Review the file afterward."
        echo "" >> "$target_file"
        echo "<!-- .principles: begin -->" >> "$target_file"
    else
        echo "<!-- .principles: begin -->" > "$target_file"
    fi

    # Generate Copilot instructions from the prime prompt
    cat >> "$target_file" << 'COPILOT_EOF'
# .principles — AI Coding Guidelines

When writing or reviewing code in this project, follow the layered principle system below.

## Layer 1 — Always Active (apply to all code)

- **SD-001**: Single Responsibility — one reason to change per module/class/function
- **SD-006**: Favor composition over inheritance
- **SD-007**: Program to an interface, not an implementation
- **SD-029**: Code must pass all tests
- **SD-030**: Code must reveal intention
- **SD-031**: No knowledge duplication
- **SD-032**: Fewest elements — remove anything unnecessary
- **SEC-001**: Validate input at system boundaries
- **CS-001**: Don't repeat knowledge — single authoritative representation
- **DX-001**: Name things by what they represent
- **DX-002**: Keep functions small and single-purpose
- **DX-003**: Write code for the reader, not the writer
- **DX-005**: Delete dead code
- **RL-001**: Fail fast, fail loudly — never silently swallow errors

## Layer 2 — Context-Dependent (activate based on what you're building)

Apply additional principles when working in these contexts:
- **API design**: Follow REST semantics, proper status codes, backward compatibility
- **Concurrency**: Guard shared state, prefer immutability, use structured concurrency
- **Domain modeling**: Use ubiquitous language, bounded contexts, aggregates
- **Testing**: One behavior per test, test behavior not implementation, fast tests
- **Cloud-native**: Follow 12-factor app principles
- **Infrastructure**: Define as code, pipeline-driven changes, immutable infrastructure

## Layer 3 — Risk-Elevated (apply extra scrutiny in high-risk areas)

Elevate severity when code handles:
- **Authentication/sessions**: Enforce access control, strong crypto, proper session management
- **Financial transactions**: Validate rigorously, ensure idempotency, guard shared state
- **Personal data (PII)**: Encrypt, log access, comply with GDPR/CCPA/HIPAA
- **Public APIs**: Never break existing clients, design method signatures carefully
- **Performance-critical paths**: Profile before optimizing, mind data locality and allocation
- **Distributed systems**: Design for fault tolerance, idempotency, circuit breakers
COPILOT_EOF

    echo "<!-- .principles: end -->" >> "$target_file"

    echo -e "  ${GREEN}✓${NC} $target_file"
    echo ""
    echo "Copilot instructions written. Review and commit the file."
    echo ""
    echo "IDE notes:"
    echo "  VS Code   — .github/copilot-instructions.md is auto-detected. No setup needed."
    echo "              For path-specific instructions (Java, TypeScript, security, etc.),"
    echo "              use: ./install.sh vscode <dir>"
    echo "  JetBrains — Verify: Settings > Languages & Frameworks > GitHub Copilot > Use instruction files"
    echo "  CLI       — Works automatically from repository root."
}

install_cursor() {
    local project_dir="${1:-.}"

    if [ ! -d "$project_dir" ]; then
        echo -e "${RED}Error: Directory '$project_dir' does not exist.${NC}"
        exit 1
    fi

    echo -e "${BOLD}Generating Cursor rules for: $project_dir${NC}"

    local target_dir="$project_dir/.cursor/rules"
    mkdir -p "$target_dir"

    local target_file="$target_dir/.principles.mdc"

    cat > "$target_file" << 'CURSOR_EOF'
---
description: Code principles for writing and reviewing software
globs:
alwaysApply: true
---

# .principles — AI Coding Guidelines

When writing or reviewing code, follow the layered principle system below.

## Layer 1 — Always Active

- SD-001: Single Responsibility — one reason to change per module/class/function
- SD-006: Favor composition over inheritance
- SD-007: Program to an interface, not an implementation
- SD-029: Code must pass all tests
- SD-030: Code must reveal intention
- SD-031: No knowledge duplication
- SD-032: Fewest elements — remove anything unnecessary
- SEC-001: Validate input at system boundaries
- CS-001: Don't repeat knowledge
- DX-001: Name things by what they represent
- DX-002: Keep functions small and single-purpose
- DX-003: Write code for the reader, not the writer
- DX-005: Delete dead code
- RL-001: Fail fast, fail loudly

## Layer 2 — Context-Dependent

Apply additional principles when the context matches:
- API design: REST semantics, proper status codes, backward compatibility
- Concurrency: Guard shared state, prefer immutability, structured concurrency
- Domain modeling: Ubiquitous language, bounded contexts, aggregates
- Testing: One behavior per test, behavior over implementation, fast tests
- Cloud-native: 12-factor app principles
- Infrastructure: Define as code, pipeline-driven, immutable

## Layer 3 — Risk-Elevated

Elevate severity for code handling:
- Authentication/sessions: Access control, strong crypto, session management
- Financial transactions: Validation, idempotency, synchronized access
- Personal data (PII): Encryption, access logging, regulatory compliance
- Public APIs: Backward compatibility, careful method signatures
- Performance-critical: Profile first, data locality, allocation pressure
- Distributed systems: Fault tolerance, idempotency, circuit breakers
CURSOR_EOF

    echo -e "  ${GREEN}✓${NC} $target_file"
    echo ""
    echo "Cursor rules written. The rule will apply to all files in the project."
}

install_vscode() {
    local project_dir="${1:-.}"

    if [ ! -d "$project_dir" ]; then
        echo -e "${RED}Error: Directory '$project_dir' does not exist.${NC}"
        exit 1
    fi

    echo -e "${BOLD}Generating VS Code Copilot instructions for: $project_dir${NC}"

    local github_dir="$project_dir/.github"
    local base_file="$github_dir/copilot-instructions.md"
    local instructions_dir="$github_dir/instructions"

    mkdir -p "$instructions_dir"

    # Base file — layer overview
    if [ -f "$base_file" ] && [ -s "$base_file" ]; then
        echo -e "${YELLOW}Warning: $base_file already exists.${NC}"
        echo "  Appending .principles section. Review the file afterward."
        echo "" >> "$base_file"
        echo "<!-- .principles: begin -->" >> "$base_file"
    else
        echo "<!-- .principles: begin -->" > "$base_file"
    fi

    cat >> "$base_file" << 'VSCODE_BASE_EOF'
# .principles — AI Coding Guidelines

When writing or reviewing code in this project, follow the layered principle system below.

## Layer 1 — Always Active (apply to all code)

- **SOLID-SRP**: Single Responsibility — one reason to change per module/class/function
- **GOF-COMPOSITION-OVER-INHERITANCE**: Favor composition over inheritance
- **GOF-PROGRAM-TO-INTERFACE**: Program to an interface, not an implementation
- **CODE-SEC-VALIDATE-INPUT**: Validate input at system boundaries
- **CODE-CS-DRY**: Don't repeat knowledge — single authoritative representation
- **CODE-DX-NAMING**: Name things by what they represent
- **CODE-DX-SMALL-FUNCTIONS**: Keep functions small and single-purpose
- **CODE-DX-CODE-FOR-READERS**: Write code for the reader, not the writer
- **CODE-CS-FAIL-FAST**: Fail fast, fail loudly — never silently swallow errors
- **INFRA-NO-SECRETS-IN-CODE**: Never commit credentials, tokens, or keys

## Layer 2 — Context-Dependent

Path-specific instruction files in `.github/instructions/` apply additional principles
automatically based on file type and location (language, API code, security-sensitive paths, tests).

## Layer 3 — Risk-Elevated

Elevate scrutiny for code handling authentication, financial data, PII, or public APIs.
See `.github/instructions/security.instructions.md`.
VSCODE_BASE_EOF

    echo "<!-- .principles: end -->" >> "$base_file"
    echo -e "  ${GREEN}✓${NC} .github/copilot-instructions.md"

    # --- Path-specific instruction files ---

    cat > "$instructions_dir/java.instructions.md" << 'EOF'
---
applyTo: "**/*.java,**/*.kt"
---
# Java / Kotlin principles

## SOLID
- **SOLID-SRP**: Single Responsibility — one reason to change per class/module
- **SOLID-OCP**: Open/Closed — open for extension, closed for modification
- **SOLID-LSP**: Liskov Substitution — subtypes must be substitutable for their base types
- **SOLID-ISP**: Interface Segregation — prefer narrow, focused interfaces
- **SOLID-DIP**: Dependency Inversion — depend on abstractions, not concretions

## Effective Java
- **EJ-STATIC-FACTORY**: Prefer static factory methods over constructors
- **EJ-BUILDER**: Use the builder pattern when constructors have many parameters
- **EJ-MINIMIZE-MUTABILITY**: Prefer immutable classes; make fields final where possible
- **EJ-MINIMIZE-ACCESSIBILITY**: Reduce visibility as much as possible
- **EJ-ELIMINATE-UNCHECKED**: Eliminate unchecked warnings

## Concurrency
- **CODE-CC-SYNC-SHARED-STATE**: Synchronize all access to shared mutable state
- **CODE-CC-SAFE-PUBLICATION**: Ensure objects are safely published across threads
- **CODE-CC-STRUCTURED-CONCURRENCY**: Use structured concurrency (Java 21+ StructuredTaskScope)
- **CODE-CC-TASK-BASED-CONCURRENCY**: Prefer tasks over raw threads
- **CODE-CC-DOCUMENT-THREAD-SAFETY**: Document thread-safety guarantees on every class

## Type Safety
- **CODE-TP-MAKE-ILLEGAL-STATES-UNREPRESENTABLE**: Use the type system to prevent invalid states
- **CODE-TP-EXHAUSTIVE-PATTERN-MATCHING**: Handle all cases in switch expressions and pattern matches
- **CODE-TP-PREFER-SUM-TYPES**: Use sealed interfaces or enums to model alternatives
EOF
    echo -e "  ${GREEN}✓${NC} .github/instructions/java.instructions.md"

    cat > "$instructions_dir/typescript.instructions.md" << 'EOF'
---
applyTo: "**/*.ts,**/*.tsx"
---
# TypeScript principles

## Type Safety
- **CODE-TP-MAKE-ILLEGAL-STATES-UNREPRESENTABLE**: Use discriminated unions and the type system to prevent invalid states
- **CODE-TP-EXHAUSTIVE-PATTERN-MATCHING**: Use exhaustive checks (`never`) in switch statements and union handling
- **CODE-TP-PREFER-SUM-TYPES**: Model alternatives with discriminated unions, not optional fields
- **CODE-TP-TYPE-STATE-MACHINES**: Encode state machine transitions in the type system
- **CODE-TP-BRANDED-TYPES**: Use branded/nominal types to distinguish structurally identical values

## Design
- **GOF-COMPOSITION-OVER-INHERITANCE**: Prefer composition and mixins over class hierarchies
- **GOF-PROGRAM-TO-INTERFACE**: Depend on interfaces and type aliases, not concrete implementations
- **SOLID-SRP**: Each module, class, or function should have one reason to change
EOF
    echo -e "  ${GREEN}✓${NC} .github/instructions/typescript.instructions.md"

    cat > "$instructions_dir/javascript.instructions.md" << 'EOF'
---
applyTo: "**/*.js,**/*.jsx,**/*.mjs,**/*.cjs"
---
# JavaScript principles

## Design
- **GOF-COMPOSITION-OVER-INHERITANCE**: Prefer composition over prototype chains
- **GOF-PROGRAM-TO-INTERFACE**: Depend on duck-typed interfaces, not concrete objects
- **SOLID-SRP**: Each module or function should have one reason to change
- **CODE-CS-DRY**: Single authoritative representation — avoid copy-paste logic
- **CODE-CS-YAGNI**: Don't add abstractions until they're needed
- **CODE-DX-SMALL-FUNCTIONS**: Keep functions small and focused on one task

## Reliability
- **CODE-CS-FAIL-FAST**: Surface errors immediately; avoid silent failures
- **CODE-RL-FAULT-TOLERANCE**: Handle async failures explicitly; don't leave unhandled promise rejections
EOF
    echo -e "  ${GREEN}✓${NC} .github/instructions/javascript.instructions.md"

    cat > "$instructions_dir/python.instructions.md" << 'EOF'
---
applyTo: "**/*.py"
---
# Python principles

## Design
- **SOLID-SRP**: Each class or function should have one reason to change
- **GOF-COMPOSITION-OVER-INHERITANCE**: Prefer composition and mixins over deep inheritance chains
- **CODE-CS-DRY**: Single authoritative representation — avoid duplicating logic
- **CODE-CS-KISS**: Prefer simple, readable solutions over clever ones
- **CODE-DX-CODE-FOR-READERS**: Write for the reader; Python's readability is a feature, not a bonus

## Code Smells to avoid
- **CODE-SMELLS-LONG-METHOD**: Extract methods when a function grows beyond a single screen
- **CODE-SMELLS-LARGE-CLASS**: Split classes that accumulate unrelated responsibilities
EOF
    echo -e "  ${GREEN}✓${NC} .github/instructions/python.instructions.md"

    cat > "$instructions_dir/csharp.instructions.md" << 'EOF'
---
applyTo: "**/*.cs"
---
# C# principles

## SOLID
- **SOLID-SRP**: Single Responsibility — one reason to change per class
- **SOLID-OCP**: Open/Closed — open for extension, closed for modification
- **SOLID-LSP**: Liskov Substitution — subtypes must be substitutable for their base types
- **SOLID-ISP**: Interface Segregation — prefer narrow, focused interfaces
- **SOLID-DIP**: Dependency Inversion — depend on abstractions, not concretions

## Type Safety
- **CODE-TP-MAKE-ILLEGAL-STATES-UNREPRESENTABLE**: Use the type system to prevent invalid states
- **CODE-TP-EXHAUSTIVE-PATTERN-MATCHING**: Use exhaustive switch expressions with discard patterns
- **CODE-TP-PREFER-SUM-TYPES**: Use discriminated unions (OneOf) or sealed class hierarchies
- **CODE-TP-TYPE-STATE-MACHINES**: Encode state transitions in the type system

## Concurrency
- **CODE-CC-TASK-BASED-CONCURRENCY**: Prefer Task/async-await over raw Thread
- **CODE-CC-STRUCTURED-CONCURRENCY**: Use CancellationToken for cooperative cancellation
EOF
    echo -e "  ${GREEN}✓${NC} .github/instructions/csharp.instructions.md"

    cat > "$instructions_dir/go.instructions.md" << 'EOF'
---
applyTo: "**/*.go"
---
# Go principles

## Design
- **GOF-COMPOSITION-OVER-INHERITANCE**: Embed interfaces and structs; avoid deep type hierarchies
- **GOF-PROGRAM-TO-INTERFACE**: Accept interfaces, return structs
- **CODE-CS-DRY**: Single authoritative representation — avoid duplicating logic
- **ARCH-OBSERVABILITY-BY-DESIGN**: Instrument code with structured logging and tracing from the start

## Concurrency
- **CODE-CC-SYNC-SHARED-STATE**: Protect all shared state with mutexes or channels
- **CODE-CC-HIGHER-LEVEL-CONCURRENCY**: Use goroutines and channels; avoid low-level sync primitives where possible
- **CODE-CC-TASK-BASED-CONCURRENCY**: Prefer goroutine-based task patterns with explicit lifecycle management
- **CODE-CC-STRUCTURED-CONCURRENCY**: Use errgroup or similar for structured goroutine lifecycle management
EOF
    echo -e "  ${GREEN}✓${NC} .github/instructions/go.instructions.md"

    cat > "$instructions_dir/rust.instructions.md" << 'EOF'
---
applyTo: "**/*.rs"
---
# Rust principles

## Type Safety
- **CODE-TP-MAKE-ILLEGAL-STATES-UNREPRESENTABLE**: Use enums and the type system to prevent invalid states
- **CODE-TP-EXHAUSTIVE-PATTERN-MATCHING**: Handle all enum variants in match expressions; avoid wildcard `_` unless intentional
- **CODE-TP-PREFER-SUM-TYPES**: Model alternatives with enums, not Option chains
- **CODE-TP-TYPE-STATE-MACHINES**: Encode state transitions using the typestate pattern

## Concurrency
- **CODE-CC-SYNC-SHARED-STATE**: Use Arc<Mutex<T>> or channels; trust the borrow checker
- **CODE-CC-SAFE-PUBLICATION**: Ensure data shared across threads implements Send + Sync

## Performance
- **CODE-PF-PROFILE-FIRST**: Measure before optimizing; use cargo flamegraph or perf
- **CODE-PF-DATA-LOCALITY**: Prefer cache-friendly data structures (Vec over LinkedList)
- **CODE-PF-MECHANICAL-SYMPATHY**: Write with the underlying hardware in mind; minimize allocations
EOF
    echo -e "  ${GREEN}✓${NC} .github/instructions/rust.instructions.md"

    cat > "$instructions_dir/api.instructions.md" << 'EOF'
---
applyTo: "**/controller/**,**/controllers/**,**/handler/**,**/handlers/**,**/router/**,**/routers/**,**/route/**,**/routes/**,**/api/**,**/endpoint/**,**/endpoints/**"
---
# API design principles

- **CODE-API-STANDARD-HTTP-METHODS**: Use HTTP methods by their RFC 9110 semantics (GET=safe, PUT/DELETE=idempotent)
- **CODE-API-RESOURCE-NOUNS**: Resource URLs use nouns, not verbs (`/orders`, not `/getOrders`)
- **CODE-API-HTTP-STATUS-CODES**: Return semantically correct HTTP status codes
- **CODE-API-BACKWARD-COMPATIBILITY**: Never break existing clients; add fields, don't remove or rename
- **CODE-API-HATEOAS**: Include hypermedia links in responses where appropriate
- **CODE-RL-IDEMPOTENCY**: Ensure mutating operations are safe to retry
- **CODE-CS-POSTELS-LAW**: Be conservative in what you send, liberal in what you accept
- **CODE-CS-HYRUMS-LAW**: All observable behaviors become implicit contracts — design deliberately
EOF
    echo -e "  ${GREEN}✓${NC} .github/instructions/api.instructions.md"

    cat > "$instructions_dir/security.instructions.md" << 'EOF'
---
applyTo: "**/auth/**,**/authentication/**,**/authorization/**,**/security/**,**/crypto/**,**/cryptography/**,**/payment/**,**/payments/**,**/oauth/**,**/jwt/**"
---
# Security principles (elevated risk)

## Input & Access
- **CODE-SEC-VALIDATE-INPUT**: Validate and sanitize all input at system boundaries
- **OWASP-01-BROKEN-ACCESS-CONTROL**: Enforce access control on every request; deny by default
- **OWASP-03-INJECTION**: Use parameterized queries and safe APIs; never build queries from user input
- **OWASP-07-AUTHENTICATION-FAILURES**: Implement secure session management and MFA where appropriate

## Cryptography
- **CODE-SEC-STRONG-CRYPTOGRAPHY**: Use vetted algorithms (AES-256, SHA-256+); never roll your own crypto
- **OWASP-02-CRYPTOGRAPHIC-FAILURES**: Encrypt data in transit and at rest; avoid weak algorithms

## Design & Infrastructure
- **CODE-SEC-SECURITY-BY-DESIGN**: Build security in from the start; do not treat it as an afterthought
- **OWASP-04-INSECURE-DESIGN**: Threat-model during design; identify and mitigate risks before coding
- **OWASP-05-SECURITY-MISCONFIGURATION**: Disable default credentials; harden configs; apply least privilege
- **INFRA-NO-SECRETS-IN-CODE**: Never commit credentials, tokens, or keys; use environment variables or vaults
- **INFRA-LEAST-PRIVILEGE**: Grant only the minimum permissions needed

## Integrity & Logging
- **CODE-SEC-DATA-INTEGRITY**: Verify integrity of data and third-party components
- **OWASP-08-SOFTWARE-INTEGRITY-FAILURES**: Verify signatures and checksums for all dependencies
- **CODE-SEC-SECURITY-LOGGING**: Log security events (auth failures, access denials) with sufficient detail
- **OWASP-09-LOGGING-FAILURES**: Ensure security-relevant events are logged and monitored
- **OWASP-10-SSRF**: Validate and restrict outbound requests; never fetch arbitrary user-supplied URLs
EOF
    echo -e "  ${GREEN}✓${NC} .github/instructions/security.instructions.md"

    cat > "$instructions_dir/test.instructions.md" << 'EOF'
---
applyTo: "**/*Test.java,**/*Tests.java,**/*Spec.java,**/*_test.go,**/*_test.py,**/*.test.ts,**/*.spec.ts,**/*.test.js,**/*.spec.js,**/*.test.tsx,**/*.spec.tsx,**/test/**,**/tests/**,**/spec/**,**/specs/**"
---
# Testing principles

- **CODE-TS-SINGLE-BEHAVIOR**: Each test verifies exactly one behavior or requirement
- **CODE-TS-TEST-BEHAVIOR**: Test what the code does, not how it does it; avoid testing internals
- **CODE-TS-FAST-TESTS**: Unit tests must run in milliseconds; slow tests belong in integration suites
- **CODE-TS-TEST-INDEPENDENCE**: Tests must not depend on execution order or share mutable state
- **CODE-TS-TEST-NAMING**: Test names describe the scenario and expected outcome in plain language
- **CODE-TS-ARRANGE-ACT-ASSERT**: Structure tests with clear setup, action, and assertion phases
- **CODE-TS-TEST-DOUBLES**: Use test doubles (mocks, stubs, fakes) only at architectural boundaries
- **CODE-TS-TEST-FIRST**: Write the test before the implementation to drive design
EOF
    echo -e "  ${GREEN}✓${NC} .github/instructions/test.instructions.md"

    echo ""
    echo "VS Code Copilot instructions written. Commit these files and they will be"
    echo "active for all workspace users automatically — no IDE setup required."
    echo ""
    echo "Files generated:"
    echo "  .github/copilot-instructions.md     — Layer overview (all tools)"
    echo "  .github/instructions/               — Path-specific (VS Code only)"
    echo "    java.instructions.md              applyTo: *.java, *.kt"
    echo "    typescript.instructions.md        applyTo: *.ts, *.tsx"
    echo "    javascript.instructions.md        applyTo: *.js, *.jsx, *.mjs"
    echo "    python.instructions.md            applyTo: *.py"
    echo "    csharp.instructions.md            applyTo: *.cs"
    echo "    go.instructions.md                applyTo: *.go"
    echo "    rust.instructions.md              applyTo: *.rs"
    echo "    api.instructions.md               applyTo: controller/handler/router/api paths"
    echo "    security.instructions.md          applyTo: auth/security/crypto/payment paths"
    echo "    test.instructions.md              applyTo: test/spec files"
    echo ""
    echo "  JetBrains note: only .github/copilot-instructions.md is supported."
    echo "  Verify: Settings > Languages & Frameworks > GitHub Copilot > Use instruction files"
}

uninstall_claude() {
    echo -e "${BOLD}Removing Claude Code slash commands...${NC}"

    local count=0
    for file in prime.md audit.md scout.md; do
        if [ -f "$CLAUDE_COMMANDS_DIR/$file" ]; then
            rm "$CLAUDE_COMMANDS_DIR/$file"
            count=$((count + 1))
            echo -e "  ${RED}✗${NC} /$(basename "$file" .md)"
        fi
    done

    if [ $count -eq 0 ]; then
        echo "  No commands found to remove."
    else
        echo ""
        echo "Removed $count commands."
    fi
}

list_installed() {
    echo -e "${BOLD}Installed .principles:${NC}"
    echo ""

    echo "Claude Code commands:"
    local found=false
    for file in prime.md audit.md scout.md; do
        if [ -f "$CLAUDE_COMMANDS_DIR/$file" ]; then
            echo -e "  ${GREEN}✓${NC} /$(basename "$file" .md)"
            found=true
        fi
    done
    if [ "$found" = false ]; then
        echo "  (none)"
    fi
}

show_usage() {
    print_header
    echo ""
    echo "Usage: $0 <target> [options]"
    echo ""
    echo "Targets:"
    echo "  claude              Install slash commands to ~/.claude/commands/"
    echo "  copilot [dir]       Generate .github/copilot-instructions.md — Copilot CLI + JetBrains"
    echo "  vscode [dir]        Generate copilot-instructions.md + path-specific .github/instructions/"
    echo "  cursor [dir]        Generate .cursor/rules/.principles.mdc (default: current dir)"
    echo "  all [dir]           Install all targets"
    echo ""
    echo "Management:"
    echo "  --uninstall         Remove Claude Code commands"
    echo "  --list              Show what's installed"
    echo "  --help              Show this help"
    echo ""
    echo "Examples:"
    echo "  ./install.sh claude"
    echo "  ./install.sh copilot ~/projects/my-app"
    echo "  ./install.sh all ~/projects/my-app"
}

# Main
print_header

case "${1:-}" in
    claude)
        install_claude
        ;;
    copilot)
        install_copilot "${2:-.}"
        ;;
    vscode)
        install_vscode "${2:-.}"
        ;;
    cursor)
        install_cursor "${2:-.}"
        ;;
    all)
        install_claude
        echo ""
        install_vscode "${2:-.}"
        echo ""
        install_cursor "${2:-.}"
        ;;
    --uninstall|-u)
        uninstall_claude
        ;;
    --list|-l)
        list_installed
        ;;
    --help|-h)
        show_usage
        ;;
    "")
        show_usage
        ;;
    *)
        echo -e "${RED}Unknown target: $1${NC}"
        show_usage
        exit 1
        ;;
esac

echo ""
echo "Done."
