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
```