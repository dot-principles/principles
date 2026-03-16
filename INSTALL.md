# Installation

This guide covers installing `.principles` on Linux, macOS, and Windows.

---

## Prerequisites

- **Bash 4+** — required by `install.sh` / `uninstall.sh`
- **AI model** — Claude Haiku 4.5+, GPT-4.1+, or equivalent

See [REQUIREMENTS.md](REQUIREMENTS.md) for platform-specific setup and model compatibility details.

---

## 1. Clone the repo

```bash
git clone https://github.com/code-principles/.principles.git
cd .principles
```

---

## 2. Install

### Linux / macOS

Bash is pre-installed on both platforms. Run the installer directly:

```bash
# Claude Code — global (all projects)
./install.sh claude

# Claude Code — local (one project)
./install.sh claude ~/projects/my-app

# GitHub Copilot — global
./install.sh copilot

# GitHub Copilot — local (one project)
./install.sh copilot ~/projects/my-app

# Cursor — local only (global requires manual setup in Cursor settings)
./install.sh cursor ~/projects/my-app

# All tools — global
./install.sh all

# All tools — local
./install.sh all ~/projects/my-app
```

---

### Windows

Windows users need bash on `PATH`. The repo ships thin wrapper scripts for both PowerShell and Command Prompt that detect bash and forward arguments to the real `install.sh`.

**Step 1 — get bash.** Install [Git for Windows](https://git-scm.com/download/win) (includes Git Bash). WSL, MSYS2, and Cygwin also work as long as `bash` is on `PATH`.

**Step 2 — run the wrapper.**

**PowerShell:**

```powershell
# Claude Code — global
.\install.ps1 claude

# Claude Code — local
.\install.ps1 claude ~/projects/my-app

# GitHub Copilot — global
.\install.ps1 copilot

# GitHub Copilot — local
.\install.ps1 copilot ~/projects/my-app

# Cursor — local only
.\install.ps1 cursor ~/projects/my-app

# All tools — global
.\install.ps1 all

# All tools — local
.\install.ps1 all ~/projects/my-app
```

**Command Prompt:**

```cmd
install.cmd claude
install.cmd claude ~/projects/my-app
install.cmd copilot
install.cmd copilot ~/projects/my-app
install.cmd cursor ~/projects/my-app
install.cmd all ~/projects/my-app
```

> **Path note:** On Windows, `~` is equivalent to `%USERPROFILE%` (e.g. `C:\Users\YourName`). Both wrapper styles handle Windows absolute paths for you. `install.cmd` / `uninstall.cmd` normalize backslashes to forward slashes before calling bash, and `install.ps1` / `uninstall.ps1` convert `C:\...` paths to a bash-friendly absolute path.

---

## 3. Installation scopes

Every tool supports two scopes:

| Command                    | Scope  | Where it installs                             |
|----------------------------|--------|-----------------------------------------------|
| `install.sh claude`        | Global | `~/.claude/commands/`                         |
| `install.sh claude <dir>`  | Local  | `<dir>/.claude/commands/`                     |
| `install.sh copilot`       | Global | `~/.copilot/copilot-instructions.md`          |
| `install.sh copilot <dir>` | Local  | `<dir>/.github/` (instructions + skills + prompts) |
| `install.sh cursor`        | —      | Not supported (see Cursor note below)         |
| `install.sh cursor <dir>`  | Local  | `<dir>/.cursor/rules/principles.mdc`          |
| `install.sh all`           | Global | Claude + Copilot globally; Cursor message     |
| `install.sh all <dir>`     | Local  | All three tools in `<dir>`                    |

### Claude Code — global commands work everywhere

Claude Code stores commands in `~/.claude/commands/`. Once installed globally, `/scout`, `/prime`, and `/audit` are available in every project automatically — no per-project setup needed.

### GitHub Copilot — global installation is passive only

GitHub Copilot has no user-level location for skills or prompt files. The global installation (`install.sh copilot`) writes **only** `~/.copilot/copilot-instructions.md` — a brief Layer 1/2/3 summary that Copilot reads as background context. This gives Copilot passive awareness of the principle layers, but **`/scout`, `/prime`, and `/audit` are not available** from the global installation alone.

To get the slash commands in a project, run the **local install** once per project:

```bash
./install.sh copilot ~/projects/my-app
# Windows:
.\install.ps1 copilot C:\projects\my-app
```

This writes into `.github/` inside that project:


| File                              | Purpose                                      |
|-----------------------------------|----------------------------------------------|
| `.github/copilot-instructions.md` | Always-on context for all Copilot clients    |
| `.github/prompts/prime.prompt.md` | `/prime` in VS Code / JetBrains Copilot Chat |
| `.github/prompts/audit.prompt.md` | `/audit` in VS Code / JetBrains Copilot Chat |
| `.github/prompts/scout.prompt.md` | `/scout` in VS Code / JetBrains Copilot Chat |
| `.github/skills/prime/SKILL.md`   | `/prime` in Copilot CLI                      |
| `.github/skills/audit/SKILL.md`   | `/audit` in Copilot CLI                      |
| `.github/skills/scout/SKILL.md`   | `/scout` in Copilot CLI                      |
Commit these files to the repository so every team member gets the commands automatically.

### Principles data directory

Every Claude install (global or local) copies the `groups/` and `principles/` data files to `~/.principles`:

| Platform                 | Path                        |
|--------------------------|-----------------------------|
| Linux / macOS            | `~/.principles`             |
| Windows (Git Bash / WSL) | `%USERPROFILE%\.principles` |

The data directory is **created or refreshed on every install** — old files are replaced with the current repo content. The installed command files (`/scout`, `/prime`, `/audit`) reference this fixed path, so the AI tool can always find the data regardless of where the repo lives.

Running `./uninstall.sh` (global) removes `~/.principles` along with the command files. Local uninstalls (`./uninstall.sh <dir>`) do not remove it, since it is shared across all installations.

### Cursor limitation

Cursor has no file-based user-level config. For global principles, go to **Cursor → Settings → General → Rules for AI** and paste the principle content there manually. For a single project, use `install.sh cursor <dir>`.

---

## 4. Verify

```bash
./install.sh --list
```

Shows what is currently installed globally.

---

## 5. Uninstall

```bash
# Remove global assets
./uninstall.sh

# Remove local assets from a project
./uninstall.sh ~/projects/my-app
```

On Windows, use `uninstall.ps1` or `uninstall.cmd` with the same arguments.

---

## 6. Try it on a branch first

Not ready to commit to a project? Install locally into a throwaway branch:

```bash
cd ~/projects/my-app
git checkout -b try-principles

# Install into this project directory only
/path/to/.principles/install.sh claude .
# or on Windows:
# \path\to\.principles\install.ps1 claude .

# Run /scout, /prime, /audit — explore without touching your main branch
# When done, delete the branch to remove the local .claude/commands/
git checkout main && git branch -D try-principles
```

Local installations write only into `<dir>/.claude/commands/` (or `.github/`, `.cursor/rules/`) — they leave your global setup untouched and disappear with the branch.

## 7. After installing

Open your AI tool and run the commands:

```
/scout     → detect project profile and create .principles files
/prime     → activate principles before writing code
/audit     → review code with severity-categorized findings
```

> **Copilot users:** `/scout`, `/prime`, and `/audit` require a **local** installation in your project (`.github/prompts/` or `.github/skills/`). The global installation alone is not enough. Run `install.sh copilot <your-project>` first — see [Section 3](#3-installation-scopes) above.

See [README.md](README.md) for a full walkthrough and examples.
