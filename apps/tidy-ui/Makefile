APP     := Tidy
BUNDLE  := build/$(APP).app
BINARY  := $(BUNDLE)/Contents/MacOS/$(APP)
SOURCES := $(wildcard Sources/*.swift)
SWIFTC  := swiftc
FLAGS   := -swift-version 5 -parse-as-library -target arm64-apple-macos14.0 -framework AppKit

.PHONY: build run install clean

build: $(BINARY)

$(BINARY): $(SOURCES) Resources/Info.plist
	@mkdir -p $(BUNDLE)/Contents/MacOS $(BUNDLE)/Contents/Resources
	cp Resources/Info.plist $(BUNDLE)/Contents/Info.plist
	$(SWIFTC) $(FLAGS) $(SOURCES) -o $(BINARY)
	codesign --force --sign - $(BUNDLE)

run: build
	open $(BUNDLE)

install: build
	rm -rf /Applications/$(APP).app
	cp -R $(BUNDLE) /Applications/

clean:
	rm -rf build
