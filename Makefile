# Makefile

# Tools
GO_FUMPT = mvdan.cc/gofumpt@latest
GO_LINT = github.com/golangci/golangci-lint/v2/cmd/golangci-lint@latest
GO_TEST = gotest.tools/gotestsum@latest

ifndef $(GOPATH)
    GOPATH=$(shell go env GOPATH)
    export GOPATH
endif

# Variables
ARTIFACT_NAME = hsc-revive
VERSION       =`git describe --tags --abbrev=0`

##@ General

.PHONY: help
help: ## Display this help.
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-22s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

show: ## Show variables
	@echo "\n\033[1mVariables\033[0m"
	@echo "\033[36m  ARTIFACT_NAME\033[0m $(ARTIFACT_NAME)"
	@echo "\033[36m  VERSION\033[0m $(VERSION)"

##@ Code analysis

.PHONY: fmt
fmt: ## Run gofumpt against code.
	go run $(GO_FUMPT) -w .

.PHONY: vet
vet: ## Run go vet against code.
	go vet ./...

.PHONY: lint
lint: ## Run golangci-lint against code.
	mkdir -p build/reports
	go run $(GO_LINT) run --timeout 2m

.PHONY: static-analysis
static-analysis: lint vet ## Run static analysis against code.

##@ GO

.PHONY: clean
clean: ## Clean the build directory
	rm -rf ./dist
	rm -rf ./build
	rm -rf ./vendor

.PHONY: build
build: ## Build the default binary
	go build -o build/bin/hsc-revive ./cmd/hsc-revive

.PHONY: run
run: build ## Run the binary on local machine
	build/bin/hsc-revive

.PHONY: all
all: unit-test build ## Run the unit tests and build the binaries

##@ Test

.PHONY: unit-test
unit-test: ## Run unit tests
	mkdir -p build/reports
	go run $(GO_TEST) --format pkgname \
	  --junitfile build/reports/unit-test.xml -- \
	  -race ./... -count=1 -short -cover -coverprofile \
	  build/reports/unit-test-coverage.out
