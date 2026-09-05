# ==============================================================================
# Makefile — Standalone TelcoSec Operator CLI
# ==============================================================================

NAME := telcosec
MODULE := github.com/TelcoSec-Tools/telcosec-cli
VERSION ?= 3.0.0
COMMIT := $(shell git rev-parse --short HEAD 2>/dev/null || echo "release")
BUILD_DATE := $(shell date -u +'%Y-%m-%dT%H:%M:%SZ')

GO ?= go
GOFLAGS ?= -trimpath
LDFLAGS := -s -w \
	-X main.Version=$(VERSION) \
	-X main.GitCommit=$(COMMIT) \
	-X main.BuildDate=$(BUILD_DATE)

BIN_DIR := bin
TARGET := $(BIN_DIR)/$(NAME)

.PHONY: all build clean test lint install

all: build

build:
	@mkdir -p $(BIN_DIR)
	CGO_ENABLED=0 $(GO) build $(GOFLAGS) -ldflags "$(LDFLAGS)" -o $(TARGET) ./cmd/telcosec
	@echo "Build complete: $(TARGET)"

test:
	$(GO) test -v -race -cover ./pkg/...

clean:
	rm -rf $(BIN_DIR)

install: build
	install -d /usr/local/bin
	install -m 755 $(TARGET) /usr/local/bin/$(NAME)
	@ln -sf /usr/local/bin/$(NAME) /usr/local/bin/telcochisel
	@echo "Installed $(NAME) to /usr/local/bin/$(NAME) and linked telcochisel"
