SHELL := /bin/bash

.PHONY: up test down

up:
	@bash scripts/up.sh

test:
	@bash scripts/test.sh

down:
	@bash scripts/down.sh
