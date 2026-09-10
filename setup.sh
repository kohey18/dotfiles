#!/usr/bin/env bash
# dotfiles 一発セットアップ
#   ./setup.sh            : Homebrew パッケージのインストール + シンボリックリンク作成
#   SKIP_BREW=1 ./setup.sh: シンボリックリンク作成のみ
# 何度実行しても同じ結果になる（既存ファイルは *.bak に退避）
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOME_DIR="${HOME}"

log() { printf '\033[1;32m==>\033[0m %s\n' "$*"; }

# ---- Homebrew --------------------------------------------------------------
if [ "${SKIP_BREW:-0}" != "1" ]; then
  if ! command -v brew >/dev/null 2>&1; then
    log "Installing Homebrew"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
  log "brew bundle (Brewfile)"
  brew bundle --file="${DOTFILES}/Brewfile"
fi

# ---- symlinks --------------------------------------------------------------
# link <repo-relative-path> <target-absolute-path>
link() {
  local src="${DOTFILES}/$1" dst="$2"
  mkdir -p "$(dirname "${dst}")"
  if [ -L "${dst}" ] && [ "$(readlink "${dst}")" = "${src}" ]; then
    log "ok      ${dst}"
    return
  fi
  if [ -e "${dst}" ] || [ -L "${dst}" ]; then
    log "backup  ${dst} -> ${dst}.bak"
    rm -rf "${dst}.bak"
    mv "${dst}" "${dst}.bak"
  fi
  ln -s "${src}" "${dst}"
  log "link    ${dst} -> ${src}"
}

link .zshrc                     "${HOME_DIR}/.zshrc"
link .tmux.conf                 "${HOME_DIR}/.tmux.conf"
link .emacs.d                   "${HOME_DIR}/.emacs.d"
link .config/herdr/config.toml  "${HOME_DIR}/.config/herdr/config.toml"
link .config/ghostty/config     "${HOME_DIR}/.config/ghostty/config"
link .claude/settings.json      "${HOME_DIR}/.claude/settings.json"
link .claude/statusline.sh      "${HOME_DIR}/.claude/statusline.sh"

# ---- tmux-powerline --------------------------------------------------------
if [ ! -d "${HOME_DIR}/.tmux/tmux-powerline" ]; then
  log "Cloning tmux-powerline"
  git clone --depth 1 https://github.com/erikw/tmux-powerline.git "${HOME_DIR}/.tmux/tmux-powerline"
else
  log "ok      ${HOME_DIR}/.tmux/tmux-powerline"
fi

# ---- emacs packages --------------------------------------------------------
if command -v cask >/dev/null 2>&1; then
  log "cask install (emacs packages)"
  (cd "${DOTFILES}/.emacs.d" && cask install)
fi

# ---- reload running tools --------------------------------------------------
if command -v herdr >/dev/null 2>&1 && herdr status server >/dev/null 2>&1; then
  log "herdr server reload-config"
  herdr server reload-config >/dev/null || true
fi

log "done. login shell を zsh にするには: chsh -s \"\$(command -v zsh)\""
