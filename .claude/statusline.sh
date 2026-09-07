#!/bin/bash
# Claude Code statusline (usage-bar style)
# 1行目: dir/worktree・branch・model・PR
# 2行目: context bar・rate limits(5h/7d)・cost・duration

input=$(cat)

MODEL=$(echo "$input" | jq -r '.model.display_name')
DIR=$(echo "$input" | jq -r '.workspace.current_dir')
DIR_NAME=$(basename "$DIR")

# worktree名があれば優先してディレクトリ表記に使う（cmuxのpane識別用）
WT_NAME=$(echo "$input" | jq -r '.worktree.name // empty')
[ -n "$WT_NAME" ] && DIR_NAME="$WT_NAME"

# git branch + dirty flag
BRANCH=""
if git -C "$DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  B=$(git -C "$DIR" branch --show-current 2>/dev/null)
  DIRTY=""
  [ -n "$(git -C "$DIR" status --porcelain 2>/dev/null)" ] && DIRTY="*"
  [ -n "$B" ] && BRANCH=" (${B}${DIRTY})"
fi

# PR番号（あれば）
PR=$(echo "$input" | jq -r '.pr.number // empty')
PR_DISPLAY=""
[ -n "$PR" ] && PR_DISPLAY=" | PR #${PR}"

# --- 1行目 ---
echo "${DIR_NAME}${BRANCH} | ${MODEL}${PR_DISPLAY}"

# --- 2行目 ---
# context bar
PCT=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)
FILLED=$((PCT / 10))
EMPTY=$((10 - FILLED))
BAR=""
[ "$FILLED" -gt 0 ] && printf -v FILL "%${FILLED}s" && BAR="${FILL// /▓}"
[ "$EMPTY" -gt 0 ] && printf -v PAD "%${EMPTY}s" && BAR="${BAR}${PAD// /░}"

# rate limits (Pro/Maxサブスクの場合のみ値が入る)
FIVE_H=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
FIVE_H_RESET=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
WEEK=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
WEEK_RESET=$(echo "$input" | jq -r '.rate_limits.seven_day.resets_at // empty')

fmt_reset() {
  local ts="$1"
  [ -z "$ts" ] && return
  local now=$(date +%s)
  local diff=$((ts - now))
  [ "$diff" -lt 0 ] && diff=0
  local h=$((diff / 3600))
  local m=$(((diff % 3600) / 60))
  if [ "$h" -gt 0 ]; then echo "${h}h${m}m"; else echo "${m}m"; fi
}

RATE_DISPLAY=""
if [ -n "$FIVE_H" ]; then
  RATE_DISPLAY="${RATE_DISPLAY} | 5h $(printf '%.0f' "$FIVE_H")% (rst $(fmt_reset "$FIVE_H_RESET"))"
fi
if [ -n "$WEEK" ]; then
  RATE_DISPLAY="${RATE_DISPLAY} | 7d $(printf '%.0f' "$WEEK")% (rst $(fmt_reset "$WEEK_RESET"))"
fi

# cost & duration
COST=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')
COST_FMT=$(printf '$%.2f' "$COST")
DUR_MS=$(echo "$input" | jq -r '.cost.total_duration_ms // 0')
DUR_SEC=$((DUR_MS / 1000))
DUR_MIN=$((DUR_SEC / 60))
DUR_S=$((DUR_SEC % 60))

echo "ctx ${BAR} ${PCT}%${RATE_DISPLAY} | ${COST_FMT} | ${DUR_MIN}m${DUR_S}s"
