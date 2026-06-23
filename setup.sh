#!/bin/bash
set -e

detect_os() {
  if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "mac"
  elif [[ -f /etc/lsb-release ]] || [[ -f /etc/debian_version ]]; then
    echo "ubuntu"
  else
    echo "unknown"
  fi
}
install_dependencies() {
  local os=$(detect_os)
  case $os in
  mac)
    brew install mise stow zsh neovim
    ;;
  ubuntu)
    sudo apt update
    sudo apt install -y stow zsh neovim
    curl https://mise.run | sh
    ;;
  *)
    echo "Unsupported OS"
    exit 1
    ;;
  esac
}
stow_dotfiles() {
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
update_submodules() {
  git submodule update --init --recursive
}
install_oh_my_zsh() {
  if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Installing oh-my-zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  else
    echo "oh-my-zsh already installed"
  fi
}
configure_zsh() {
  sudo chsh -s $(which zsh) $(whoami)
}
install_tools() {
  mise trust
  mise install --yes
}
echo "Installing dependencies..."
install_dependencies
echo "Updating submodules..."
update_submodules
echo "Installing oh-my-zsh and plugins..."
install_oh_my_zsh
echo "Stowing dotfiles..."
stow_dotfiles
echo "Configuring zsh as default shell..."
configure_zsh
echo "Installing global tools with mise..."
install_tools
echo "Setup complete! Please restart your shell."
