<div align="center">

# claude-status-bar

**Real-time status line for Claude Code.**

[![License](https://img.shields.io/github/license/kangraemin/claude-status-bar?style=for-the-badge)](https://github.com/kangraemin/claude-status-bar/blob/main/LICENSE)
[![Stars](https://img.shields.io/github/stars/kangraemin/claude-status-bar?style=for-the-badge)](https://github.com/kangraemin/claude-status-bar/stargazers)

[Getting Started](#install) · [한국어](README.ko.md) · [Issues](https://github.com/kangraemin/claude-status-bar/issues)

</div>

---

Directory, git branch, model, context usage, cost, and rate limits — always visible at the bottom.

![claude-status-bar screenshot](assets/screenshot.png)

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/kangraemin/claude-status-bar/main/install.sh | bash
```

Restart Claude Code. That's it.

## What You See

| Line | Info | Example |
|------|------|---------|
| 1 | Directory, branch, model | `📁 my-project 🌿 main 🧠 Opus` |
| 2 | Context usage + session cost | `🧊 10% [=---------] 💰 $15.09 ($1.26/h)` |
| 3 | Rate limit used (5h / 7d) | `⏳ 5h: 21% [==--------] 7d: 44% [====------]` |

- Context bar fills up as you use more — know when to `/compact` or start fresh.
- Rate limits show **used** quota, matching the built-in `/status` display. Appears only for Pro/Max subscribers.

## Update

```bash
curl -fsSL https://raw.githubusercontent.com/kangraemin/claude-status-bar/main/install.sh | bash
```

Same command. Overwrites the script, keeps your other settings.

## Uninstall

```bash
curl -fsSL https://raw.githubusercontent.com/kangraemin/claude-status-bar/main/uninstall.sh | bash
```

## How It Works

The installer does two things:

1. Copies `statusline.sh` → `~/.claude/statusline.sh`
2. Adds `statusLine` config to `~/.claude/settings.json`

```json
{
  "statusLine": {
    "type": "command",
    "command": "~/.claude/statusline.sh"
  }
}
```

Claude Code pipes session data as JSON to stdin. The script parses it with `jq` (preferred) or `python3` (fallback) and outputs three lines.

## Requirements

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) CLI
- `jq` or `python3`

## License

MIT
