#!/usr/bin/env bash
#
# Shared helper: schedule a background `hedwig-cg-auto update` when the
# current repo already has a central hedwig-cg database.
#
# Safe to call from post-merge / post-checkout / post-rewrite hooks.
# Exits immediately if:
#   - not a git repo
#   - hedwig-cg-auto not on PATH
#   - no existing DB for this repo (avoid force-building on every random repo)
#   - $HEDWIG_CG_DISABLE_HOOK=1 (escape hatch)

[ "${HEDWIG_CG_DISABLE_HOOK:-0}" = "1" ] && exit 0

command -v hedwig-cg-auto >/dev/null 2>&1 || exit 0

repo_root=$(git rev-parse --show-toplevel 2>/dev/null) || exit 0
repo_name=$(basename "$repo_root")
db_root="${HEDWIG_CG_DB_ROOT:-$HOME/.hedwig-cg/dbs}"
db_path="$db_root/$repo_name/knowledge.db"

[ -f "$db_path" ] || exit 0

# Fire-and-forget incremental update. nohup + disown decouples from the
# parent git process so `git pull` returns immediately.
log_dir="$HOME/.hedwig-cg/logs"
mkdir -p "$log_dir"
log_file="$log_dir/$repo_name.log"

(
    cd "$repo_root" || exit 0
    {
        printf '\n=== %s hedwig-cg-auto update ===\n' "$(date '+%Y-%m-%d %H:%M:%S')"
        hedwig-cg-auto update
    } >>"$log_file" 2>&1
) </dev/null >/dev/null 2>&1 &

disown 2>/dev/null || true
exit 0
