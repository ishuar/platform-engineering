#!/usr/bin/env bash

## * This scripts check if there is any terraform configuration (.tf) file available in the current directory.
## * If not available it exits the script with exit code 200.
## * If found terraform files then no action.

set -e

DIR=${DIR:="$(pwd)"}

for file in "$DIR"/*.tf; do
  if [[ ! -e "$file" ]]; then
    ## \e[ starts the ANSI escape sequence, 1;31m specifies the formatting options (bold and red text), and \e[0m resets the text formatting to default. The \n adds a newline character at the end.
    printf "\e[1;31mNo Terraform configuration available in the current directory\e[0m\n"
    exit 200
  fi
done
