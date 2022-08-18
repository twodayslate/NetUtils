SOURCE_ROOT:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

.PHONY: help
help:
	@echo "Usage make [target]"
	@echo "Targets:"
	@echo "  bootstrap      Install necessary programs and requirements."
	@echo "  help           Print this message and exit."
	@echo "  format         Format and lint project."
	@echo "  snapshot       Use fastlane to take and deliver snapshots."
	@echo "  open           Open workspace."

.PHONY: bootstrap
bootstrap:
	gem install bundler
	bundle install

.PHONY: format lint
lint: format
format:
	cd BuildTools && swift run -c release swiftformat --config "${SOURCE_ROOT}/.swiftformat" "${SOURCE_ROOT}"
	cd BuildTools && swift run -c release swiftlint --config "${SOURCE_ROOT}/.swiftlint.yml" "${SOURCE_ROOT}" --fix

.PHONY: snapshot
snapshot:
	fastlane snapshot && fastlane deliver --overwrite_screenshots

.PHONY: open
open:
	xed .

.DEFAULT_GOAL := format
