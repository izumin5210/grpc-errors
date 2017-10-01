SRC_FILES := $(shell git ls-files | grep -E "\.go$$" | grep -v -E "\.pb(:?\.gw)?\.go$$")
GO_TEST_FLAGS  := -v -race

DEP_COMMANDS := \
	vendor/github.com/golang/protobuf/protoc-gen-go


#  Commands
#-----------------------------------------------
.PHONY: dep
dep: Gopkg.toml Gopkg.lock
	@dep ensure -v
	@GOBIN="$$PWD/bin"; \
	pkgs="$(DEP_COMMANDS)"; \
	for pkg in $$pkgs; do \
		cd $$pkg; \
		go install .; \
		cd -; \
	done

.PHONY: gen
gen: $(SRC_FILES)
	@PATH=$$PWD/bin:$$PATH go generate ./...

.PHONY: lint
lint:
	@gofmt -e -d -s $(SRC_FILES) | awk '{ e = 1; print $0 } END { if (e) exit(1) }'
	@echo $(SRC_FILES) | xargs -n1 golint -set_exit_status
	@go vet ./...

.PHONY: test
test: gen lint
	@go test $(GO_TEST_FLAGS) ./...

.PHONY: ci-test
ci-test: lint
	@go test $(GO_TEST_FLAGS) ./...