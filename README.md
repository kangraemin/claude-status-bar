# claude-status-bar

[한국어](README.ko.md)

A real-time status line for Claude Code — see what matters at a glance.

![claude-status-bar screenshot](assets/screenshot.png)

Context usage, cost, model, git branch, version — all in two lines, always visible.

## Quick Start

One command:

```bash
curl -fsSL https://raw.githubusercontent.com/kangraemin/claude-status-bar/main/install.sh | bash
```

Restart Claude Code. That's it.

## What You Get

| Info | Example |
|------|---------|
| Current directory | `📁 my-project` |
| Git branch | `🌿 main` |
| Model | `🧠 Opus 4.6 (1M context)` |
| Claude Code version | `📦 v2.1.92` |
| Context usage | `🧊 Context: 6% [=---------]` |
| Session cost | `💰 $0.69 ($0.46/h)` |

The context bar fills up as you use more — so you know when to `/compact` or start fresh.

## Update

```bash
curl -fsSL https://raw.githubusercontent.com/kangraemin/claude-status-bar/main/install.sh | bash
```

Same command as install. It overwrites the old script and keeps your other settings intact.

## Uninstall

```bash
curl -fsSL https://raw.githubusercontent.com/kangraemin/claude-status-bar/main/uninstall.sh | bash
```

Removes the script and the `statusLine` entry from `settings.json`. Nothing else is touched.

## How It Works

The installer does two things:

1. Copies `statusline.sh` to `~/.claude/statusline.sh`
2. Adds this to your `~/.claude/settings.json`:

```json
{
  "statusLine": {
    "type": "command",
    "command": "~/.claude/statusline.sh"
  }
}
```

Claude Code pipes session data (model, cost, context window, etc.) as JSON to stdin. The script parses it with `jq` (preferred) or `python3` (fallback) and prints two lines.

## Requirements

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) CLI
- `jq` or `python3`

## License

MIT
