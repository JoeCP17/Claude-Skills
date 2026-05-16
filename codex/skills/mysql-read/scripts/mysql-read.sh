#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF' >&2
Usage:
  mysql-read.sh --target local|dev --database <db> --sql "<query>" [options]

Options:
  --target <local|dev>
  --database <name>
  --sql <query>
  --container <docker-container>
  --profile <aws-profile>
  --region <aws-region>
  --host <mysql-host>
  --port <mysql-port>
  --secret-arn <aws-secret-arn>

Env overrides:
  MYSQL_READ_LOCAL_CONTAINER
  MYSQL_READ_LOCAL_USER
  MYSQL_READ_LOCAL_PASSWORD
  MYSQL_READ_DEV_PROFILE
  MYSQL_READ_DEV_REGION
  MYSQL_READ_DEV_HOST
  MYSQL_READ_DEV_PORT
  MYSQL_READ_DEV_SECRET_ARN
EOF
  exit 1
}

require_command() {
  local cmd=$1
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "Error: required command not found: $cmd" >&2
    exit 1
  fi
}

trim() {
  local value=$1
  value="${value#"${value%%[![:space:]]*}"}"
  value="${value%"${value##*[![:space:]]}"}"
  printf '%s' "$value"
}

validate_read_only_sql() {
  local sql trimmed lower
  sql=$1
  trimmed=$(trim "$sql")
  lower=$(printf '%s' "$trimmed" | tr '[:upper:]' '[:lower:]')

  if [[ ! "$lower" =~ ^(select|show|describe|desc|explain|with[[:space:]]) ]]; then
    echo "Error: only read-only queries are allowed" >&2
    exit 1
  fi

  if printf '%s' "$lower" | grep -Eq '(^|[^a-z])(insert|update|delete|replace|alter|drop|truncate|create|rename|grant|revoke|call|do|load[[:space:]]+data|lock|unlock|set[[:space:]]+global|set[[:space:]]+session)([^a-z]|$)'; then
    echo "Error: mutating SQL keyword detected" >&2
    exit 1
  fi
}

find_local_container() {
  local explicit=${MYSQL_READ_LOCAL_CONTAINER:-}
  if [[ -n "$explicit" ]]; then
    printf '%s' "$explicit"
    return 0
  fi

  local detected
  detected=$(docker ps --format '{{.Names}}' | grep 'mysql' | grep 'thomas' | head -n 1 || true)
  if [[ -n "$detected" ]]; then
    printf '%s' "$detected"
    return 0
  fi

  echo "Error: could not find a running Thomas MySQL Docker container" >&2
  exit 1
}

json_field() {
  local json=$1
  local field=$2
  python3 - "$json" "$field" <<'PY'
import json
import sys

payload = json.loads(sys.argv[1])
field = sys.argv[2]
value = payload.get(field, "")
if value is None:
    value = ""
print(value)
PY
}

target=""
database=""
sql=""
container=""
profile="${MYSQL_READ_DEV_PROFILE:-default}"
region="${MYSQL_READ_DEV_REGION:-ap-northeast-2}"
host="${MYSQL_READ_DEV_HOST:-}"
port="${MYSQL_READ_DEV_PORT:-3306}"
secret_arn="${MYSQL_READ_DEV_SECRET_ARN:-}"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --target)
      target=${2:-}
      shift 2
      ;;
    --database)
      database=${2:-}
      shift 2
      ;;
    --sql)
      sql=${2:-}
      shift 2
      ;;
    --container)
      container=${2:-}
      shift 2
      ;;
    --profile)
      profile=${2:-}
      shift 2
      ;;
    --region)
      region=${2:-}
      shift 2
      ;;
    --host)
      host=${2:-}
      shift 2
      ;;
    --port)
      port=${2:-}
      shift 2
      ;;
    --secret-arn)
      secret_arn=${2:-}
      shift 2
      ;;
    *)
      usage
      ;;
  esac
done

if [[ -z "$target" || -z "$database" || -z "$sql" ]]; then
  usage
fi

validate_read_only_sql "$sql"
require_command docker

case "$target" in
  local)
    container=${container:-$(find_local_container)}
    local_user="${MYSQL_READ_LOCAL_USER:-user}"
    local_password="${MYSQL_READ_LOCAL_PASSWORD:-pass}"
    docker exec -e MYSQL_PWD="$local_password" "$container" \
      mysql -u"$local_user" -D "$database" -N -e "$sql"
    ;;
  dev)
    require_command aws
    if [[ -z "$host" || -z "$secret_arn" ]]; then
      echo "Error: MYSQL_READ_DEV_HOST and MYSQL_READ_DEV_SECRET_ARN are required for --target dev" >&2
      exit 1
    fi
    container=${container:-$(find_local_container)}
    secret_json=$(AWS_PROFILE="$profile" AWS_REGION="$region" aws secretsmanager get-secret-value \
      --secret-id "$secret_arn" \
      --query SecretString \
      --output text)
    dev_user=$(json_field "$secret_json" username)
    dev_password=$(json_field "$secret_json" password)
    docker exec -e MYSQL_PWD="$dev_password" "$container" \
      mysql -h "$host" -P "$port" -u"$dev_user" -D "$database" -N -e "$sql"
    ;;
  *)
    echo "Error: unsupported target: $target" >&2
    exit 1
    ;;
esac
