.PHONY: lint
.DEFAULT_GOAL := lint

lint:
	zizmor .
	editorconfig-checker
	flake-checker --no-telemetry
	nix flake check
