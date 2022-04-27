BACKEND?=docker
CONCURRENCY?=1

# Abs path only. It gets copied in chroot in pre-seed stages
BHOJPUR_ISO_MANAGER?=/usr/bin/isomgr
export ROOT_DIR:=$(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
DESTINATION?=$(ROOT_DIR)/output
COMPRESSION?=zstd
CLEAN?=true
TREE?=./packages
BUILD_ARGS?= --pull --image-repository quay.io/bhojpur/repo-amd64-cache --only-target-package
export BHOJPUR_BIN?=$(BHOJPUR_ISO_MANAGER)

.PHONY: all
all: deps build

.PHONY: deps
deps:
	@echo "Installing Bhojpur ISO"
	go get -u github.com/bhojpur/iso

.PHONY: clean
clean:
	rm -rf build/ *.tar *.metadata.yaml

.PHONY: build
build: clean
	mkdir -p $(ROOT_DIR)/build
	$(BHOJPUR_ISO_MANAGER) build $(BUILD_ARGS) --tree=$(TREE) $(PACKAGES) --destination $(ROOT_DIR)/build --backend $(BACKEND) --concurrency $(CONCURRENCY) --compression $(COMPRESSION)

.PHONY: build-all
build-all: clean
	mkdir -p $(ROOT_DIR)/build
	$(BHOJPUR_ISO_MANAGER) build $(BUILD_ARGS) --tree=$(TREE) --all --destination $(ROOT_DIR)/build --backend $(BACKEND) --concurrency $(CONCURRENCY) --compression $(COMPRESSION)
	rm -rf $(ROOT_DIR)/build/*.image.tar

.PHONY: rebuild
rebuild:
	$(BHOJPUR_ISO_MANAGER) build $(BUILD_ARGS) --tree=$(TREE) $(PACKAGES) --destination $(ROOT_DIR)/build --backend $(BACKEND) --concurrency $(CONCURRENCY) --compression $(COMPRESSION)

.PHONY: rebuild-all
rebuild-all:
	$(BHOJPUR_ISO_MANAGER) build $(BUILD_ARGS) --tree=$(TREE) --all --destination $(ROOT_DIR)/build --backend $(BACKEND) --concurrency $(CONCURRENCY) --compression $(COMPRESSION)

.PHONY: create-repo
create-repo:
	$(BHOJPUR_ISO_MANAGER) create-repo --tree "$(TREE)" \
    --output $(ROOT_DIR)/build \
    --packages $(ROOT_DIR)/build \
    --name "bhojpur-official" \
    --descr "Bhojpur ISO official repository" \
    --urls "http://localhost:8000" \
    --tree-compression $(COMPRESSION) \
    --tree-filename tree.tar \
    --meta-compression $(COMPRESSION) \
    --type http

.PHONY: serve-repo
serve-repo:
	BHOJPUR_ISO_NOLOCK=true $(BHOJPUR_ISO_MANAGER) serve-repo --port 8000 --dir $(ROOT_DIR)/build

.PHONY: autobump
autobump:
	TREE_DIR=$(ROOT_DIR) $(BHOJPUR_ISO_MANAGER) autobump-github
	
.PHONY: auto-bump
auto-bump: autobump
