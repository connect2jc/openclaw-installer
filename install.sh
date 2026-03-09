#!/usr/bin/env bash
set -euo pipefail

# ============================================================================
# OpenCLAW Installer — Interactive Modular Setup
# ============================================================================
# Usage: curl -sL <url>/install.sh | bash
#   or:  bash install.sh
#
# Modules (auto-prompted):
#   1. Core         — CLI + config + directory structure (REQUIRED)
#   2. Memory       — PARA knowledge system + tacit knowledge
#   3. Agents       — Multi-agent workspaces (sales, marketing, research, etc.)
#   4. Discord      — Discord bot integration
#   5. Telegram     — Telegram bot integration
#   6. Dashboard    — Mission Control (Next.js + Convex)
#   7. Cron Jobs    — Automated scheduling
#   8. Skills       — Custom skill packages
#   9. Scripts      — Automation shell scripts
# ============================================================================

OPENCLAW_HOME="${OPENCLAW_HOME:-$HOME/.openclaw}"
INSTALLER_DIR="$(cd "$(dirname "$0")" && pwd)"
LOG_FILE="/tmp/openclaw-install-$(date +%Y%m%d-%H%M%S).log"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# Track selected modules
declare -A MODULES
MODULES[core]=true  # always required

# ============================================================================
# Helpers
# ============================================================================

log() { echo -e "${GREEN}[✓]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }
err() { echo -e "${RED}[✗]${NC} $1"; }
info() { echo -e "${BLUE}[i]${NC} $1"; }
header() { echo -e "\n${BOLD}${CYAN}═══ $1 ═══${NC}\n"; }

ask_yn() {
    local prompt="$1"
    local default="${2:-n}"
    local yn
    if [[ "$default" == "y" ]]; then
        read -rp "$(echo -e "${BOLD}$prompt [Y/n]:${NC} ")" yn
        yn="${yn:-y}"
    else
        read -rp "$(echo -e "${BOLD}$prompt [y/N]:${NC} ")" yn
        yn="${yn:-n}"
    fi
    [[ "$yn" =~ ^[Yy] ]]
}

ask_input() {
    local prompt="$1"
    local default="${2:-}"
    local val
    if [[ -n "$default" ]]; then
        read -rp "$(echo -e "${BOLD}$prompt [${default}]:${NC} ")" val
        echo "${val:-$default}"
    else
        read -rp "$(echo -e "${BOLD}$prompt:${NC} ")" val
        echo "$val"
    fi
}

ask_secret() {
    local prompt="$1"
    local val
    read -srp "$(echo -e "${BOLD}$prompt:${NC} ")" val
    echo ""
    echo "$val"
}

check_command() {
    command -v "$1" &>/dev/null
}

# ============================================================================
# Banner
# ============================================================================

echo -e "
${BOLD}${CYAN}
   ██████╗ ██████╗ ███████╗███╗   ██╗ ██████╗██╗      █████╗ ██╗    ██╗
  ██╔═══██╗██╔══██╗██╔════╝████╗  ██║██╔════╝██║     ██╔══██╗██║    ██║
  ██║   ██║██████╔╝█████╗  ██╔██╗ ██║██║     ██║     ███████║██║ █╗ ██║
  ██║   ██║██╔═══╝ ██╔══╝  ██║╚═╝ ██║██║     ██║     ██╔══██║██║███╗██║
  ╚██████╔╝██║     ███████╗██║ ╚═╝██║╚██████╗███████╗██╔══██║╚███╔███╔╝
   ╚═════╝ ╚═╝     ╚══════╝╚═╝    ╚═╝ ╚═════╝╚══════╝╚═╝  ╚═╝ ╚══╝╚══╝
${NC}
  ${BOLD}Interactive Installer${NC}                              v1.0.0
"

# ============================================================================
# Pre-flight checks
# ============================================================================

header "Pre-flight Checks"

# OS check
OS="$(uname -s)"
case "$OS" in
    Darwin) info "macOS detected" ;;
    Linux)  info "Linux detected" ;;
    *)      err "Unsupported OS: $OS"; exit 1 ;;
esac

# Node.js
if check_command node; then
    NODE_VER="$(node -v)"
    log "Node.js found: $NODE_VER"
    NODE_MAJOR="${NODE_VER#v}"
    NODE_MAJOR="${NODE_MAJOR%%.*}"
    if (( NODE_MAJOR < 18 )); then
        err "Node.js 18+ required (found $NODE_VER)"
        exit 1
    fi
else
    err "Node.js not found. Please install Node.js 18+ first."
    echo "  → https://nodejs.org or: brew install node"
    exit 1
fi

# npm
if check_command npm; then
    log "npm found: $(npm -v)"
else
    err "npm not found"; exit 1
fi

# git
if check_command git; then
    log "git found: $(git --version | awk '{print $3}')"
else
    err "git not found. Please install git first."
    exit 1
fi

# gh (optional)
if check_command gh; then
    log "GitHub CLI found"
else
    warn "GitHub CLI (gh) not found — some features may be limited"
    warn "  → https://cli.github.com or: brew install gh"
fi

# ============================================================================
# Module Selection
# ============================================================================

header "Module Selection"

echo -e "Select which modules to install. ${BOLD}Core is always installed.${NC}\n"

if ask_yn "📝 Memory System — PARA knowledge + tacit knowledge + daily logs" "y"; then
    MODULES[memory]=true
    log "Memory system selected"
else
    MODULES[memory]=false
    info "Memory system skipped"
fi

if ask_yn "🤖 Multi-Agent — Specialized agent workspaces (sales, marketing, research, etc.)" "n"; then
    MODULES[agents]=true
    log "Multi-agent selected"
else
    MODULES[agents]=false
    info "Multi-agent skipped"
fi

if ask_yn "💬 Discord Integration — Discord bot for agent communication" "n"; then
    MODULES[discord]=true
    log "Discord selected"
else
    MODULES[discord]=false
    info "Discord skipped"
fi

if ask_yn "📱 Telegram Integration — Telegram bot for agent communication" "n"; then
    MODULES[telegram]=true
    log "Telegram selected"
else
    MODULES[telegram]=false
    info "Telegram skipped"
fi

if ask_yn "📊 Mission Control Dashboard — Real-time dashboard (Next.js + Convex)" "n"; then
    MODULES[dashboard]=true
    log "Dashboard selected"
else
    MODULES[dashboard]=false
    info "Dashboard skipped"
fi

if ask_yn "⏰ Cron Jobs — Automated scheduling (standup, consolidation, heartbeats)" "n"; then
    MODULES[cron]=true
    log "Cron jobs selected"
else
    MODULES[cron]=false
    info "Cron jobs skipped"
fi

if ask_yn "🔧 Skills — Custom skill packages (browser automation, social media, etc.)" "n"; then
    MODULES[skills]=true
    log "Skills selected"
else
    MODULES[skills]=false
    info "Skills skipped"
fi

if ask_yn "📜 Scripts — Automation shell scripts (heartbeat, sync, hygiene)" "n"; then
    MODULES[scripts]=true
    log "Scripts selected"
else
    MODULES[scripts]=false
    info "Scripts skipped"
fi

# Print summary
header "Installation Summary"
echo -e "  Install location: ${BOLD}$OPENCLAW_HOME${NC}\n"
echo -e "  Modules:"
for mod in core memory agents discord telegram dashboard cron skills scripts; do
    if [[ "${MODULES[$mod]:-false}" == "true" ]]; then
        echo -e "    ${GREEN}●${NC} $mod"
    else
        echo -e "    ${RED}○${NC} $mod"
    fi
done
echo ""

if ! ask_yn "Proceed with installation?" "y"; then
    info "Installation cancelled."
    exit 0
fi

# ============================================================================
# 1. CORE — Always installed
# ============================================================================

header "Installing Core"

# Install OpenClaw CLI
if check_command openclaw; then
    log "OpenClaw CLI already installed: $(openclaw --version 2>/dev/null || echo 'unknown')"
else
    info "Installing OpenClaw CLI via npm..."
    npm install -g openclaw 2>>"$LOG_FILE" && log "OpenClaw CLI installed" || {
        err "Failed to install OpenClaw CLI. Check $LOG_FILE"
        exit 1
    }
fi

# Create directory structure
info "Creating directory structure..."
mkdir -p "$OPENCLAW_HOME"/{workspace,logs,credentials,delivery-queue,memory}
log "Core directories created"

# Collect API keys
header "API Keys"
info "We need at least an Anthropic API key. Others are optional.\n"

ENV_FILE="$OPENCLAW_HOME/.env"

# Only create if doesn't exist
if [[ -f "$ENV_FILE" ]]; then
    warn ".env already exists at $ENV_FILE"
    if ask_yn "Overwrite existing .env?" "n"; then
        WRITE_ENV=true
    else
        WRITE_ENV=false
        log "Keeping existing .env"
    fi
else
    WRITE_ENV=true
fi

if [[ "$WRITE_ENV" == "true" ]]; then
    echo -e "\n${BOLD}Required:${NC}"
    ANTHROPIC_KEY="$(ask_secret "  Anthropic API key (sk-ant-...)")"
    if [[ -z "$ANTHROPIC_KEY" ]]; then
        err "Anthropic API key is required!"
        exit 1
    fi

    echo -e "\n${BOLD}Optional (press Enter to skip):${NC}"
    OPENAI_KEY="$(ask_secret "  OpenAI API key (for fallback model)")"
    BRAVE_KEY="$(ask_secret "  Brave Search API key (for web search)")"

    # Start writing .env
    cat > "$ENV_FILE" <<ENVEOF
# OpenCLAW Environment — generated $(date +%Y-%m-%d)
ANTHROPIC_API_KEY=$ANTHROPIC_KEY
ENVEOF

    [[ -n "$OPENAI_KEY" ]] && echo "OPENAI_API_KEY=$OPENAI_KEY" >> "$ENV_FILE"
    [[ -n "$BRAVE_KEY" ]] && echo "BRAVE_SEARCH_API_KEY=$BRAVE_KEY" >> "$ENV_FILE"

    # Discord keys (if module selected)
    if [[ "${MODULES[discord]}" == "true" ]]; then
        echo ""
        DISCORD_TOKEN="$(ask_secret "  Discord Bot Token")"
        [[ -n "$DISCORD_TOKEN" ]] && echo "DISCORD_BOT_TOKEN=$DISCORD_TOKEN" >> "$ENV_FILE"
    fi

    # Telegram keys (if module selected)
    if [[ "${MODULES[telegram]}" == "true" ]]; then
        echo ""
        TELEGRAM_TOKEN="$(ask_secret "  Telegram Bot Token")"
        [[ -n "$TELEGRAM_TOKEN" ]] && echo "TELEGRAM_BOT_TOKEN=$TELEGRAM_TOKEN" >> "$ENV_FILE"
    fi

    # Dashboard keys (if module selected)
    if [[ "${MODULES[dashboard]}" == "true" ]]; then
        echo ""
        CONVEX_URL="$(ask_input "  Convex Deployment URL")"
        CONVEX_KEY="$(ask_secret "  Convex Deploy Key")"
        [[ -n "$CONVEX_URL" ]] && echo "CONVEX_URL=$CONVEX_URL" >> "$ENV_FILE"
        [[ -n "$CONVEX_KEY" ]] && echo "CONVEX_DEPLOY_KEY=$CONVEX_KEY" >> "$ENV_FILE"
    fi

    # Twitter keys (optional, prompt only if skills/agents selected)
    if [[ "${MODULES[skills]}" == "true" ]] || [[ "${MODULES[agents]}" == "true" ]]; then
        echo ""
        if ask_yn "  Do you have Twitter/X API credentials?" "n"; then
            TW_API_KEY="$(ask_secret "    Twitter API Key")"
            TW_API_SECRET="$(ask_secret "    Twitter API Secret")"
            TW_BEARER="$(ask_secret "    Twitter Bearer Token")"
            TW_ACCESS="$(ask_secret "    Twitter Access Token")"
            TW_ACCESS_SECRET="$(ask_secret "    Twitter Access Token Secret")"
            [[ -n "$TW_API_KEY" ]] && echo "TWITTER_API_KEY=$TW_API_KEY" >> "$ENV_FILE"
            [[ -n "$TW_API_SECRET" ]] && echo "TWITTER_API_SECRET=$TW_API_SECRET" >> "$ENV_FILE"
            [[ -n "$TW_BEARER" ]] && echo "TWITTER_BEARER_TOKEN=$TW_BEARER" >> "$ENV_FILE"
            [[ -n "$TW_ACCESS" ]] && echo "TWITTER_ACCESS_TOKEN=$TW_ACCESS" >> "$ENV_FILE"
            [[ -n "$TW_ACCESS_SECRET" ]] && echo "TWITTER_ACCESS_TOKEN_SECRET=$TW_ACCESS_SECRET" >> "$ENV_FILE"
        fi
    fi

    chmod 600 "$ENV_FILE"
    log ".env created and secured (chmod 600)"
fi

# Generate openclaw.json
info "Generating configuration..."

AGENT_NAME="$(ask_input "  Your agent's name" "Marvis")"
AGENT_MODEL="$(ask_input "  Default model (claude-sonnet-4-6 / claude-opus-4-6)" "claude-sonnet-4-6")"
GATEWAY_TOKEN="$(openssl rand -hex 16)"

# Build channels array
CHANNELS_JSON="[]"
if [[ "${MODULES[discord]}" == "true" ]]; then
    DISCORD_USER_ID="$(ask_input "  Your Discord User ID (for allowlist)")"
    CHANNELS_JSON=$(cat <<CJEOF
[
    {
      "kind": "discord",
      "token": "\${DISCORD_BOT_TOKEN}",
      "allowFrom": ["$DISCORD_USER_ID"]
    }
  ]
CJEOF
)
    if [[ "${MODULES[telegram]}" == "true" ]]; then
        CHANNELS_JSON=$(cat <<CJEOF
[
    {
      "kind": "discord",
      "token": "\${DISCORD_BOT_TOKEN}",
      "allowFrom": ["$DISCORD_USER_ID"]
    },
    {
      "kind": "telegram",
      "token": "\${TELEGRAM_BOT_TOKEN}",
      "pairing": "dm"
    }
  ]
CJEOF
)
    fi
elif [[ "${MODULES[telegram]}" == "true" ]]; then
    CHANNELS_JSON=$(cat <<CJEOF
[
    {
      "kind": "telegram",
      "token": "\${TELEGRAM_BOT_TOKEN}",
      "pairing": "dm"
    }
  ]
CJEOF
)
fi

# Build tools array
TOOLS_JSON='[]'
if [[ -n "${BRAVE_KEY:-}" ]]; then
    TOOLS_JSON='[
    {
      "kind": "brave-search",
      "apiKey": "${BRAVE_SEARCH_API_KEY}"
    }
  ]'
fi

cat > "$OPENCLAW_HOME/openclaw.json" <<CONFIGEOF
{
  "version": "$(date +%Y.%-m.%-d)",
  "gateway": {
    "listen": "127.0.0.1:39271",
    "auth": { "kind": "token", "token": "$GATEWAY_TOKEN" }
  },
  "auth": {
    "anthropic": { "kind": "env", "var": "ANTHROPIC_API_KEY" }
  },
  "agents": [
    {
      "id": "main",
      "name": "$AGENT_NAME",
      "model": "$AGENT_MODEL",
      "workspace": "$OPENCLAW_HOME/workspace",
      "systemPrompt": "You are $AGENT_NAME, an autonomous AI agent. Read your workspace files for context.",
      "memory": {
        "search": { "mode": "hybrid", "weights": { "vector": 0.7, "text": 0.3 }, "ttl": "6h" }
      },
      "context": {
        "safeguard": "compaction",
        "reserveTokens": 40000
      }
    }
  ],
  "channels": $CHANNELS_JSON,
  "tools": $TOOLS_JSON,
  "exec": {
    "security": "full",
    "shell": "bash"
  },
  "sandbox": { "enabled": false },
  "logging": {
    "dir": "$OPENCLAW_HOME/logs",
    "level": "info"
  }
}
CONFIGEOF

log "openclaw.json created"

# Create workspace identity files
info "Setting up workspace identity..."

YOUR_NAME="$(ask_input "  Your name (for USER.md)" "User")"
YOUR_COMPANY="$(ask_input "  Your company/project name" "My Project")"

cat > "$OPENCLAW_HOME/workspace/USER.md" <<USEREOF
# User Profile

**Name:** $YOUR_NAME
**Company:** $YOUR_COMPANY
**Timezone:** $(ask_input "  Your timezone" "UTC")
USEREOF

cat > "$OPENCLAW_HOME/workspace/SOUL.md" <<SOULEOF
# $AGENT_NAME — Identity

I am $AGENT_NAME, an AI agent managed by $YOUR_NAME.

## Core Principles
1. I am autonomous — I find solutions, not excuses
2. I write everything to files — memory is persistent
3. I prioritize clarity and action over discussion
4. I respect security boundaries and budget constraints

## Operating Rules
- Read SOUL.md → USER.md → MEMORY.md on every session start
- Log all significant decisions to daily logs
- Never expose secrets or credentials
SOULEOF

cat > "$OPENCLAW_HOME/workspace/MEMORY.md" <<MEMEOF
# $AGENT_NAME — Long-Term Memory

## Setup
- Installed: $(date +%Y-%m-%d)
- Owner: $YOUR_NAME ($YOUR_COMPANY)
- Home: $OPENCLAW_HOME

## Key Decisions
(append decisions here as they happen)

## Active Projects
(track your active projects here)
MEMEOF

log "Workspace identity files created"

# ============================================================================
# 2. MEMORY SYSTEM
# ============================================================================

if [[ "${MODULES[memory]}" == "true" ]]; then
    header "Installing Memory System"

    # PARA structure
    mkdir -p "$OPENCLAW_HOME/workspace/memory"/{daily,knowledge/{projects,areas,resources,archive}}
    mkdir -p "$OPENCLAW_HOME/workspace/memory/tacit"

    # PARA Index
    cat > "$OPENCLAW_HOME/workspace/memory/knowledge/INDEX.md" <<PARAEOF
# PARA Knowledge Index

## Projects (time-bound, with deadlines)
<!-- Add project files to knowledge/projects/ -->

## Areas (ongoing responsibilities)
<!-- Add area files to knowledge/areas/ -->

## Resources (reference material)
<!-- Add resource files to knowledge/resources/ -->

## Archive (completed/paused)
<!-- Move completed items to knowledge/archive/ -->
PARAEOF

    # Tacit knowledge templates
    cat > "$OPENCLAW_HOME/workspace/memory/tacit/PREFERENCES.md" <<PREFEOF
# Preferences — $YOUR_NAME

## Communication
- Style: (concise/detailed)
- Tone: (casual/professional)

## Technical
- Languages: (Node.js, Python, etc.)
- Frameworks: (React, etc.)
- Git workflow: (feature branches, trunk-based)

## Work Style
- Autonomy level: (full/supervised)
- Review preference: (before commit/after)
PREFEOF

    cat > "$OPENCLAW_HOME/workspace/memory/tacit/LESSONS.md" <<LESSEOF
# Lessons Learned (append-only)

<!-- Format: YYYY-MM-DD | Lesson | Context -->
LESSEOF

    cat > "$OPENCLAW_HOME/workspace/memory/tacit/SECURITY-RULES.md" <<SECEOF
# Security Rules

1. Never expose API keys, tokens, or passwords
2. Never commit .env files to git
3. Gateway listens on localhost only (127.0.0.1)
4. All external APIs use token authentication
5. Discord/Telegram use allowlist mode
SECEOF

    # Create today's daily log
    TODAY="$(date +%Y-%m-%d)"
    cat > "$OPENCLAW_HOME/workspace/memory/daily/$TODAY.md" <<DAYEOF
# Daily Log — $TODAY

## Summary
OpenCLAW installed and configured.

## Modules Installed
$(for mod in core memory agents discord telegram dashboard cron skills scripts; do
    [[ "${MODULES[$mod]:-false}" == "true" ]] && echo "- $mod"
done)

## Next Steps
- Customize PREFERENCES.md with your working style
- Add your first project to knowledge/projects/
- Start a conversation with your agent
DAYEOF

    log "Memory system created (PARA + tacit + daily)"
fi

# ============================================================================
# 3. MULTI-AGENT WORKSPACES
# ============================================================================

if [[ "${MODULES[agents]}" == "true" ]]; then
    header "Installing Multi-Agent Workspaces"

    echo -e "Available agent specializations:\n"
    echo "  1. sales      — Sales pipeline & outreach"
    echo "  2. marketing  — Content & campaigns"
    echo "  3. research   — Market & tech research"
    echo "  4. twitter     — Twitter/X management"
    echo "  5. linkedin   — LinkedIn management"
    echo "  6. finance    — Budget & expense tracking"
    echo "  7. qc         — Quality control & review"
    echo "  8. aso        — App Store Optimization"
    echo ""

    SELECTED_AGENTS="$(ask_input "  Enter agent numbers (comma-separated, or 'all')" "all")"

    ALL_AGENTS=(sales marketing research twitter linkedin finance qc aso)

    if [[ "$SELECTED_AGENTS" == "all" ]]; then
        AGENTS_TO_INSTALL=("${ALL_AGENTS[@]}")
    else
        AGENTS_TO_INSTALL=()
        IFS=',' read -ra NUMS <<< "$SELECTED_AGENTS"
        for num in "${NUMS[@]}"; do
            num="$(echo "$num" | tr -d ' ')"
            idx=$((num - 1))
            if (( idx >= 0 && idx < ${#ALL_AGENTS[@]} )); then
                AGENTS_TO_INSTALL+=("${ALL_AGENTS[$idx]}")
            fi
        done
    fi

    AGENT_NAMES=(
        [sales]="Sable"
        [marketing]="Maya"
        [research]="Rex"
        [twitter]="Flint"
        [linkedin]="Archer"
        [finance]="Vault"
        [qc]="Vera"
        [aso]="Aria"
    )

    AGENT_ROLES=(
        [sales]="Sales pipeline management, lead qualification, and outreach"
        [marketing]="Content creation, campaign management, and brand strategy"
        [research]="Market research, competitor analysis, and tech scouting"
        [twitter]="Twitter/X content, engagement, and community management"
        [linkedin]="LinkedIn content, networking, and professional outreach"
        [finance]="Budget tracking, expense management, and financial reporting"
        [qc]="Quality assurance, code review, and process auditing"
        [aso]="App Store Optimization, keyword research, and listing management"
    )

    for agent in "${AGENTS_TO_INSTALL[@]}"; do
        agent_name="${AGENT_NAMES[$agent]}"
        agent_role="${AGENT_ROLES[$agent]}"
        ws="$OPENCLAW_HOME/workspace-$agent"

        mkdir -p "$ws/memory"

        cat > "$ws/memory/context.md" <<CTXEOF
# $agent_name — $agent Agent

## Role
$agent_role

## Reporting To
$AGENT_NAME (main agent / orchestrator)

## Guidelines
- Stay focused on your domain
- Write all findings to workspace files
- Report blockers to main agent
- Follow security rules at all times
CTXEOF

        log "Created workspace: $agent ($agent_name)"
    done

    log "Agent workspaces created (${#AGENTS_TO_INSTALL[@]} agents)"
fi

# ============================================================================
# 4. DISCORD INTEGRATION
# ============================================================================

if [[ "${MODULES[discord]}" == "true" ]]; then
    header "Discord Setup"

    if [[ -z "${DISCORD_TOKEN:-}" ]]; then
        warn "No Discord bot token was provided during API key setup."
    fi

    echo -e "\n${BOLD}Manual Steps Required:${NC}\n"
    echo "  1. Go to https://discord.com/developers/applications"
    echo "  2. Click 'New Application' → name it (e.g., 'OpenCLAW Bot')"
    echo "  3. Go to Bot tab → click 'Reset Token' → copy it"
    echo "  4. Enable these Privileged Intents:"
    echo "     - Message Content Intent"
    echo "     - Server Members Intent"
    echo "  5. Go to OAuth2 → URL Generator:"
    echo "     - Scopes: bot"
    echo "     - Permissions: Send Messages, Read Message History, Embed Links"
    echo "  6. Copy the generated URL and open it to invite the bot to your server"
    echo "  7. Paste the bot token in $ENV_FILE as DISCORD_BOT_TOKEN"
    echo ""

    if [[ -n "${DISCORD_TOKEN:-}" ]]; then
        log "Discord token already configured in .env"
    else
        warn "Add DISCORD_BOT_TOKEN to $ENV_FILE when ready"
    fi

    # Create discord credentials placeholder
    mkdir -p "$OPENCLAW_HOME/credentials"
    echo '[]' > "$OPENCLAW_HOME/credentials/discord-allowFrom.json"
    echo '{}' > "$OPENCLAW_HOME/credentials/discord-pairing.json"

    log "Discord integration configured"
fi

# ============================================================================
# 5. TELEGRAM INTEGRATION
# ============================================================================

if [[ "${MODULES[telegram]}" == "true" ]]; then
    header "Telegram Setup"

    echo -e "\n${BOLD}Manual Steps Required:${NC}\n"
    echo "  1. Open Telegram and message @BotFather"
    echo "  2. Send /newbot and follow the prompts"
    echo "  3. Copy the bot token"
    echo "  4. Paste it in $ENV_FILE as TELEGRAM_BOT_TOKEN"
    echo "  5. Start a conversation with your bot"
    echo "  6. OpenCLAW will auto-pair via DM on first message"
    echo ""

    mkdir -p "$OPENCLAW_HOME/credentials"
    echo '[]' > "$OPENCLAW_HOME/credentials/telegram-default-allowFrom.json"
    echo '{}' > "$OPENCLAW_HOME/credentials/telegram-pairing.json"

    log "Telegram integration configured"
fi

# ============================================================================
# 6. DASHBOARD (Mission Control)
# ============================================================================

if [[ "${MODULES[dashboard]}" == "true" ]]; then
    header "Installing Mission Control Dashboard"

    DASHBOARD_DIR="$OPENCLAW_HOME/mission-control"

    if [[ -d "$DASHBOARD_DIR" ]]; then
        warn "Dashboard directory already exists at $DASHBOARD_DIR"
    else
        info "Setting up Mission Control (Next.js + Convex)..."

        mkdir -p "$DASHBOARD_DIR"
        cd "$DASHBOARD_DIR"

        # Initialize package.json
        cat > package.json <<PKGEOF
{
  "name": "openclaw-mission-control",
  "version": "1.0.0",
  "private": true,
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "start": "next start",
    "convex:dev": "npx convex dev",
    "convex:deploy": "npx convex deploy"
  },
  "dependencies": {
    "convex": "^1.32.0",
    "next": "^16.1.6",
    "react": "^19.2.4",
    "react-dom": "^19.2.4"
  },
  "devDependencies": {
    "typescript": "^5.9.3",
    "@types/node": "^22.0.0",
    "@types/react": "^19.0.0"
  }
}
PKGEOF

        info "Installing dashboard dependencies (this may take a minute)..."
        npm install 2>>"$LOG_FILE" && log "Dashboard dependencies installed" || {
            warn "npm install had issues — check $LOG_FILE"
        }

        cd "$OPENCLAW_HOME"
    fi

    echo -e "\n${BOLD}Manual Steps Required:${NC}\n"
    echo "  1. Create a Convex account at https://convex.dev"
    echo "  2. Create a new project"
    echo "  3. Run: cd $DASHBOARD_DIR && npx convex dev"
    echo "  4. Add CONVEX_URL and CONVEX_DEPLOY_KEY to $ENV_FILE"
    echo "  5. Deploy: npx convex deploy"
    echo "  6. For Vercel hosting: vercel --prod"
    echo ""

    log "Dashboard scaffolded at $DASHBOARD_DIR"
fi

# ============================================================================
# 7. CRON JOBS
# ============================================================================

if [[ "${MODULES[cron]}" == "true" ]]; then
    header "Installing Cron Jobs"

    mkdir -p "$OPENCLAW_HOME/cron/runs"

    TZ_INPUT="$(ask_input "  Your timezone for cron jobs" "UTC")"

    # Generate a starter cron jobs config
    cat > "$OPENCLAW_HOME/cron/jobs.json" <<CRONEOF
[
  {
    "id": "morning-standup",
    "name": "Morning Standup",
    "enabled": true,
    "schedule": {
      "kind": "cron",
      "expr": "30 7 * * *",
      "tz": "$TZ_INPUT"
    },
    "payload": {
      "kind": "agentTurn",
      "agent": "main",
      "message": "Good morning. Review yesterday's daily log, check pending tasks, and prepare today's plan. Write today's daily log."
    },
    "delivery": {
      "mode": "announce"
    }
  },
  {
    "id": "nightly-consolidation",
    "name": "Nightly Consolidation",
    "enabled": true,
    "schedule": {
      "kind": "cron",
      "expr": "0 2 * * *",
      "tz": "$TZ_INPUT"
    },
    "payload": {
      "kind": "agentTurn",
      "agent": "main",
      "message": "Run nightly consolidation: review today's daily log, update MEMORY.md with key decisions, check for stale data in knowledge files, and clean up any contradictions."
    },
    "delivery": {
      "mode": "announce"
    }
  },
  {
    "id": "weekly-review",
    "name": "Weekly Review",
    "enabled": true,
    "schedule": {
      "kind": "cron",
      "expr": "0 10 * * 0",
      "tz": "$TZ_INPUT"
    },
    "payload": {
      "kind": "agentTurn",
      "agent": "main",
      "message": "Weekly review: summarize the week's progress, update project statuses, identify blockers, and plan next week's priorities."
    },
    "delivery": {
      "mode": "announce"
    }
  }
]
CRONEOF

    log "Cron jobs configured (3 starter jobs)"
    info "  → Morning standup: 7:30 AM $TZ_INPUT"
    info "  → Nightly consolidation: 2:00 AM $TZ_INPUT"
    info "  → Weekly review: Sunday 10:00 AM $TZ_INPUT"
fi

# ============================================================================
# 8. SKILLS
# ============================================================================

if [[ "${MODULES[skills]}" == "true" ]]; then
    header "Installing Skills"

    mkdir -p "$OPENCLAW_HOME/workspace/skills"

    echo -e "Available skill categories:\n"
    echo "  1. agent-browser  — Browser automation (persistent sessions)"
    echo "  2. git-essentials — Git operations"
    echo "  3. social-media   — Twitter, LinkedIn management"
    echo "  4. productivity   — Calendar, email, Slack"
    echo "  5. deployment     — Vercel, Railway deployment"
    echo "  6. seo            — SEO analysis and optimization"
    echo ""

    SELECTED_SKILLS="$(ask_input "  Enter skill numbers (comma-separated, or 'all')" "1,2")"

    SKILL_DIRS=(agent-browser git-essentials social-media productivity deployment seo)

    if [[ "$SELECTED_SKILLS" == "all" ]]; then
        SKILLS_TO_INSTALL=("${SKILL_DIRS[@]}")
    else
        SKILLS_TO_INSTALL=()
        IFS=',' read -ra NUMS <<< "$SELECTED_SKILLS"
        for num in "${NUMS[@]}"; do
            num="$(echo "$num" | tr -d ' ')"
            idx=$((num - 1))
            if (( idx >= 0 && idx < ${#SKILL_DIRS[@]} )); then
                SKILLS_TO_INSTALL+=("${SKILL_DIRS[$idx]}")
            fi
        done
    fi

    for skill in "${SKILLS_TO_INSTALL[@]}"; do
        skill_dir="$OPENCLAW_HOME/workspace/skills/$skill"
        mkdir -p "$skill_dir"

        cat > "$skill_dir/SKILL.md" <<SKILLEOF
# $skill

## Status
Installed (scaffold) — configure as needed.

## Usage
Invoke via: openclaw skill run $skill

## Configuration
Edit this file and add skill-specific config below.
SKILLEOF

        log "Skill scaffolded: $skill"
    done

    log "Skills installed (${#SKILLS_TO_INSTALL[@]} skills)"
fi

# ============================================================================
# 9. SCRIPTS
# ============================================================================

if [[ "${MODULES[scripts]}" == "true" ]]; then
    header "Installing Automation Scripts"

    mkdir -p "$OPENCLAW_HOME/scripts"

    # Agent heartbeat script
    cat > "$OPENCLAW_HOME/scripts/agent-heartbeat.sh" <<'HBEOF'
#!/usr/bin/env bash
# Agent heartbeat — checks notifications and updates status
set -euo pipefail
OPENCLAW_HOME="${OPENCLAW_HOME:-$HOME/.openclaw}"
AGENT="${1:-main}"
TIMESTAMP="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
echo "[heartbeat] $AGENT at $TIMESTAMP"
openclaw agent --message "Heartbeat check: review pending notifications and update status." --agent "$AGENT" 2>/dev/null || echo "[heartbeat] Agent $AGENT not responding"
HBEOF

    # Memory hygiene script
    cat > "$OPENCLAW_HOME/scripts/memory-hygiene.sh" <<'MHEOF'
#!/usr/bin/env bash
# Memory hygiene — deterministic checker for stale data
set -euo pipefail
OPENCLAW_HOME="${OPENCLAW_HOME:-$HOME/.openclaw}"
MEMORY_DIR="$OPENCLAW_HOME/workspace/memory"
echo "[hygiene] Checking memory files..."

# Check for files not modified in 30+ days
find "$MEMORY_DIR/knowledge" -name "*.md" -mtime +30 -print | while read -r file; do
    echo "[stale] $file (not modified in 30+ days)"
done

# Check daily log exists for today
TODAY="$(date +%Y-%m-%d)"
if [[ ! -f "$MEMORY_DIR/daily/$TODAY.md" ]]; then
    echo "[missing] No daily log for $TODAY"
fi

echo "[hygiene] Done."
MHEOF

    # Auto-commit script
    cat > "$OPENCLAW_HOME/scripts/auto-commit.sh" <<'ACEOF'
#!/usr/bin/env bash
# Auto-commit workspace changes to git
set -euo pipefail
OPENCLAW_HOME="${OPENCLAW_HOME:-$HOME/.openclaw}"
WS="$OPENCLAW_HOME/workspace"

if [[ ! -d "$WS/.git" ]]; then
    echo "[auto-commit] Workspace is not a git repo. Initialize with: cd $WS && git init"
    exit 0
fi

cd "$WS"
if [[ -n "$(git status --porcelain)" ]]; then
    git add -A
    git commit -m "auto: workspace sync $(date +%Y-%m-%d_%H:%M)"
    echo "[auto-commit] Changes committed."
else
    echo "[auto-commit] No changes."
fi
ACEOF

    # Convex sync script
    cat > "$OPENCLAW_HOME/scripts/convex-sync.sh" <<'CSEOF'
#!/usr/bin/env bash
# Sync data to Convex backend
set -euo pipefail
OPENCLAW_HOME="${OPENCLAW_HOME:-$HOME/.openclaw}"
source "$OPENCLAW_HOME/.env" 2>/dev/null || true

ACTION="${1:-heartbeat}"
AGENT="${2:-main}"

if [[ -z "${CONVEX_URL:-}" ]]; then
    echo "[convex-sync] CONVEX_URL not set — skipping"
    exit 0
fi

case "$ACTION" in
    heartbeat)
        curl -s "$CONVEX_URL/api/mutation" \
            -H "Content-Type: application/json" \
            -d "{\"path\":\"agents:heartbeat\",\"args\":{\"agentId\":\"$AGENT\"}}" \
            > /dev/null 2>&1
        echo "[convex-sync] Heartbeat sent for $AGENT"
        ;;
    status)
        STATUS="${3:-idle}"
        curl -s "$CONVEX_URL/api/mutation" \
            -H "Content-Type: application/json" \
            -d "{\"path\":\"agents:updateStatus\",\"args\":{\"agentId\":\"$AGENT\",\"status\":\"$STATUS\"}}" \
            > /dev/null 2>&1
        echo "[convex-sync] Status updated: $AGENT → $STATUS"
        ;;
    *)
        echo "Usage: convex-sync.sh [heartbeat|status] [agent] [value]"
        ;;
esac
CSEOF

    # Session memory sync
    cat > "$OPENCLAW_HOME/scripts/session-memory-sync.sh" <<'SMEOF'
#!/usr/bin/env bash
# Sync session memories to persistent files
set -euo pipefail
OPENCLAW_HOME="${OPENCLAW_HOME:-$HOME/.openclaw}"
echo "[session-sync] Syncing session memories..."
openclaw memory sync 2>/dev/null || echo "[session-sync] Memory sync skipped (no active session)"
SMEOF

    # Make all scripts executable
    chmod +x "$OPENCLAW_HOME/scripts/"*.sh

    log "Scripts installed (5 scripts)"
    info "All scripts are in $OPENCLAW_HOME/scripts/"
fi

# ============================================================================
# Exec Approvals
# ============================================================================

header "Security Configuration"

cat > "$OPENCLAW_HOME/exec-approvals.json" <<EXECEOF
{
  "main": [
    "node *",
    "npm *",
    "git *",
    "cat *",
    "ls *",
    "mkdir *",
    "openclaw *",
    "curl *",
    "gh *",
    "bash $OPENCLAW_HOME/scripts/*.sh"
  ]
}
EXECEOF

log "Exec approvals configured (main agent)"

# ============================================================================
# Final Summary
# ============================================================================

header "Installation Complete!"

echo -e "${GREEN}${BOLD}OpenCLAW has been installed successfully!${NC}\n"
echo -e "  ${BOLD}Home:${NC}        $OPENCLAW_HOME"
echo -e "  ${BOLD}Config:${NC}      $OPENCLAW_HOME/openclaw.json"
echo -e "  ${BOLD}Secrets:${NC}     $OPENCLAW_HOME/.env"
echo -e "  ${BOLD}Workspace:${NC}   $OPENCLAW_HOME/workspace"
echo -e "  ${BOLD}Logs:${NC}        $OPENCLAW_HOME/logs"
echo -e "  ${BOLD}Install log:${NC} $LOG_FILE"

echo -e "\n${BOLD}Installed Modules:${NC}"
for mod in core memory agents discord telegram dashboard cron skills scripts; do
    if [[ "${MODULES[$mod]:-false}" == "true" ]]; then
        echo -e "  ${GREEN}✓${NC} $mod"
    fi
done

echo -e "\n${BOLD}Quick Start:${NC}"
echo "  1. Start the gateway:     openclaw gateway start"
echo "  2. Chat with your agent:  openclaw agent --message \"Hello!\""
echo "  3. Check status:          openclaw status"

if [[ "${MODULES[discord]}" == "true" ]] || [[ "${MODULES[telegram]}" == "true" ]]; then
    echo ""
    echo -e "${BOLD}Channel Setup:${NC}"
    [[ "${MODULES[discord]}" == "true" ]] && echo "  Discord: Ensure DISCORD_BOT_TOKEN is set, then: openclaw gateway start"
    [[ "${MODULES[telegram]}" == "true" ]] && echo "  Telegram: Ensure TELEGRAM_BOT_TOKEN is set, then message your bot"
fi

if [[ "${MODULES[dashboard]}" == "true" ]]; then
    echo ""
    echo -e "${BOLD}Dashboard:${NC}"
    echo "  cd $OPENCLAW_HOME/mission-control && npm run dev"
fi

echo -e "\n${BOLD}Next Steps:${NC}"
echo "  → Customize $OPENCLAW_HOME/workspace/SOUL.md with your agent's personality"
echo "  → Edit $OPENCLAW_HOME/workspace/USER.md with your details"
[[ "${MODULES[memory]}" == "true" ]] && echo "  → Fill in $OPENCLAW_HOME/workspace/memory/tacit/PREFERENCES.md"
echo "  → Read the full guide: $OPENCLAW_HOME/GUIDE.md"
echo ""
echo -e "${CYAN}Happy automating! 🤖${NC}"
