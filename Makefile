.Phony: lockfile lock init init_lockfile providerlock fmt format clean build install-kustomize

install-kustomize: ##? install kustomize , path is relative from argocd directory
	../scripts/install-kustomize.sh

build: install-kustomize
	kustomize build .

providerlock:
	terraform providers lock -platform=darwin_arm64 -platform=darwin_amd64 -platform=linux_amd64 -platform=linux_arm64

fmt:
	terraform fmt -recursive

format:
	terraform fmt -recursive

clean:
	find . -type d -name ".terraform" -prune -exec rm -rf {} \;
