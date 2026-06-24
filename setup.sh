#!/bin/bash
set -e

ensure_rust() {
  # If cargo is already available (e.g. pre-installed in a dev container like
  # Ona, where Rust lives in /usr/local/cargo owned by root), don't try to run
  # rustup — it will fail with "cannot install while Rust is installed" and a
  # permission error trying to overwrite the existing binary.
  if command -v cargo >/dev/null 2>&1; then
    echo "cargo already installed ($(command -v cargo)); skipping rustup"
  elif [ -f "$HOME/.cargo/env" ]; then
    echo "Found existing rustup install; sourcing it"
    source "$HOME/.cargo/env"
  else
    curl https://sh.rustup.rs -sSf | sh -s -- -y
    source "$HOME/.cargo/env"
  fi
}

install_tree_sitter() {
  if command -v tree-sitter >/dev/null 2>&1; then
    echo "tree-sitter-cli already installed; skipping"
    return
  fi

  # Prefer the official prebuilt binary over `cargo install`. The crate now
  # pulls in rquickjs-sys, whose build script compiles a QuickJS C engine from
  # source and needs a full C toolchain — slow and fragile in minimal
  # containers. The prebuilt binary sidesteps all of that.
  local os arch
  case "$(uname -s)" in
    Darwin) os="macos" ;;
    Linux) os="linux" ;;
    *) os="" ;;
  esac
  case "$(uname -m)" in
    x86_64 | amd64) arch="x64" ;;
    arm64 | aarch64) arch="arm64" ;;
    *) arch="" ;;
  esac

  if [ -n "$os" ] && [ -n "$arch" ]; then
    local asset="tree-sitter-${os}-${arch}.gz"
    local url="https://github.com/tree-sitter/tree-sitter/releases/latest/download/${asset}"
    echo "Downloading prebuilt tree-sitter ($asset)..."
    mkdir -p "$HOME/.local/bin"
    if curl -fsSL "$url" | gunzip >"$HOME/.local/bin/tree-sitter"; then
      chmod +x "$HOME/.local/bin/tree-sitter"
      return
    fi
    echo "Prebuilt download failed; falling back to 'cargo install'"
  fi

  # Fallback: build from source. The pre-installed cargo may use a root-owned
  # CARGO_HOME (e.g. /usr/local/cargo in the Ona dev container), so override it
  # and the install root to user-owned locations. Needs a C toolchain
  # (build-essential), installed above on Ubuntu.
  CARGO_HOME="$HOME/.cargo" cargo install tree-sitter-cli --root "$HOME/.local"
}

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
    brew install mise stow zsh neovim ripgrep fd
    ensure_rust
    install_tree_sitter
    ;;
  ubuntu)
    export DEBIAN_FRONTEND=noninteractive
    sudo apt-get update
    sudo apt-get install -y stow zsh neovim build-essential
    curl https://mise.run | sh
    ensure_rust
    install_tree_sitter
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
  if ! sudo chsh -s "$(which zsh)" "$(whoami)"; then
    echo "Could not change default shell to zsh; skipping (continue setup)"
  fi
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
