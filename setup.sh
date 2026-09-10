#!/usr/bin/env bash
# dotfiles 一発セットアップ
#   ./setup.sh              : Homebrew パッケージ + シンボリックリンク + 自作アプリのビルド
#   SKIP_BREW=1 ./setup.sh  : Homebrew の手順を飛ばす
#   SKIP_APPS=1 ./setup.sh  : kanatan / editan のビルドを飛ばす
#   REBUILD_APPS=1 ./setup.sh : /Applications にあっても kanatan / editan を再ビルド
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

# Apple Silicon では /opt/homebrew/bin が PATH に無いので ~/.zprofile で通す
BREW_BIN="$(command -v brew || echo /opt/homebrew/bin/brew)"
SHELLENV_LINE="eval \"\$(${BREW_BIN} shellenv)\""
if ! grep -qsF "${SHELLENV_LINE}" "${HOME_DIR}/.zprofile"; then
  log "append  brew shellenv -> ${HOME_DIR}/.zprofile"
  printf '%s\n' "${SHELLENV_LINE}" >> "${HOME_DIR}/.zprofile"
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

# ---- herdr integrations (Claude Code / Codex の状態をサイドバーに出す) --------
if command -v herdr >/dev/null 2>&1; then
  for agent in claude codex; do
    if command -v "${agent}" >/dev/null 2>&1; then
      log "herdr integration install ${agent}"
      herdr integration install "${agent}" >/dev/null || true
    fi
  done
  # settings.json の herdr hook は絶対パスで書かれるため、別ユーザー名のマシンでは
  # 古い /Users/<name>/ 向けエントリが残る。実在しないパスのものを取り除く。
  SETTINGS="${HOME_DIR}/.claude/settings.json"
  if command -v jq >/dev/null 2>&1 && [ -f "${SETTINGS}" ]; then
    tmp="$(mktemp)"
    jq --arg home "${HOME_DIR}" '
      if .hooks.SessionStart then
        .hooks.SessionStart |= map(select(
          (.hooks[0].command | test("herdr-agent-state") | not)
          or (.hooks[0].command | contains($home + "/"))
        ))
      else . end' "${SETTINGS}" > "${tmp}"
    if ! cmp -s "${tmp}" "${SETTINGS}"; then
      log "prune   stale herdr hook entries in ${SETTINGS}"
      cat "${tmp}" > "${SETTINGS}"
    fi
    rm -f "${tmp}"
  fi
  if herdr status server >/dev/null 2>&1; then
    log "herdr server reload-config"
    herdr server reload-config >/dev/null || true
  fi
fi

# ---- 自作 macOS アプリ (kanatan / editan) をソースからビルドしてインストール ----
# install_app <github repo> <install script (repo 相対)> <App 名>
# clone 先は dotfiles と同じ親ディレクトリ (例: ~/Documents/dev/kohey18/kanatan)
install_app() {
  local repo="$1" script="$2" app="$3"
  local dir="$(dirname "${DOTFILES}")/${repo##*/}"
  if [ -d "/Applications/${app}.app" ] && [ "${REBUILD_APPS:-0}" != "1" ]; then
    log "ok      /Applications/${app}.app (REBUILD_APPS=1 で再ビルド)"
    return
  fi
  if [ ! -d "${dir}" ]; then
    log "Cloning ${repo}"
    git clone "https://github.com/${repo}.git" "${dir}"
  else
    (cd "${dir}" && git pull --ff-only) || true
  fi
  log "Building ${app} (${dir}/${script})"
  if ! (cd "${dir}" && "./${script}"); then
    log "FAILED  ${app}: ビルドに失敗しました。Kanatan は Apple Development 署名を使うので Xcode に Apple ID を登録してから REBUILD_APPS=1 で再実行してください"
    FAILED_APPS="${FAILED_APPS:-} ${app}"
  fi
}

if [ "${SKIP_APPS:-0}" != "1" ]; then
  if xcodebuild -version >/dev/null 2>&1 && command -v xcodegen >/dev/null 2>&1; then
    install_app kohey18/kanatan scripts/install.sh Kanatan
    install_app kohey18/editan  Scripts/install.sh Editan
  else
    log "skip    kanatan / editan: Xcode (App Store) と xcodegen が必要です。導入後に再実行してください"
  fi
fi

if [ -n "${FAILED_APPS:-}" ]; then
  log "done (ビルド失敗:${FAILED_APPS}). login shell を zsh にするには: chsh -s \"\$(command -v zsh)\""
  exit 1
fi
log "done. login shell を zsh にするには: chsh -s \"\$(command -v zsh)\""
