<div align="center">

# claude-status-bar

**Claude Code 실시간 status line.**

[![License](https://img.shields.io/github/license/kangraemin/claude-status-bar?style=for-the-badge)](https://github.com/kangraemin/claude-status-bar/blob/main/LICENSE)
[![Stars](https://img.shields.io/github/stars/kangraemin/claude-status-bar?style=for-the-badge)](https://github.com/kangraemin/claude-status-bar/stargazers)

[시작하기](#설치) · [English](README.md) · [Issues](https://github.com/kangraemin/claude-status-bar/issues)

</div>

---

디렉토리, git 브랜치, 모델, 컨텍스트 사용량, 비용, rate limit — 항상 하단에 표시.

![claude-status-bar 스크린샷](assets/screenshot.png)

## 설치

```bash
curl -fsSL https://raw.githubusercontent.com/kangraemin/claude-status-bar/main/install.sh | bash
```

Claude Code 재시작하면 적용됩니다.

## 표시 항목

| 줄 | 정보 | 예시 |
|----|------|------|
| 1 | 디렉토리, 브랜치, 모델 | `📁 my-project 🌿 main 🧠 Opus` |
| 2 | 컨텍스트 사용량 + 세션 비용 | `🧊 10% [=---------] 💰 $15.09 ($1.26/h)` |
| 3 | Rate limit 사용량 (5h / 7d) | `⏳ 5h: 21% [==--------] 7d: 44% [====------]` |

- 컨텍스트를 쓸수록 바가 채워집니다. `/compact` 타이밍을 잡기 좋습니다.
- Rate limit은 **사용량** 기준이며, 내장 `/status` 표시와 동일합니다. Pro/Max 구독자만 표시됩니다.

## 업데이트

```bash
curl -fsSL https://raw.githubusercontent.com/kangraemin/claude-status-bar/main/install.sh | bash
```

설치와 같은 명령어입니다. 기존 스크립트만 덮어쓰고, 다른 설정은 건드리지 않습니다.

## 제거

```bash
curl -fsSL https://raw.githubusercontent.com/kangraemin/claude-status-bar/main/uninstall.sh | bash
```

## 동작 방식

설치 스크립트가 하는 일은 두 가지:

1. `statusline.sh` → `~/.claude/statusline.sh` 복사
2. `~/.claude/settings.json`에 `statusLine` 설정 추가

```json
{
  "statusLine": {
    "type": "command",
    "command": "~/.claude/statusline.sh"
  }
}
```

Claude Code가 세션 데이터를 JSON으로 stdin에 넘기면, 스크립트가 `jq` (우선) 또는 `python3` (폴백)으로 파싱해서 세 줄을 출력합니다.

## 요구사항

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) CLI
- `jq` 또는 `python3`

## 라이선스

MIT
