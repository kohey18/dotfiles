# dotfiles

macOS 用の設定ファイル一式。新しいマシンでは以下だけで全部セットアップできる。

```
git clone git@github.com:kohey18/dotfiles.git ~/Documents/dev/kohey18/dotfiles
cd ~/Documents/dev/kohey18/dotfiles
./setup.sh
chsh -s "$(command -v zsh)"
```

`setup.sh` は何度実行しても安全（既存ファイルは `*.bak` に退避してからリンクを張る）。
オプション:

- `SKIP_BREW=1 ./setup.sh` … Homebrew のインストールと `brew bundle` だけを飛ばす（リンク・clone・ビルドは実行する）
- `SKIP_APPS=1 ./setup.sh` … kanatan / editan のビルドを飛ばす
- `REBUILD_APPS=1 ./setup.sh` … kanatan / editan を再ビルドして入れ直す

事前に必要なもの:

- Xcode（App Store から。kanatan / editan のビルドに使う）
- Kanatan は Apple Development 署名でビルドするので、Xcode の Settings → Accounts に Apple ID を登録しておく。未登録だと Kanatan だけ失敗し、他は続行する

## setup.sh がやること

1. Homebrew が無ければインストールし、`brew shellenv` を `~/.zprofile` に追記
2. `brew bundle` で [Brewfile](Brewfile) のパッケージを一括インストール
   - zsh / tmux / reattach-to-user-namespace / jq / asdf / emacs / cask / herdr / git / xcodegen
   - `.zshrc` が使う direnv / rbenv / pyenv / peco
   - `ghostty`（ターミナル）
   - `font-udev-gothic-nf`（ghostty / tmux / emacs で使う Nerd Font）
   - `claude-code`（Claude Code CLI）
   - `codex`（OpenAI Codex CLI）
   - GUI アプリ: Cursor / VS Code / TablePlus / Alfred / Postman / ChatGPT / Claude
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
6. `herdr integration install claude` / `codex` で herdr のエージェント連携を有効化し、サーバーが起動していれば `herdr server reload-config`
7. 自作 macOS アプリをソースからビルドして `/Applications` にインストール（dotfiles と同じ親ディレクトリに clone）
   - [kanatan](https://github.com/kohey18/kanatan) … 左⌘で英数 / 右⌘でかな
   - [editan](https://github.com/kohey18/editan) … ステージング用エディタ

初回ログイン後に手動でやること:

- `claude` と `codex` でログイン
- Kanatan を起動してアクセシビリティ権限を許可

## 各ツールのメモ

### tmux

プレフィックスはデフォルトの `Ctrl-b`。`prefix+v` で左右分割、`prefix+s` で上下分割（いずれもカレントディレクトリを引き継ぐ）。

### herdr

tmux と同じキーに合わせてある（`prefix+v` 左右分割 / `prefix+s` 上下分割）。`prefix+n` で新しい space（workspace）を作る。次のタブは `prefix+shift+n`。
設定を変えたら `herdr server reload-config`。

### ghostty

フォントは `UDEV Gothic NF`（Brewfile の `font-udev-gothic-nf`）。設定変更は ghostty 上で `Cmd+Shift+,` で再読み込み。

### emacs

パッケージは `.emacs.d/Cask` で管理。追加したら `cd .emacs.d && cask install`。

### Claude Code / Codex

`.claude/settings.json` と `statusline.sh`（`jq` が必要）。settings.json の `hooks` は herdr の連携用で、`herdr integration install claude` が管理する。
Codex の `~/.codex/config.toml` はプロジェクトの trust 設定などマシン固有の内容が多いので dotfiles では管理しない。
