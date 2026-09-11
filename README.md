## zshrc

```
brew install zsh
chsh -s /bin/zsh
ln -s "`pwd`"/.zshrc ~/.zshrc
source .zshrc
```

## emacs

```
brew install cask
ln -s "`pwd`"/.emacs.d/ ~/.emacs.d
cd .emacs.d
cask install
```


## tmux

```
brew install tmux
brew install reattach-to-user-namespace
ln -s "`pwd`"/.tmux.conf ~/.tmux.conf
cd
mkdir .tmux
cd .tmux
git clone git@github.com:erikw/tmux-powerline.git
```

### Powerline Setting(tmux & emacs)

```
brew install fontforge
brew tap sanemat/font
brew install ricty --with-powerline
cp -f /usr/local/opt/ricty/share/fonts/Ricty*.ttf ~/Library/Fonts/
fc-cache -vf
```

#### `iTerm` -> `Preferences`

![](https://gyazo.com/c2ed34eda3d12e4b5a1ea93b0b471955.png)

## Ghostty

```
brew install --cask ghostty
mkdir -p ~/.config/ghostty
ln -s "`pwd`"/.config/ghostty/config ~/.config/ghostty/config
```

macOS では `~/Library/Application Support/com.mitchellh.ghostty/config` も読み込まれる(こちらが優先)。
自動生成されたテンプレートが残っている場合は二重に読まれるので削除しておく。

```
rm -f ~/Library/Application\ Support/com.mitchellh.ghostty/config
```

## Codex

```
npm i -g @openai/codex   # or volta install @openai/codex
mkdir -p ~/.codex/rules
cp .codex/config.toml ~/.codex/config.toml
ln -s "`pwd`"/.codex/rules/default.rules ~/.codex/rules/default.rules
```

- `config.toml` は Codex 自身が端末固有の状態(projects の trust_level, plugin marketplace のパスなど)を書き戻すため、リンクではなくコピーしてベースにする
- `~/.codex/auth.json` は認証情報なので管理対象外(`codex login` で生成)
- herdr 連携用の `hooks.json` / `herdr-agent-state.sh` は下記 `herdr integration install codex` で生成される

## herdr

```
brew install herdr   # https://herdr.dev
mkdir -p ~/.config/herdr
ln -s "`pwd`"/.config/herdr/config.toml ~/.config/herdr/config.toml
herdr integration install claude
herdr integration install codex
```

- 設定変更後は `prefix+shift+r` でライブリロード(`herdr server reload-config` でも可)
- zsh 補完: `herdr completion zsh`
