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

PREFIX ?= /usr/local
DESTDIR ?=
BINDIR ?= $(DESTDIR)$(PREFIX)/bin
MANDIR ?= $(DESTDIR)$(PREFIX)/share/man/man1
BASHCOMPDIR ?= $(DESTDIR)/etc/bash_completion.d
ZSHCOMPDIR ?= $(DESTDIR)$(PREFIX)/share/zsh/vendor-completions
FISHCOMPDIR ?= $(DESTDIR)$(PREFIX)/share/fish/vendor_completions.d

.PHONY: all build clean test lint install install-completions install-man deb

all: build

deb:
	dpkg-buildpackage -us -uc -b
	@echo "Debian package build complete"

build:
	@mkdir -p $(BIN_DIR)
	CGO_ENABLED=0 $(GO) build $(GOFLAGS) -ldflags "$(LDFLAGS)" -o $(TARGET) ./cmd/telcosec
	@echo "Build complete: $(TARGET)"

test:
	$(GO) test -v -cover ./...

clean:
	rm -rf $(BIN_DIR)

install-completions:
	install -d $(BASHCOMPDIR)
	install -m 644 completions/telcosec.bash $(BASHCOMPDIR)/telcosec
	install -d $(ZSHCOMPDIR)
	install -m 644 completions/_telcosec $(ZSHCOMPDIR)/_telcosec
	install -d $(FISHCOMPDIR)
	install -m 644 completions/telcosec.fish $(FISHCOMPDIR)/telcosec.fish
	@echo "Shell completions installed for Bash, Zsh, and Fish"

install-man:
	install -d $(MANDIR)
	gzip -9c docs/man/telcosec.1 > $(MANDIR)/telcosec.1.gz
	chmod 644 $(MANDIR)/telcosec.1.gz
	ln -sf telcosec.1.gz $(MANDIR)/telcochisel.1.gz
	@echo "Installed manpages to $(MANDIR)/telcosec.1.gz and linked telcochisel.1.gz"

install: build install-completions install-man
	install -d $(BINDIR)
	install -m 755 $(TARGET) $(BINDIR)/$(NAME)
	@ln -sf $(NAME) $(BINDIR)/telcochisel
	@echo "Installed $(NAME) to $(BINDIR)/$(NAME) and linked telcochisel"

