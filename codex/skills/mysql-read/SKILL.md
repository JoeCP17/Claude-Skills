---
name: mysql-read
description: Run read-only MySQL queries against the Thomas local Docker MySQL or the dev Aurora hmmall/thomas databases. Use when the user wants quick schema inspection, SQL lookups, NATION/STATE mapping checks, or direct read-only validation without relying on MCP.
---

# MySQL Read

Use the bundled shell script for read-only MySQL access.

Default targets:
- `local`: Docker MySQL started by the Thomas repo (`compose.yml`)
- `dev`: Aurora read endpoint using AWS CLI + Secrets Manager

## Workflow

1. Decide the target:
   - Use `local` for Docker data seeded by the repo.
   - Use `dev` for shared Aurora data after `aws sso login`.
2. Keep queries read-only.
3. Run the script instead of hand-assembling credentials inline.
4. Summarize the result briefly and include the important rows or counts in the reply.

## Commands

```bash
~/.codex/skills/mysql-read/scripts/mysql-read.sh --target local --database hmmall --sql "SELECT 1"
```

```bash
~/.codex/skills/mysql-read/scripts/mysql-read.sh --target dev --database hmmall --sql "SELECT NATION_NO, COUNTRY_ID, DEF_NATION_NM FROM NATION WHERE COUNTRY_ID IN ('US','CA')"
```

## Behavior

- Only `SELECT`, `SHOW`, `DESCRIBE`, `DESC`, `EXPLAIN`, and `WITH ... SELECT` queries are allowed.
- `local` uses a running Docker MySQL container and defaults to:
  - container auto-detected from `docker ps`
  - user `user`
  - password `pass`
- `dev` defaults to:
  - AWS profile `default`
  - region `ap-northeast-2`
  - host from `MYSQL_READ_DEV_HOST`
  - secret ARN from `MYSQL_READ_DEV_SECRET_ARN`
- Override defaults with flags or env vars when needed.

## Common Cases

- Find a nation number:
  - `--sql "SELECT NATION_NO, COUNTRY_ID, DEF_NATION_NM FROM NATION WHERE COUNTRY_ID = 'US'"`
- Check state code mapping:
  - `--sql "SELECT NATION_NO, STATE_NM, STATE_CD FROM STATE WHERE STATE_NM = 'New York'"`
- Inspect schema:
  - `--sql "SHOW COLUMNS FROM STATE"`

## Prerequisites

- `docker`
- `aws`

If `local` is used, the Thomas MySQL container must be running.
If `dev` is used, run `aws sso login` first and set `MYSQL_READ_DEV_HOST` plus `MYSQL_READ_DEV_SECRET_ARN`.
