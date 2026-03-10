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
    echo "  copilot [dir]       Generate .github/copilot-instructions.md (default: current dir)"
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
    cursor)
        install_cursor "${2:-.}"
        ;;
    all)
        install_claude
        echo ""
        install_copilot "${2:-.}"
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
