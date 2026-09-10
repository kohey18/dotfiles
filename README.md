# dotfiles

macOS 用の設定ファイル一式。新しいマシンでは以下だけで全部セットアップできる。

```
git clone git@github.com:kohey18/dotfiles.git ~/Documents/dev/kohey18/dotfiles
cd ~/Documents/dev/kohey18/dotfiles
./setup.sh
chsh -s "$(command -v zsh)"
```

`setup.sh` は何度実行しても安全（既存ファイルは `*.bak` に退避してからリンクを張る）。
パッケージのインストールを飛ばしてリンクだけ張り直したい場合は `SKIP_BREW=1 ./setup.sh`。

## setup.sh がやること

1. Homebrew が無ければインストール
2. `brew bundle` で [Brewfile](Brewfile) のパッケージを一括インストール
   - zsh / tmux / reattach-to-user-namespace / jq / asdf / emacs / cask / herdr / git
   - `ghostty`（ターミナル）
   - `font-udev-gothic-nf`（ghostty / tmux / emacs で使う Nerd Font）
3. 以下のシンボリックリンクを作成

   | リポジトリ | リンク先 |
   |---|---|
   | `.zshrc` | `~/.zshrc` |
   | `.tmux.conf` | `~/.tmux.conf` |
   | `.emacs.d/` | `~/.emacs.d` |
   | `.config/herdr/config.toml` | `~/.config/herdr/config.toml` |
   | `.config/ghostty/config` | `~/.config/ghostty/config` |
   | `.claude/settings.json` | `~/.claude/settings.json` |
   | `.claude/statusline.sh` | `~/.claude/statusline.sh` |

4. `~/.tmux/tmux-powerline` を clone
5. `cask install` で emacs パッケージをインストール
6. herdr サーバーが起動していれば `herdr server reload-config`

## 各ツールのメモ

### tmux

プレフィックスはデフォルトの `Ctrl-b`。`prefix+v` で左右分割、`prefix+s` で上下分割（いずれもカレントディレクトリを引き継ぐ）。

### herdr

tmux と同じキーに合わせてある（`prefix+v` 左右分割 / `prefix+s` 上下分割）。
設定を変えたら `herdr server reload-config`。

### ghostty

フォントは `UDEV Gothic NF`（Brewfile の `font-udev-gothic-nf`）。設定変更は ghostty 上で `Cmd+Shift+,` で再読み込み。

### emacs

パッケージは `.emacs.d/Cask` で管理。追加したら `cd .emacs.d && cask install`。

### Claude Code

`.claude/settings.json` と `statusline.sh`（`jq` が必要）。
