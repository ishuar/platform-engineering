#!/usr/bin/env bash

set -e

INSTALLATION_DIR="$HOME/local/bin"
TEMP_SCRIPT_FILE="/tmp/install_kustomize.sh"

echo "Check if kustomize is installed"

if ! which kustomize >/dev/null; then
  echo "Kustomize is not installed ..."

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
  echo "kustomize is installed"
fi
