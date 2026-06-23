#!/bin/bash
set -e
brew install stow zsh neovim

if [ -f "$HOME/.zshrc" ]; then
  echo "Found existing .zshrc, backing up to .zshrc-bak"
  mv "$HOME/.zshrc" "$HOME/.zshrc-bak"
fi

sudo chsh -s $(which zsh) $(whoami)
