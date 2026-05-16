# Codex MCP 서버 설정

`codex/config.toml`에 기본 MCP 서버 정의를 함께 보관한다. 실제 토큰, DB host, Secret ARN은 커밋하지 않고 환경변수로 주입한다.

## 환경변수

```bash
cp ~/LLM-Dot-files/codex/mcp/.env.example ~/LLM-Dot-files/codex/mcp/.env
```

`.env`에는 실제 값을 넣되 커밋하지 않는다.

## 복원 명령

`codex/config.toml`을 `~/.codex/config.toml`로 복원하면 대부분 별도 `codex mcp add` 없이 로드된다. 수동 등록이 필요할 때만 아래 명령을 사용한다.

```bash
# 인증 불필요 stdio 서버
codex mcp add jetbrains -- npx -y @jetbrains/mcp-proxy
codex mcp add mcp-installer -- npx @anaisbetts/mcp-installer
codex mcp add sequential-thinking -- npx -y @modelcontextprotocol/server-sequential-thinking
codex mcp add browsermcp -- npx @browsermcp/mcp@latest
codex mcp add playwright -- npx @playwright/mcp@latest
codex mcp add context7 --env DEFAULT_MINIMUM_TOKENS=6000 -- npx -y @upstash/context7-mcp

# 인증 필요 stdio 서버
codex mcp add github \
  --env GITHUB_PERSONAL_ACCESS_TOKEN=<your_token> \
  -- npx -y @modelcontextprotocol/server-github

codex mcp add notion \
  --env NOTION_TOKEN=<your_token> \
  -- npx -y @notionhq/notion-mcp-server

codex mcp add taskmaster-ai \
  --env AWS_REGION=us-east-1 \
  --env AWS_PROFILE=default \
  --env BEDROCK_ENABLED=true \
  --env BEDROCK_MODEL_ID=us.anthropic.claude-sonnet-4-20250514-v1:0 \
  -- npx -y --package=task-master-ai task-master-ai

codex mcp add mysql-mcp-server \
  --env AWS_PROFILE=default \
  --env AWS_REGION=ap-northeast-2 \
  --env FASTMCP_LOG_LEVEL=ERROR \
  -- uvx awslabs.mysql-mcp-server@latest \
    --hostname <db_endpoint> \
    --secret_arn <secret_arn> \
    --database <db_name> \
    --region ap-northeast-2 \
    --readonly True

# Streamable HTTP 서버
codex mcp add atlassian \
  --url https://mcp.atlassian.com/v1/mcp

codex mcp add datadog-mcp \
  --url https://mcp.datadoghq.com/api/unstable/mcp-server/mcp
```

## 주의

- Codex CLI `mcp add`는 stdio 서버와 streamable HTTP URL을 지원한다.
- Datadog HTTP 헤더는 `codex/config.toml`의 `[mcp_servers.datadog-mcp.http_headers]`에서 관리한다.
- MySQL MCP는 실제 endpoint와 Secret ARN을 `codex/mcp/.env.example` 변수로만 관리한다.
- `agent-workbench`의 `.mcp.json`에는 개발 DB endpoint와 Secret ARN이 들어 있었지만, 이 레포에는 placeholder만 반영했다.
