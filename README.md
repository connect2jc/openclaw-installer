# OpenCLAW Installer

Interactive, modular installer for [OpenCLAW](https://github.com/openclaw) — your autonomous AI agent platform.

One script. Pick what you need. It sets up everything automatically.

## Quick Start

```bash
git clone https://github.com/connect2jc/openclaw-installer.git
cd openclaw-installer
bash install.sh
```

## What It Does

The installer walks you through setup interactively — no manual config editing needed.

```
═══ Module Selection ═══

📝 Memory System — PARA knowledge + tacit knowledge + daily logs [Y/n]: y
🤖 Multi-Agent — Specialized agent workspaces [y/N]: n
💬 Discord Integration — Discord bot for agent communication [y/N]: y
📱 Telegram Integration — Telegram bot for communication [y/N]: n
📊 Mission Control Dashboard — Real-time dashboard [y/N]: n
⏰ Cron Jobs — Automated scheduling [y/N]: y
🔧 Skills — Custom skill packages [y/N]: n
📜 Scripts — Automation shell scripts [y/N]: y
```

## Modules

| Module | Description | Required |
|--------|-------------|----------|
| **Core** | CLI, config, directory structure, API keys | Always |
| **Memory** | PARA knowledge system, tacit knowledge, daily logs | No |
| **Agents** | Specialized workspaces — sales, marketing, research, twitter, linkedin, finance, QC, ASO | No |
| **Discord** | Discord bot integration + setup guide | No |
| **Telegram** | Telegram bot integration + setup guide | No |
| **Dashboard** | Mission Control (Next.js + Convex) | No |
| **Cron Jobs** | Morning standup, nightly consolidation, weekly review | No |
| **Skills** | Browser automation, git, social media, SEO, deployment | No |
| **Scripts** | Heartbeat, memory hygiene, auto-commit, Convex sync | No |

## Prerequisites

- **Node.js 18+** — `brew install node`
- **npm** — comes with Node.js
- **git** — `brew install git`
- **GitHub CLI** (optional) — `brew install gh`

## What You'll Need

At minimum, an **Anthropic API key**. Everything else is optional based on your module selection:

| Key | Module |
|-----|--------|
| Anthropic API key | Core (required) |
| OpenAI API key | Core (fallback model) |
| Brave Search API key | Core (web search) |
| Discord Bot Token | Discord |
| Telegram Bot Token | Telegram |
| Convex Deploy Key | Dashboard |
| Twitter API keys | Agents / Skills |

## What Gets Created

```
~/.openclaw/
├── openclaw.json          # Auto-generated config
├── .env                   # API keys (secured)
├── workspace/             # Your agent's home
│   ├── SOUL.md           # Agent identity
│   ├── USER.md           # Your profile
│   ├── MEMORY.md         # Long-term memory
│   └── memory/           # Knowledge system
├── workspace-*/           # Agent workspaces (if multi-agent)
├── scripts/              # Automation scripts
├── cron/                 # Scheduled jobs
├── credentials/          # Stored credentials
└── logs/                 # System logs
```

## After Install

```bash
# Start the gateway
openclaw gateway start

# Talk to your agent
openclaw agent --message "Hello!"

# Check status
openclaw status
```

## Full Guide

See [GUIDE.md](GUIDE.md) for detailed setup instructions, manual steps for Discord/Telegram/Convex, troubleshooting, and common commands.

## License

MIT
