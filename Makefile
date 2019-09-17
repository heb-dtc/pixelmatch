CURRENT_DIR = $(shell pwd)
BUILD_DIR = $(CURRENT_DIR)/build

all: package

package: package
	zip -9 -x .\* Makefile *.md build/ -r $(BUILD_DIR)/PixelMatch.love .

.PHONY: all
