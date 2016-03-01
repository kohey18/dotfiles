## zshrc

```
chsh -s /bin/zsh
ln -s dotfiles/.zshrc .zshrc
source .zshrc
```

## emacs

```
ln -s dotfiles/.emacs.d/ ~/.emacs.d
cd .emacs.d
cask install
```


## tmux

```
brew install reattach-to-user-namespace
ln -s dotfiles/.tmux.conf ~/.tmux.conf
mkdir .tmux
cd .tmux
git clone git@github.com:erikw/tmux-powerline.git
```

### Powerline Setting(tmux & emacs)

```
brew install fontforge
brew reinstall --powerline --vim-powerline ricty
cp -f /usr/local/Cellar/ricty/3.2.4/share/fonts/Ricty*.ttf ~/Library/Fonts
```
`iTerm` -> `Preferences`

![](https://gyazo.com/c2ed34eda3d12e4b5a1ea93b0b471955.png)