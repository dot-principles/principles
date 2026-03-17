#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# Copyright (c) 2026 Flemming N. Larsen — https://github.com/code-principles/.principles
set -euo pipefail

# uninstall.sh — Remove code-principles assets from supported AI coding tools
#
# Usage:
#   ./uninstall.sh             # Remove global assets:
#                              #   Claude Code: ~/.claude/commands/<name>.md
#                              #   Copilot:     ~/.copilot/copilot-instructions.md (code-principles block only)
#   ./uninstall.sh <project>   # Remove local assets from <project>:
#                              #   Claude Code: <project>/.claude/commands/<name>.md
#                              #   Copilot CLI: .github/skills/<name>/SKILL.md
#                              #   Copilot IDE: .github/prompts/<name>.prompt.md
#                              #               .github/copilot-instructions.md (code-principles block only)
#                              #   Cursor:      .cursor/rules/code-principles.mdc
#   ./uninstall.sh --help      # Show this help

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

# Resolve the home directory for global asset removal.
# When invoked via WSL (e.g. PowerShell 7 finds the WSL bash instead of Git
# Bash), $HOME is the Linux home (/home/<user>) but assets live in the
# Windows user profile where they were installed.
resolve_home() {
    if [ -n "${PRINCIPLES_WIN_HOME:-}" ]; then
        # Set by uninstall.ps1 — Windows USERPROFILE with forward slashes.
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

UNINSTALL_SCOPE="global"
PROJECT_DIR=""
if [ -n "${1:-}" ] && [[ "${1:-}" != --* ]]; then
    UNINSTALL_SCOPE="local"
    PROJECT_DIR="$(normalize_directory_path "$1")"
fi

# Colors (if terminal supports them)
if [ -t 1 ]; then
    GREEN='\033[0;32m'
    RED='\033[0;31m'
    BOLD='\033[1m'
    NC='\033[0m'
else
    GREEN='' RED='' BOLD='' NC=''
fi

NEUTRAL='-'

cleanup_dir_if_empty() {
    local dir="$1"

    if [ -d "$dir" ] && [ -z "$(find "$dir" -mindepth 1 -maxdepth 1 -print -quit 2>/dev/null)" ]; then
        rmdir "$dir"
    fi
}

require_project_dir() {
    if [ -n "$PROJECT_DIR" ] && [ ! -d "$PROJECT_DIR" ]; then
        echo -e "${RED}Error: Directory '$PROJECT_DIR' does not exist.${NC}"
        exit 1
    fi
}

print_header() {
    echo ""
    echo -e "${BOLD}code-principles uninstaller${NC}"
    echo "───────────────────────────"
}

show_usage() {
    print_header
    echo ""
    echo "Usage: $0 [project-dir]"
    echo ""
    echo "Removes code-principles assets for Claude Code, GitHub Copilot, and Cursor."
    echo ""
    echo "  (no arg)            Remove global assets (~/.claude/commands/, ~/.copilot/)"
    echo "  <dir>               Remove local assets from <dir>/.claude/, .github/, .cursor/"
    echo ""
    echo "Options:"
    echo "  --help              Show this help"
}

uninstall_data() {
    if [ -d "$DATA_DIR" ]; then
        rm -rf "$DATA_DIR"
        echo -e "  ${GREEN}✓${NC} Removed $DATA_DIR"
    fi
}

uninstall_claude() {
    local project_dir="${1:-}"
    local target_dir
    local scope_label

    if [ -n "$project_dir" ]; then
        target_dir="$project_dir/.claude/commands"
        scope_label="local: $project_dir"
    else
        target_dir="$CLAUDE_COMMANDS_DIR"
        scope_label="global"
    fi

    echo -e "${BOLD}Removing Claude Code slash commands ($scope_label)...${NC}"

    local count=0
    local found_target=false
    local file

    for file in "$CLAUDE_TARGETS_DIR/"*.md; do
        if [ -f "$file" ]; then
            found_target=true
            local installed_file="$target_dir/$(basename "$file")"
            if [ -f "$installed_file" ]; then
                rm "$installed_file"
                count=$((count + 1))
                echo -e "  ${GREEN}✓${NC} /$(basename "$file" .md)"
            fi
        fi
    done

    if [ "$found_target" = false ]; then
        echo -e "${RED}Error: No Claude Code command templates found in $CLAUDE_TARGETS_DIR.${NC}"
        exit 1
    fi

    if [ $count -eq 0 ]; then
        echo "  ${NEUTRAL} No current commands found to remove."
    else
        echo ""
        echo -e "Removed ${GREEN}$count${NC} commands."
    fi

    if [ -n "$project_dir" ]; then
        cleanup_dir_if_empty "$target_dir"
        cleanup_dir_if_empty "$project_dir/.claude"
    else
        echo ""
        echo -e "${BOLD}Removing .principles data...${NC}"
        uninstall_data
    fi
}

uninstall_copilot() {
    local project_dir="${1:-}"
    if [ -n "$project_dir" ]; then
        uninstall_copilot_local "$project_dir"
    else
        uninstall_copilot_global
    fi
}

uninstall_copilot_local() {
    local project_dir="$1"
    local target_file="$project_dir/.github/copilot-instructions.md"
    local prompts_dir="$project_dir/.github/prompts"
    local skills_dir="$project_dir/.github/skills"

    echo -e "${BOLD}Removing GitHub Copilot instructions...${NC}"

    if [ ! -f "$target_file" ]; then
        echo "  ${NEUTRAL} No Copilot instructions found to remove."
        return
    fi

    local temp_file
    temp_file="$(mktemp)"

    awk '
        BEGIN { in_block=0; removed=0 }
        /^<!-- code-principles: begin -->$/ { in_block=1; removed=1; next }
        /^<!-- code-principles: end -->$/   { if (in_block) { in_block=0; next } }
        !in_block { print }
        END { exit removed ? 0 : 1 }
    ' "$target_file" > "$temp_file" || {
        rm -f "$temp_file"
        echo "  ${NEUTRAL} No code-principles Copilot instructions found to remove."
        return
    }

    # Trim trailing blank lines left after block removal
    awk '{lines[NR]=$0; if(/[^[:space:]]/) last=NR} END{for(i=1;i<=last;i++) print lines[i]}' \
        "$temp_file" > "${temp_file}.t" && mv "${temp_file}.t" "$temp_file"

    if grep -q '[^[:space:]]' "$temp_file"; then
        mv "$temp_file" "$target_file"
        echo -e "  ${GREEN}✓${NC} .github/copilot-instructions.md (removed code-principles block)"
    else
        rm -f "$temp_file" "$target_file"
        echo -e "  ${GREEN}✓${NC} .github/copilot-instructions.md"
    fi

    echo ""
    echo -e "${BOLD}Removing GitHub Copilot skills...${NC}"

    local skill_count=0
    local file
    for file in "$CLAUDE_TARGETS_DIR/"*.md; do
        if [ -f "$file" ]; then
            local command_name
            command_name="$(basename "$file" .md)"
            local skill_dir="$skills_dir/$command_name"
            if [ -d "$skill_dir" ]; then
                rm -rf "$skill_dir"
                skill_count=$((skill_count + 1))
                echo -e "  ${GREEN}✓${NC} .github/skills/$command_name/"
            fi
        fi
    done

    if [ $skill_count -eq 0 ]; then
        echo "  ${NEUTRAL} No Copilot skills found to remove."
    fi

    echo ""
    echo -e "${BOLD}Removing GitHub Copilot prompt commands...${NC}"

    local prompt_count=0
    for file in "$CLAUDE_TARGETS_DIR/"*.md; do
        if [ -f "$file" ]; then
            local prompt_file="$prompts_dir/$(basename "$file" .md).prompt.md"
            if [ -f "$prompt_file" ]; then
                rm "$prompt_file"
                prompt_count=$((prompt_count + 1))
                echo -e "  ${GREEN}✓${NC} .github/prompts/$(basename "$prompt_file")"
            fi
        fi
    done

    if [ $prompt_count -eq 0 ]; then
        echo "  ${NEUTRAL} No Copilot prompt commands found to remove."
    fi

    cleanup_dir_if_empty "$skills_dir"
    cleanup_dir_if_empty "$prompts_dir"
    cleanup_dir_if_empty "$project_dir/.github"
}

uninstall_copilot_global() {
    local target_file="$EFFECTIVE_HOME/.copilot/copilot-instructions.md"

    echo -e "${BOLD}Removing global Copilot instructions...${NC}"

    if [ ! -f "$target_file" ]; then
        echo "  ${NEUTRAL} No global Copilot instructions found to remove."
        return
    fi

    local temp_file
    temp_file="$(mktemp)"

    awk '
        BEGIN { in_block=0; removed=0 }
        /^<!-- code-principles: begin -->$/ { in_block=1; removed=1; next }
        /^<!-- code-principles: end -->$/   { if (in_block) { in_block=0; next } }
        !in_block { print }
        END { exit removed ? 0 : 1 }
    ' "$target_file" > "$temp_file" || {
        rm -f "$temp_file"
        echo "  ${NEUTRAL} No code-principles block found in global Copilot instructions."
        return
    }

    awk '{lines[NR]=$0; if(/[^[:space:]]/) last=NR} END{for(i=1;i<=last;i++) print lines[i]}' \
        "$temp_file" > "${temp_file}.t" && mv "${temp_file}.t" "$temp_file"

    if grep -q '[^[:space:]]' "$temp_file"; then
        mv "$temp_file" "$target_file"
        echo -e "  ${GREEN}✓${NC} ~/.copilot/copilot-instructions.md (removed code-principles block)"
    else
        rm -f "$temp_file" "$target_file"
        echo -e "  ${GREEN}✓${NC} ~/.copilot/copilot-instructions.md"
    fi

    cleanup_dir_if_empty "$EFFECTIVE_HOME/.copilot"
}

uninstall_cursor() {
    local project_dir="${1:-}"

    if [ -z "$project_dir" ]; then
        echo -e "${BOLD}Cursor — global/user scope not supported${NC}"
        echo ""
        echo "Cursor does not support file-based user-level rules."
        echo "Configure manually: Cursor > Settings > General > Rules for AI"
        echo ""
        echo "For project-level removal: ./uninstall.sh <project-dir>"
        return 0
    fi

    local target_file="$project_dir/.cursor/rules/code-principles.mdc"

    echo -e "${BOLD}Removing Cursor rules...${NC}"

    if [ ! -f "$target_file" ]; then
        echo "  ${NEUTRAL} No Cursor rule found to remove."
        return
    fi

    rm "$target_file"
    echo -e "  ${GREEN}✓${NC} .cursor/rules/code-principles.mdc"

    cleanup_dir_if_empty "$project_dir/.cursor/rules"
    cleanup_dir_if_empty "$project_dir/.cursor"
}

run_uninstall() {
    require_project_dir

    print_header
    echo ""
    uninstall_claude "$PROJECT_DIR"
    echo ""
    uninstall_copilot "$PROJECT_DIR"
    echo ""
    uninstall_cursor "$PROJECT_DIR"
    echo ""
    echo "Done."
}

case "${1:-}" in
    --help|-h)
        show_usage
        ;;
    "")
        run_uninstall
        ;;
    *)
        if [[ "$1" == -* ]]; then
            echo -e "${RED}Unknown option: $1${NC}"
            show_usage
            exit 1
        fi

        run_uninstall
        ;;
esac
