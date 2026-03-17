#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# Copyright (c) 2026 Flemming N. Larsen — https://github.com/code-principles/.principles
set -euo pipefail

# install.sh — Deploy code-principles to AI coding tools
#
# Usage:
#   ./install.sh claude              # Install Claude Code slash commands globally (~/.claude/commands/)
#   ./install.sh claude <dir>        # Install Claude Code slash commands locally (<dir>/.claude/commands/)
#   ./install.sh copilot             # Install Copilot instructions globally (~/.copilot/copilot-instructions.md)
#   ./install.sh copilot <dir>       # Generate Copilot assets in <dir>/.github/
#                                    #   .github/copilot-instructions.md  (all Copilot clients)
#                                    #   .github/skills/<name>/SKILL.md   (Copilot CLI slash commands)
#                                    #   .github/prompts/<name>.prompt.md (VS Code / JetBrains / Visual Studio)
#   ./install.sh cursor              # (not applicable — configure via Cursor > Settings > General > Rules for AI)
#   ./install.sh cursor <dir>        # Generate Cursor rules (<dir>/.cursor/rules/code-principles.mdc)
#   ./install.sh all                 # Global: install claude + copilot (cursor: message)
#   ./install.sh all <dir>           # Local: install all tools in <dir>
#   ./install.sh --list              # Show what's installed
#   ./uninstall.sh                   # Remove global assets
#   ./uninstall.sh <dir>             # Remove local assets from <dir>

# Convert a Windows-style path (C:\... or C:/...) to a path the current bash understands.
# Under WSL, uses wslpath. Under Git Bash / native Linux/macOS, returns the path unchanged.
normalize_path() {
    local p="$1"
    if [[ -n "$p" && "$p" =~ ^[A-Za-z]:[/\\] ]]; then
        if command -v wslpath &>/dev/null; then
            wslpath -u "$p"
            return
        fi
    fi
    printf '%s' "$p"
}

normalize_directory_path() {
    local dir
    dir="$(normalize_path "$1")"
    if [ -z "$dir" ]; then
        printf '%s' "$dir"
        return
    fi

    case "$dir" in
        /|[A-Za-z]:/)
            printf '%s' "$dir"
            return
            ;;
    esac

    while [ "${dir%/}" != "$dir" ]; do
        dir="${dir%/}"
    done

    printf '%s' "$dir"
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Resolve the home directory for global asset installation.
# (defined before DATA_DIR so resolve_home() is available)
# When invoked via WSL (e.g. PowerShell 7 finds the WSL bash instead of Git
# Bash), $HOME is the Linux home (/home/<user>) but assets must go to the
# Windows user profile so that Windows tools (Copilot, Claude Code) find them.
resolve_home() {
    if [ -n "${PRINCIPLES_WIN_HOME:-}" ]; then
        # Set by install.ps1 — Windows USERPROFILE with forward slashes.
        # normalize_path converts it to a bash-usable path (wslpath under WSL,
        # pass-through under Git Bash which natively handles C:/... paths).
        normalize_path "$PRINCIPLES_WIN_HOME"
    elif command -v wslpath &>/dev/null && [ -n "${USERPROFILE:-}" ]; then
        wslpath -u "$USERPROFILE"
    else
        echo "$HOME"
    fi
}
EFFECTIVE_HOME="$(resolve_home)"
DATA_DIR="$EFFECTIVE_HOME/.principles"

CLAUDE_COMMANDS_DIR="$EFFECTIVE_HOME/.claude/commands"
CLAUDE_TARGETS_DIR="$SCRIPT_DIR/targets/claude-code"

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
    echo -e "${BOLD}code-principles installer${NC}"
    echo "─────────────────────────"
}

copilot_prompt_description() {
    case "$1" in
        scout)
            echo "Detect project profile and create or update .principles files (Experimental)"
            ;;
        prime)
            echo "Activate code principles before writing code (Experimental)"
            ;;
        audit)
            echo "Review code against the active principles and group findings by severity (Experimental)"
            ;;
        *)
            echo "Run the $1 code-principles workflow (Experimental)"
            ;;
    esac
}

copilot_skill_description() {
    case "$1" in
        scout)
            echo "Analyse the project, detect language/framework/domain, and create or update .principles files. Use this skill when asked to scout, detect project profile, or set up principles."
            ;;
        prime)
            echo "Resolve the .principles hierarchy, load full principle guidance, and prepare a coding frame. Use this skill when asked to prime, activate principles, or before writing code."
            ;;
        audit)
            echo "Resolve the .principles hierarchy, load principle content, review code, and group findings by severity (Critical/High/Medium/Low). Use this skill when asked to audit or review code against principles."
            ;;
        *)
            echo "Run the $1 code-principles workflow."
            ;;
    esac
}

write_principles_body() {
    local target_file="$1"
    cat >> "$target_file" << 'PRINCIPLES_EOF'
# Code Principles — AI Coding Guidelines

When writing or reviewing code, follow the layered principle system below.

## Layer 1 — Always Active

Non-negotiable fundamentals that apply to every line of code: single responsibility, no duplication, reveal intention, fail fast, validate input, delete dead code.

## Layer 2 — Context-Dependent

Additional principles activated by what you're building. Covers API design, concurrency, domain modeling, testing, cloud-native, and infrastructure patterns.

## Layer 3 — Risk-Elevated

Extra scrutiny for high-risk areas where mistakes are costly or hard to reverse: authentication, financial transactions, personal data (PII), public APIs, performance-critical paths, and distributed systems.
PRINCIPLES_EOF
}


write_copilot_skill() {
    local source_file="$1"
    local skill_dir="$2"
    local command_name="$3"

    mkdir -p "$skill_dir"
    local skill_file="$skill_dir/SKILL.md"

    cat > "$skill_file" <<EOF
---
name: $command_name
description: $(copilot_skill_description "$command_name")
license: MIT
---

EOF

    cat "$source_file" >> "$skill_file"
}


write_copilot_prompt() {
    local source_file="$1"
    local prompt_file="$2"
    local command_name="$3"

    cat > "$prompt_file" <<EOF
---
description: $(copilot_prompt_description "$command_name")
mode: agent
---

EOF

    cat "$source_file" >> "$prompt_file"
}

install_data() {
    echo -e "${BOLD}Installing .principles data...${NC}"
    rm -rf "$DATA_DIR/groups" "$DATA_DIR/principles"
    mkdir -p "$DATA_DIR"
    cp -r "$SCRIPT_DIR/groups"     "$DATA_DIR/"
    cp -r "$SCRIPT_DIR/principles" "$DATA_DIR/"
    echo -e "  ${GREEN}✓${NC} $DATA_DIR"
    echo ""
}

install_claude() {
    local project_dir="${1:-}"
    local target_dir

    if [ -n "$project_dir" ]; then
        if [ ! -d "$project_dir" ]; then
            echo -e "${RED}Error: Directory '$project_dir' does not exist.${NC}"; exit 1
        fi
        target_dir="$project_dir/.claude/commands"
        echo -e "${BOLD}Installing Claude Code slash commands (local: $project_dir)...${NC}"
    else
        target_dir="$CLAUDE_COMMANDS_DIR"
        echo -e "${BOLD}Installing Claude Code slash commands (global)...${NC}"
    fi

    install_data
    mkdir -p "$target_dir"

    local count=0
    for file in "$CLAUDE_TARGETS_DIR/"*.md; do
        if [ -f "$file" ]; then
            sed "s|{{PRINCIPLES_DIRECTORY}}|$DATA_DIR|g" "$file" > "$target_dir/$(basename "$file")"
            count=$((count + 1))
            echo -e "  ${GREEN}✓${NC} /$(basename "$file" .md)"
        fi
    done

    echo ""
    echo -e "Installed ${BOLD}$count${NC} commands to $target_dir"
    echo ""
    echo "Available commands:"
    echo "  /scout  — Detect project profile and generate .principles placements"
    echo "  /prime  — Activate principles before writing code"
    echo "  /audit  — Review code with severity-categorized findings"
}

install_copilot() {
    local project_dir="${1:-}"
    if [ -n "$project_dir" ]; then
        install_copilot_local "$project_dir"
    else
        install_copilot_global
    fi
}

install_copilot_local() {
    local project_dir="$1"

    if [ ! -d "$project_dir" ]; then
        echo -e "${RED}Error: Directory '$project_dir' does not exist.${NC}"
        exit 1
    fi

    install_data
    echo -e "${BOLD}Generating Copilot instructions for: $project_dir${NC}"

    local target_dir="$project_dir/.github"
    local target_file="$target_dir/copilot-instructions.md"
    local prompts_dir="$target_dir/prompts"

    mkdir -p "$target_dir"
    mkdir -p "$prompts_dir"

    # Build the new block in a temp file
    local block_file
    block_file="$(mktemp)"
    echo "<!-- code-principles: begin -->" > "$block_file"
    write_principles_body "$block_file"
    echo "<!-- code-principles: end -->" >> "$block_file"

    if [ ! -f "$target_file" ] || [ ! -s "$target_file" ]; then
        # New or empty file: create with just the block
        cp "$block_file" "$target_file"
    elif grep -q "^<!-- code-principles: begin -->$" "$target_file"; then
        # Existing block found: replace it in-place
        local result_file
        result_file="$(mktemp)"
        awk '
            BEGIN { in_block=0 }
            /^<!-- code-principles: begin -->$/ { in_block=1; next }
            /^<!-- code-principles: end -->$/ { if (in_block) { in_block=0; next } }
            !in_block { print }
        ' "$target_file" > "$result_file"
        # Trim trailing blank lines, then append the new block
        awk '{lines[NR]=$0; if(/[^[:space:]]/) last=NR} END{for(i=1;i<=last;i++) print lines[i]}' \
            "$result_file" > "${result_file}.t" && mv "${result_file}.t" "$result_file"
        [ -s "$result_file" ] && echo "" >> "$result_file"
        cat "$block_file" >> "$result_file"
        mv "$result_file" "$target_file"
    else
        # Existing file without our block: append
        echo "" >> "$target_file"
        cat "$block_file" >> "$target_file"
    fi

    rm -f "$block_file"

    echo -e "${BOLD}Installing Copilot skills and prompt commands...${NC}"

    local prompt_count=0
    local file
    local skills_dir="$target_dir/skills"
    for file in "$CLAUDE_TARGETS_DIR/"*.md; do
        if [ -f "$file" ]; then
            local command_name
            local prompt_file
            command_name="$(basename "$file" .md)"
            prompt_file="$prompts_dir/$command_name.prompt.md"
            # For audit: rewrite ~/.claude/ paths to project-relative paths
            local patched_file
            patched_file="$(mktemp)"
            sed \
                -e "s|{{PRINCIPLES_DIRECTORY}}|$DATA_DIR|g" \
                -e 's|~/.claude/audit-output\.json|.github/scripts/audit-output.json|g' \
                "$file" > "$patched_file"
            write_copilot_prompt "$patched_file" "$prompt_file" "$command_name"
            write_copilot_skill "$patched_file" "$skills_dir/$command_name" "$command_name"
            rm -f "$patched_file"
            prompt_count=$((prompt_count + 1))
            echo -e "  ${GREEN}✓${NC} /$command_name"
        fi
    done

    echo -e "  ${GREEN}✓${NC} $target_file"
    echo ""
    echo "Copilot assets written:"
    echo "  - .github/copilot-instructions.md"
    echo "  - .github/skills/<name>/SKILL.md  (${prompt_count} skills  — Copilot CLI slash commands)"
    echo "  - .github/prompts/*.prompt.md      (${prompt_count} prompts — VS Code prompt files)"
    echo ""
    echo "In Copilot CLI: use /audit, /prime, /scout  (or run '/skills reload' if already in a session)"
    echo "In VS Code:     type /audit, /prime, /scout  in Copilot Chat"
}

install_copilot_global() {
    local target_dir="$EFFECTIVE_HOME/.copilot"
    local target_file="$target_dir/copilot-instructions.md"

    install_data
    echo -e "${BOLD}Generating global Copilot instructions (~/.copilot/copilot-instructions.md)...${NC}"
    mkdir -p "$target_dir"

    # Build the new block in a temp file
    local block_file
    block_file="$(mktemp)"
    echo "<!-- code-principles: begin -->" > "$block_file"
    write_principles_body "$block_file"
    echo "<!-- code-principles: end -->" >> "$block_file"

    if [ ! -f "$target_file" ] || [ ! -s "$target_file" ]; then
        cp "$block_file" "$target_file"
    elif grep -q "^<!-- code-principles: begin -->$" "$target_file"; then
        local result_file
        result_file="$(mktemp)"
        awk '
            BEGIN { in_block=0 }
            /^<!-- code-principles: begin -->$/ { in_block=1; next }
            /^<!-- code-principles: end -->$/ { if (in_block) { in_block=0; next } }
            !in_block { print }
        ' "$target_file" > "$result_file"
        awk '{lines[NR]=$0; if(/[^[:space:]]/) last=NR} END{for(i=1;i<=last;i++) print lines[i]}' \
            "$result_file" > "${result_file}.t" && mv "${result_file}.t" "$result_file"
        [ -s "$result_file" ] && echo "" >> "$result_file"
        cat "$block_file" >> "$result_file"
        mv "$result_file" "$target_file"
    else
        echo "" >> "$target_file"
        cat "$block_file" >> "$target_file"
    fi

    rm -f "$block_file"

    echo -e "  ${GREEN}✓${NC} $target_file"
    echo ""
    echo "Global Copilot instructions written to ~/.copilot/copilot-instructions.md"
    echo "For skills and prompts, run: ./install.sh copilot <project-dir>"
}

install_cursor() {
    local project_dir="${1:-}"

    if [ -z "$project_dir" ]; then
        echo -e "${BOLD}Cursor — global/user scope not supported${NC}"
        echo ""
        echo "Cursor does not support file-based user-level rules."
        echo "Configure manually: Cursor > Settings > General > Rules for AI"
        echo ""
        echo "For project-level rules: ./install.sh cursor <project-dir>"
        return 0
    fi

    if [ ! -d "$project_dir" ]; then
        echo -e "${RED}Error: Directory '$project_dir' does not exist.${NC}"
        exit 1
    fi

    echo -e "${BOLD}Generating Cursor rules for: $project_dir${NC}"

    local target_dir="$project_dir/.cursor/rules"
    mkdir -p "$target_dir"

    local target_file="$target_dir/code-principles.mdc"

    cat > "$target_file" << 'CURSOR_FRONTMATTER'
---
description: Code principles for writing and reviewing software
globs:
alwaysApply: true
---
CURSOR_FRONTMATTER

    write_principles_body "$target_file"

    echo -e "  ${GREEN}✓${NC} $target_file"
    echo ""
    echo "Cursor rules written. The rule will apply to all files in the project."
}

list_installed() {
    echo -e "${BOLD}Installed code-principles:${NC}"
    echo ""

    echo "Claude Code commands (global: ~/.claude/commands/):"
    local found=false
    for file in "$CLAUDE_TARGETS_DIR/"*.md; do
        if [ -f "$file" ] && [ -f "$CLAUDE_COMMANDS_DIR/$(basename "$file")" ]; then
            echo -e "  ${GREEN}✓${NC} /$(basename "$file" .md)"
            found=true
        fi
    done
    if [ "$found" = false ]; then
        echo "  (none)"
    fi

    echo ""
    echo "Copilot instructions (global: ~/.copilot/copilot-instructions.md):"
    if [ -f "$EFFECTIVE_HOME/.copilot/copilot-instructions.md" ] && grep -q "^<!-- code-principles: begin -->$" "$EFFECTIVE_HOME/.copilot/copilot-instructions.md" 2>/dev/null; then
        echo -e "  ${GREEN}✓${NC} ~/.copilot/copilot-instructions.md"
    else
        echo "  (none)"
    fi
}

show_usage() {
    print_header
    echo ""
    echo "Usage: $0 <target> [project-dir]"
    echo ""
    echo "Targets:"
    echo "  claude              Install slash commands globally (~/.claude/commands/)"
    echo "  claude <dir>        Install slash commands locally (<dir>/.claude/commands/)"
    echo "  copilot             Install Copilot instructions globally (~/.copilot/copilot-instructions.md)"
    echo "  copilot <dir>       Generate Copilot assets in <dir>/.github/"
    echo "  cursor              (not applicable — configure via Cursor > Settings > General > Rules for AI)"
    echo "  cursor <dir>        Generate .cursor/rules/code-principles.mdc in <dir>"
    echo "  all                 Global: install claude + copilot (cursor: message)"
    echo "  all <dir>           Local: install all tools in <dir>"
    echo ""
    echo "Management:"
    echo "  --list              Show what's installed"
    echo "  --help              Show this help"
    echo "  ./uninstall.sh      Remove global Claude and Copilot assets"
    echo "  ./uninstall.sh <dir> Remove local assets from <dir>"
    echo ""
    echo "Examples:"
    echo "  ./install.sh claude"
    echo "  ./install.sh claude ~/projects/my-app"
    echo "  ./install.sh copilot"
    echo "  ./install.sh copilot ~/projects/my-app"
    echo "  ./install.sh all ~/projects/my-app"
}

# Main
print_header

DIR_ARG="$(normalize_directory_path "${2:-}")"

case "${1:-}" in
    claude)
        install_claude "$DIR_ARG"
        ;;
    copilot)
        install_copilot "$DIR_ARG"
        ;;
    cursor)
        install_cursor "$DIR_ARG"
        ;;
    all)
        install_claude "$DIR_ARG"
        echo ""
        install_copilot "$DIR_ARG"
        echo ""
        install_cursor "$DIR_ARG"
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
