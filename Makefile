.PHONY: help manifests generate fmt vet test build docker-build docker-push docker-buildx deploy undeploy install uninstall clean check-gh branch pr

IMG ?= YOUR_DOCKER_REGISTRY/YOUR_PROJECT:latest
PLATFORMS ?= linux/arm64,linux/amd64
VERSION ?= $(shell git describe --tags --always --dirty 2>/dev/null || echo "dev")
GIT_COMMIT ?= $(shell git rev-parse --short HEAD 2>/dev/null || echo "none")
BUILD_DATE ?= $(shell date -u +"%Y-%m-%dT%H:%M:%SZ")

ENVTEST_K8S_VERSION = 1.31.0

## Location of tool binaries
LOCALBIN ?= $(shell pwd)/bin
$(LOCALBIN):
	mkdir -p $(LOCALBIN)

KUSTOMIZE ?= $(LOCALBIN)/kustomize
CONTROLLER_GEN ?= $(LOCALBIN)/controller-gen
ENVTEST ?= $(LOCALBIN)/setup-envtest

KUSTOMIZE_VERSION ?= v5.5.0
CONTROLLER_TOOLS_VERSION ?= v0.16.4
ENVTEST_VERSION ?= release-0.19

## Build

build: manifests generate fmt vet ## Build manager binary
	go build -ldflags="-s -w -X main.version=$(VERSION) -X main.gitCommit=$(GIT_COMMIT) -X main.buildDate=$(BUILD_DATE)" \
		-o bin/manager ./cmd/main.go

run: manifests generate fmt vet ## Run controller from host
	go run ./cmd/main.go

## Generate

manifests: controller-gen ## Generate CRD manifests, RBAC, etc.
	$(CONTROLLER_GEN) rbac:roleName=manager-role crd webhook paths="./..." output:crd:artifacts:config=config/crd/bases

generate: controller-gen ## Generate code (DeepCopy, etc.)
	$(CONTROLLER_GEN) object:headerFile="hack/boilerplate.go.txt" paths="./..."

## Quality

fmt: ## Format code
	go fmt ./...

vet: ## Run go vet
	go vet ./...

## Test

test: manifests generate fmt vet envtest ## Run unit tests
	KUBEBUILDER_ASSETS="$(shell $(ENVTEST) use $(ENVTEST_K8S_VERSION) --bin-dir $(LOCALBIN) -p path)" \
		go test ./... -v -race -cover -coverprofile=coverage.out

cover: test ## Generate coverage report
	go tool cover -func=coverage.out

cover-html: test ## Open coverage in browser
	go tool cover -html=coverage.out -o coverage.html
	open coverage.html

## Docker

docker-build: ## Build Docker image
	docker build \
		--build-arg VERSION=$(VERSION) \
		--build-arg GIT_COMMIT=$(GIT_COMMIT) \
		--build-arg BUILD_DATE=$(BUILD_DATE) \
		-t $(IMG) .

docker-push: ## Push Docker image
	docker push $(IMG)

docker-buildx: ## Build and push multi-arch Docker image
	- docker buildx create --name project-builder
	docker buildx use project-builder
	- docker buildx build --push --platform=$(PLATFORMS) \
		--build-arg VERSION=$(VERSION) \
		--build-arg GIT_COMMIT=$(GIT_COMMIT) \
		--build-arg BUILD_DATE=$(BUILD_DATE) \
		--tag $(IMG) .
	- docker buildx rm project-builder

## Deploy

install: manifests kustomize ## Install CRDs into cluster
	$(KUSTOMIZE) build config/crd | kubectl apply -f -

uninstall: manifests kustomize ## Uninstall CRDs from cluster
	$(KUSTOMIZE) build config/crd | kubectl delete --ignore-not-found -f -

deploy: manifests kustomize ## Deploy controller to cluster
	cd config/manager && $(KUSTOMIZE) edit set image controller=$(IMG)
	$(KUSTOMIZE) build config/default | kubectl apply -f -

undeploy: kustomize ## Undeploy controller from cluster
	$(KUSTOMIZE) build config/default | kubectl delete --ignore-not-found -f -

## Cleanup

clean: ## Remove build artifacts
	rm -rf bin/ coverage.out coverage.html

## Workflow

check-gh: ## Check if gh CLI is installed and authenticated
	@command -v gh >/dev/null 2>&1 || { echo "\033[31m✗ gh CLI not installed. Run: brew install gh\033[0m"; exit 1; }
	@gh auth status >/dev/null 2>&1 || { echo "\033[31m✗ gh CLI not authenticated. Run: gh auth login\033[0m"; exit 1; }
	@echo "\033[32m✓ gh CLI ready\033[0m"

branch: ## Create feature branch (usage: make branch name=feature-name)
	@if [ -z "$(name)" ]; then echo "Usage: make branch name=<feature-name>"; exit 1; fi
	git checkout main
	git pull origin main
	git checkout -b feat/$(name)
	@echo "\033[32m✓ Branch feat/$(name) created\033[0m"

pr: check-gh ## Run tests, push, and create PR (usage: make pr title="Add feature")
	@if [ -z "$(title)" ]; then echo "Usage: make pr title=\"PR title\""; exit 1; fi
	go test ./... -race -cover
	go vet ./...
	git push -u origin $$(git branch --show-current)
	@./scripts/create-pr.sh "$(title)"
	@echo "\033[32m✓ PR created\033[0m"

## Tool dependencies

.PHONY: kustomize controller-gen envtest

kustomize: $(KUSTOMIZE)
$(KUSTOMIZE): $(LOCALBIN)
	$(call go-install-tool,$(KUSTOMIZE),sigs.k8s.io/kustomize/kustomize/v5,$(KUSTOMIZE_VERSION))

controller-gen: $(CONTROLLER_GEN)
$(CONTROLLER_GEN): $(LOCALBIN)
	$(call go-install-tool,$(CONTROLLER_GEN),sigs.k8s.io/controller-tools/cmd/controller-gen,$(CONTROLLER_TOOLS_VERSION))

envtest: $(ENVTEST)
$(ENVTEST): $(LOCALBIN)
	$(call go-install-tool,$(ENVTEST),sigs.k8s.io/controller-runtime/tools/setup-envtest,$(ENVTEST_VERSION))

define go-install-tool
@[ -f "$(1)-$(3)" ] || { \
set -e; \
TMP_DIR=$$(mktemp -d); \
cd $$TMP_DIR; \
go mod init tmp; \
echo "Downloading $(2)@$(3)"; \
GOBIN=$(LOCALBIN) go install $(2)@$(3); \
rm -rf $$TMP_DIR; \
}
@ln -sf $$(basename $(1)) $(1)-$(3)
endef

## Help

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

.DEFAULT_GOAL := help
