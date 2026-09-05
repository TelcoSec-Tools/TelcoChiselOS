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

.PHONY: all build clean test lint install install-completions install-man

all: build

build:
	@mkdir -p $(BIN_DIR)
	CGO_ENABLED=0 $(GO) build $(GOFLAGS) -ldflags "$(LDFLAGS)" -o $(TARGET) ./cmd/telcosec
	@echo "Build complete: $(TARGET)"

test:
	$(GO) test -v -cover ./...

clean:
	rm -rf $(BIN_DIR)

install-completions:
	install -d /etc/bash_completion.d
	install -m 644 completions/telcosec.bash /etc/bash_completion.d/telcosec
	install -d /usr/share/zsh/vendor-completions
	install -m 644 completions/_telcosec /usr/share/zsh/vendor-completions/_telcosec
	install -d /usr/share/fish/vendor_completions.d
	install -m 644 completions/telcosec.fish /usr/share/fish/vendor_completions.d/telcosec.fish
	@echo "Shell completions installed for Bash, Zsh, and Fish"

install-man:
	install -d /usr/share/man/man1
	gzip -9c docs/man/telcosec.1 > /usr/share/man/man1/telcosec.1.gz
	chmod 644 /usr/share/man/man1/telcosec.1.gz
	ln -sf telcosec.1.gz /usr/share/man/man1/telcochisel.1.gz
	@echo "Installed manpages to /usr/share/man/man1/telcosec.1.gz and linked telcochisel.1.gz"

install: build install-completions install-man
	install -d /usr/local/bin
	install -m 755 $(TARGET) /usr/local/bin/$(NAME)
	@ln -sf /usr/local/bin/$(NAME) /usr/local/bin/telcochisel
	@echo "Installed $(NAME) to /usr/local/bin/$(NAME) and linked telcochisel"

