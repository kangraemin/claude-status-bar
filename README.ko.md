# claude-status-bar

Claude Code 하단에 실시간 상태 정보를 표시하는 status line.

![claude-status-bar 스크린샷](assets/screenshot.png)

컨텍스트 사용량, 비용, 모델, git 브랜치, 버전 — 두 줄로, 항상 눈에 보이게.

## 설치

한 줄이면 끝:

```bash
curl -fsSL https://raw.githubusercontent.com/kangraemin/claude-status-bar/main/install.sh | bash
```

Claude Code 재시작하면 적용됩니다.

## 표시 항목

| 정보 | 예시 |
|------|------|
| 현재 디렉토리 | `📁 my-project` |
| Git 브랜치 | `🌿 main` |
| 모델 | `🧠 Opus 4.6 (1M context)` |
| Claude Code 버전 | `📦 v2.1.92` |
| 컨텍스트 사용량 | `🧊 Context: 6% [=---------]` |
| 세션 비용 | `💰 $0.69 ($0.46/h)` |

컨텍스트를 쓸수록 바가 채워집니다. `/compact` 타이밍을 잡기 좋습니다.

## 업데이트

```bash
curl -fsSL https://raw.githubusercontent.com/kangraemin/claude-status-bar/main/install.sh | bash
```

설치와 같은 명령어입니다. 기존 스크립트를 덮어쓰고, 다른 설정은 건드리지 않습니다.

## 제거

```bash
curl -fsSL https://raw.githubusercontent.com/kangraemin/claude-status-bar/main/uninstall.sh | bash
```

스크립트와 `settings.json`의 `statusLine` 항목만 제거합니다.

## 동작 방식

설치 스크립트가 하는 일은 두 가지:

1. `statusline.sh`를 `~/.claude/statusline.sh`에 복사
2. `~/.claude/settings.json`에 아래 설정 추가:

```json
{
  "statusLine": {
    "type": "command",
    "command": "~/.claude/statusline.sh"
  }
}
```

Claude Code가 세션 데이터(모델, 비용, 컨텍스트 등)를 JSON으로 stdin에 넘기면, 스크립트가 `jq` (우선) 또는 `python3` (폴백)으로 파싱해서 두 줄을 출력합니다.

## 요구사항

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) CLI
- `jq` 또는 `python3`

## 라이선스

MIT
