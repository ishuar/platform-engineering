#!/usr/bin/env bash

## * This script checks if the kustomize binary is installed or not.
## * If it is not installed then it checks if `brew` command is available or not.
## * If brew is available then it installs kustomize via brew
## * Otherwise it follows https://kubectl.docs.kubernetes.io/installation/kustomize/binaries/ to install kustomize.

set -e

INSTALLATION_DIR="$HOME/local/bin"
TEMP_SCRIPT_FILE="/tmp/install_kustomize.sh"

echo "Check if kustomize is installed"

if ! which kustomize >/dev/null; then
  printf '\e[1;31m%-6s\e[0m\n' "Kustomize is not installed ..."

  if [ -x "$(command -v brew)" ]; then
    brew install kustomize
  else
    mkdir -p "$INSTALLATION_DIR"
    curl -sSo "$TEMP_SCRIPT_FILE" "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh"
    chmod +x "$TEMP_SCRIPT_FILE"
    "$TEMP_SCRIPT_FILE" "$INSTALLATION_DIR"
    export PATH="$INSTALLATION_DIR":"$PATH"
    rm "$TEMP_SCRIPT_FILE"
  fi

else
  printf '\e[1;32m%-6s\e[0m\n' "kustomize is already installed !!"
fi
