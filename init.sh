#!/bin/bash
set -euo pipefail

OS="$(uname -s)"

function main() {
  case "$OS" in
    Darwin)
      echo "Detected macOS"
      if ! command -v brew >/dev/null; then
        echo "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
      fi
      brew install chezmoi
      ;;
    Linux)
      echo "Detected Linux"
      command -v apt >/dev/null || exit_with_error "Unsupported Linux distro"
      sudo apt update
      sudo apt-get install -y curl git keychain ssh
      sh -c "$(curl -fsLS get.chezmoi.io)" -- -b ~/.local/bin
      export PATH="$HOME/.local/bin:$PATH"
      ;;
    *)
      echo "Unsupported OS: $OS"
      exit 1
      ;;
  esac

  while :
  do
    read -p "Repo: " REPO
    if [ -n "$REPO" ]; then
      break
    fi
  done

  # Initialize chezmoi from your repo
  chezmoi init --apply "$REPO" --ssh
}

exit_with_error() {
  if [ "$#" -gt 0 ]; then printf '%s\n' "$@" >&2; fi
  exit 1
}

main "$@"
