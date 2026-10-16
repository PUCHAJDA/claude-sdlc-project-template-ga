# Single-command interface. Everything else in this template calls these targets —
# CLAUDE.md, the evals, the verifier subagent, CI.
#
# The one rule that matters: EVERY TARGET MUST EXIT NON-ZERO ON FAILURE.
# A check that prints errors and exits 0 gives Claude a green light on broken code, and it
# will confidently build on top of it. Wrap your real tooling below; keep the names.

.PHONY: install test lint typecheck check dev rollback quarantine

install:   ## Install dependencies
	@echo "TODO: wire up this project's installer" && exit 1

test:      ## Run the test suite
	@echo "TODO: wire up this project's test runner" && exit 1

lint:      ## Lint and format-check
	@echo "TODO: wire up this project's linter" && exit 1

typecheck: ## Static type check
	@true

check: lint typecheck test   ## Everything CI runs. "Done" means this passed.

dev:       ## Run locally
	@echo "TODO: wire up this project's dev server" && exit 1

# --- Stage 6 runbooks, referenced from docs/sdlc/bands.yaml ---------------------------
# Rehearse both in staging before listing them as pre-approved. A runbook that has never
# been run is a plan, and incidents are the wrong time to find out which one you have.

rollback:  ## Roll back the last deployment
	@echo "TODO: wire up rollback" && exit 1

quarantine: ## Mark a flaky test as quarantined: make quarantine TEST=<id>
	@echo "TODO: wire up quarantine for $(TEST)" && exit 1
