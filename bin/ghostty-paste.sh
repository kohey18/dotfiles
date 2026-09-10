#!/bin/sh
# Ghostty で cmd+v を押したときに Karabiner-Elements から呼ばれる。
#   クリップボードが画像  -> ctrl+v      (Claude Code / Codex が画像として読み込む)
#   それ以外(テキスト等) -> ctrl+cmd+v  (Ghostty 側で paste_from_clipboard に割り当て)
# key code 9 = "v"
if osascript -e 'clipboard info' 2>/dev/null | grep -qE '«class PNGf»|TIFF|JPEG|«class 8BPS»|GIFf'; then
  exec osascript -e 'tell application "System Events" to key code 9 using {control down}'
else
  exec osascript -e 'tell application "System Events" to key code 9 using {control down, command down}'
fi
