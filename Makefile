SHELL := /bin/bash
.PHONY: help lint test check docker-build docker-run install uninstall clean

SCRIPT   := fixfolder.sh
INSTALL  := install.sh
PREFIX   ?= /usr/local

help:
	@echo "Usage: make <target>"
	@echo ""
	@echo "Targets:"
	@echo "  lint          Run ShellCheck on all scripts"
	@echo "  test          Run BATS test suite"
	@echo "  check         Run lint + test (CI gate)"
	@echo "  docker-build  Build Docker image"
	@echo "  docker-run    Run Docker container (arg: DIR=/path)"
	@echo "  install       Install script to \$$PREFIX/bin"
	@echo "  uninstall     Remove script from \$$PREFIX/bin"
	@echo "  clean         Remove test artifacts"

lint:
	shellcheck --severity=style --external-sources $(SCRIPT) $(INSTALL)
	shellcheck --severity=style --external-sources tests/*.bats tests/*.bash

test: lint
	@if command -v bats &>/dev/null; then \
		bats tests/; \
	elif command -v bats-core &>/dev/null; then \
		bats-core tests/; \
	else \
		echo "BATS not installed. Install with:"; \
		echo "  npm install -g bats" ; \
		exit 1; \
	fi

check: test

docker-build:
	docker build -t smart-file-organizer:latest .

docker-run:
	docker run --rm -v $(DIR):/data smart-file-organizer:latest /data

install:
	@if [ "$(shell id -u)" = "0" ]; then \
		cp $(SCRIPT) $(PREFIX)/bin/fixfolder; \
		chmod +x $(PREFIX)/bin/fixfolder; \
		echo "Installed to $(PREFIX)/bin/fixfolder"; \
	else \
		mkdir -p $(HOME)/.local/bin; \
		cp $(SCRIPT) $(HOME)/.local/bin/fixfolder; \
		chmod +x $(HOME)/.local/bin/fixfolder; \
		echo "Installed to $(HOME)/.local/bin/fixfolder"; \
		echo "Ensure \$$HOME/.local/bin is in your PATH"; \
	fi

uninstall:
	rm -f $(PREFIX)/bin/fixfolder $(HOME)/.local/bin/fixfolder

clean:
	rm -rf tests/fixtures tests/*.log
