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
brew install ricty --with-powerline
cp -f /usr/local/opt/ricty/share/fonts/Ricty*.ttf ~/Library/Fonts/
fc-cache -vf
```

#### `iTerm` -> `Preferences`

![](https://gyazo.com/c2ed34eda3d12e4b5a1ea93b0b471955.png)
