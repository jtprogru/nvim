# Test & lint harness for this Neovim config.
#
#   make smoke       — load the full config headless, fail on any error
#   make test        — run plenary busted unit tests (tests/*_spec.lua)
#   make test-file FILE=tests/templater_spec.lua  — run a single spec
#   make lint        — selene static analysis
#   make fmt         — format Lua with stylua (in place)
#   make fmt-check   — verify formatting without writing
#   make all         — smoke + test + lint + fmt-check (full local gate)
#
# Unit tests and smoke only need plenary.nvim + the config itself; no other
# plugins are loaded (see tests/minimal_init.lua).

NVIM ?= nvim
MINIMAL := tests/minimal_init.lua

.PHONY: all test test-file smoke lint fmt fmt-check help

help:
	@grep -E '^#   make' $(MAKEFILE_LIST) | sed 's/^#   /  /'

all: smoke test lint fmt-check

test:
	@echo "==> unit tests (plenary busted)"
	@$(NVIM) --headless --noplugin -u $(MINIMAL) \
		-c "PlenaryBustedDirectory tests/ { minimal_init = '$(MINIMAL)' }"

test-file:
	@test -n "$(FILE)" || { echo "usage: make test-file FILE=tests/foo_spec.lua"; exit 2; }
	@echo "==> unit test: $(FILE)"
	@$(NVIM) --headless --noplugin -u $(MINIMAL) \
		-c "PlenaryBustedFile $(FILE) { minimal_init = '$(MINIMAL)' }"

smoke:
	@echo "==> smoke: loading full config headless"
	@$(NVIM) --headless -c 'luafile tests/smoke.lua'

lint:
	@command -v selene >/dev/null 2>&1 || { echo "selene not installed — brew install selene (or cargo install selene)"; exit 1; }
	@echo "==> selene"
	@selene init.lua lua tests

fmt:
	@command -v stylua >/dev/null 2>&1 || { echo "stylua not installed — brew install stylua (or cargo install stylua)"; exit 1; }
	@echo "==> stylua (writing)"
	@stylua init.lua lua tests

fmt-check:
	@command -v stylua >/dev/null 2>&1 || { echo "stylua not installed — brew install stylua (or cargo install stylua)"; exit 1; }
	@echo "==> stylua --check"
	@stylua --check init.lua lua tests
