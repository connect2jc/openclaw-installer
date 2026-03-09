# OpenCLAW Installation Guide

## Quick Install

```bash
bash install.sh
```

The installer is fully interactive — it asks what you need and sets up only those modules.

## Modules

| Module | What it does | Requires |
|--------|-------------|----------|
| **Core** | CLI + config + directory structure | Anthropic API key |
| **Memory** | PARA knowledge system, tacit knowledge, daily logs | Core |
| **Agents** | Specialized agent workspaces (sales, marketing, research, etc.) | Core |
| **Discord** | Discord bot for agent communication | Discord bot token |
| **Telegram** | Telegram bot for agent communication | Telegram bot token |
| **Dashboard** | Real-time Mission Control (Next.js + Convex) | Convex account |
| **Cron Jobs** | Automated scheduling (standup, consolidation) | Core |
| **Skills** | Custom skill packages (browser, git, social, SEO) | Core |
| **Scripts** | Automation shell scripts (heartbeat, sync, hygiene) | Core |

## Prerequisites

- **Node.js 18+** — `brew install node` or https://nodejs.org
- **npm** — comes with Node.js
- **git** — `brew install git`
- **GitHub CLI** (optional) — `brew install gh`

## API Keys You May Need

| Key | Required For | Get It At |
|-----|-------------|-----------|
| Anthropic API | Core (required) | https://console.anthropic.com |
| OpenAI API | Fallback model | https://platform.openai.com |
| Brave Search API | Web search tool | https://brave.com/search/api |
| Discord Bot Token | Discord module | https://discord.com/developers |
| Telegram Bot Token | Telegram module | Message @BotFather on Telegram |
| Convex Deploy Key | Dashboard module | https://convex.dev |
| Twitter API keys (5) | Twitter skills/agents | https://developer.twitter.com |

## Manual Setup Steps

### Discord Bot
1. Go to https://discord.com/developers/applications
2. Create New Application → name it
3. Bot tab → Reset Token → copy it
4. Enable **Message Content Intent** and **Server Members Intent**
5. OAuth2 → URL Generator → Scopes: `bot` → Permissions: Send Messages, Read History, Embed Links
6. Open the generated URL to invite the bot
7. Add token to `.env` as `DISCORD_BOT_TOKEN`

### Telegram Bot
1. Open Telegram, message @BotFather
2. Send `/newbot`, follow prompts
3. Copy the token → add to `.env` as `TELEGRAM_BOT_TOKEN`
4. Start a conversation with your bot — OpenCLAW auto-pairs on first message

### Convex Dashboard
1. Sign up at https://convex.dev
2. Create a new project
3. Run `cd ~/.openclaw/mission-control && npx convex dev`
4. Add `CONVEX_URL` and `CONVEX_DEPLOY_KEY` to `.env`
5. Deploy: `npx convex deploy`
6. For Vercel: `vercel --prod`

## Directory Structure After Install

```
~/.openclaw/
├── openclaw.json           # Main configuration
├── .env                    # API keys (chmod 600)
├── exec-approvals.json     # Command security rules
├── workspace/              # Primary workspace
│   ├── SOUL.md            # Agent identity
│   ├── USER.md            # Your profile
│   ├── MEMORY.md          # Long-term memory
│   └── memory/            # Memory system
│       ├── daily/         # Daily logs (YYYY-MM-DD.md)
│       ├── knowledge/     # PARA structure
│       │   ├── projects/
│       │   ├── areas/
│       │   ├── resources/
│       │   └── archive/
│       └── tacit/         # Behavioral knowledge
│           ├── PREFERENCES.md
│           ├── LESSONS.md
│           └── SECURITY-RULES.md
├── workspace-{agent}/      # Agent workspaces (if multi-agent)
├── scripts/               # Automation scripts
├── cron/                  # Scheduled jobs
│   ├── jobs.json
│   └── runs/
├── credentials/           # Stored credentials
├── logs/                  # System logs
├── mission-control/       # Dashboard (if installed)
└── GUIDE.md              # This file
```

## Common Commands

```bash
# Start the gateway
openclaw gateway start

# Chat with your agent
openclaw agent --message "Hello!"

# Check system status
openclaw status

# Send message via Discord
openclaw message send --channel discord --target <channel_id> --message "text"

# Run a script
bash ~/.openclaw/scripts/agent-heartbeat.sh main

# Memory operations
openclaw memory search "topic"
openclaw memory index --force
```

## Troubleshooting

| Problem | Solution |
|---------|----------|
| `openclaw: command not found` | Run `npm install -g openclaw` |
| Gateway won't start | Check if port 39271 is in use: `lsof -i :39271` |
| Agent not responding | Check `.env` has valid ANTHROPIC_API_KEY |
| Discord bot offline | Verify DISCORD_BOT_TOKEN and bot intents are enabled |
| Convex errors | Run `npx convex dev` to check connection |

## Uninstall

```bash
# Remove OpenCLAW completely
npm uninstall -g openclaw
rm -rf ~/.openclaw

# Or just reset config (keeps data)
rm ~/.openclaw/openclaw.json
rm ~/.openclaw/.env
```
