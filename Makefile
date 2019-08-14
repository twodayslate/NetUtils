SOURCE_ROOT:=./ec3730

.PHONY: help
help:
	@echo "Usage make [target]"
	@echo "Targets:"
	@echo "  bootstrap      Install necessary programs and requirements."
	@echo "  help           Print this message and exit."
	@echo "  format         Format/lint project."
	@echo "  open           Open workspace."

.PHONY: bootstrap
bootstrap:
	sudo gem install cocoapods
	pod install

.PHONY: format lint
lint: format
format:
	./Pods/SwiftFormat/CommandLineTool/swiftformat .
	./Pods/SwiftLint/swiftlint autocorrect "${SOURCE_ROOT}"

.PHONY: open
open:
	xed .

.DEFAULT_GOAL := format
