#!/usr/bin/env bash
# PostToolUse hook: after Edit/Write on a chapter file listed in the paper's
# "Basic Information.md" chapters, ask the main session to run editing-assistant (checkpoint C).

input=$(cat)
path=$(printf '%s' "$input" | sed -n 's/.*"file_path"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -n 1)
[ -z "$path" ] && exit 0

# Normalize Windows separators (JSON-escaped or plain) to "/"
path=$(printf '%s' "$path" | tr '\\' '/' | sed -E 's#/{2,}#/#g')

case "$path" in
  */working-papers/_TEMPLATE/*) exit 0 ;;
  */working-papers/*/*) ;;
  *) exit 0 ;;
esac

rel=${path##*/working-papers/}
paper=${rel%%/*}
file=${rel#*/}

# Only top-level files of the paper folder
case "$file" in */*) exit 0 ;; esac

info="${path%/*}/Basic Information.md"
[ -f "$info" ] || exit 0
grep -qF "\`$file\`" "$info" || exit 0

msg="已修改章節檔 working-papers/$paper/$file。採用版本後請呼叫 editing-assistant（時間點 C），檢查留底、progress、查證結果表、書目與 todo。"
printf '{"hookSpecificOutput":{"hookEventName":"PostToolUse","additionalContext":"%s"}}\n' "$msg"
