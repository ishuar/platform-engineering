.Phony: lockfile lock init init_lockfile initlock fmt format clean build install-kustomize check-terraform-file init

## Determine the Makefile's directory
## * dir function -> https://www.gnu.org/software/make/manual/html_node/File-Name-Functions.html#index-dir
## * abspath -> https://www.gnu.org/software/make/manual/html_node/File-Name-Functions.html#index-abspath-1
## * lastword -> http://gnu.ist.utl.pt/software/make/manual/html_node/Text-Functions.html#Text-Functions
## * MAKEFILE_LIST -> https://ftp.gnu.org/old-gnu/Manuals/make-3.80/html_node/make_17.html
MKFILE_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
SCRIPTS_DIR := $(MKFILE_DIR)/scripts

install-kustomize: ##? install kustomize , path is relative from argocd directory
	$(SCRIPTS_DIR)/install-kustomize.sh

build: install-kustomize
	kustomize build .

check-terraform-file:
	$(SCRIPTS_DIR)/check-tf-file.sh

init: check-terraform-file
	terraform init

initlock: init
	terraform providers lock -platform=darwin_arm64 -platform=darwin_amd64 -platform=linux_amd64 -platform=linux_arm64

fmt:
	terraform fmt -recursive

format: fmt

lock: initlock

clean:
	find . -type d -name ".terraform" -prune -exec rm -rf {} \;

clean-all: clean
	find . -name ".terraform.lock.hcl" -prune -exec rm -rf {} \;
	az logout
	az account clear

