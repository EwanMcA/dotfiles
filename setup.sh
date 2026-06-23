#!/bin/bash
set -e
brew install stow zsh neovim

if [ -f "$HOME/.zshrc" ]; then
  echo "Found existing .zshrc, backing up to .zshrc-bak"
  mv "$HOME/.zshrc" "$HOME/.zshrc-bak"
fi

stow --target="$HOME" \
  --ignore='.git' \
  --ignore='.gitmodules' \
  --ignore='README.md' \
  --ignore='setup.sh' \
  .
}

if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "Installing oh-my-zsh..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
  echo "oh-my-zsh already installed"
fi

sudo chsh -s $(which zsh) $(whoami)
