.PHONY: all build clean test

all: build

build:
	@bash build-metapackages.sh

clean:
	@rm -rf dist build

test:
	@bash -n build-metapackages.sh
	@echo "All metapackage scripts pass syntax verification."
