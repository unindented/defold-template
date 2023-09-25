APP_NAME := Template
# This is provided by `semantic-release`
# APP_VERSION :=

RESOLVE_DIR := .internal
ASSETS_DIR := assets
BUILD_DIR := build
COVERAGE_DIR := coverage
DIST_DIR := dist
TOOLS_DIR := tools

MACOS_ASSETS_DIR := $(ASSETS_DIR)/macos

# Tools

BOB_PATH := $(TOOLS_DIR)/bob.jar
BOB_VERSION := 1.5.0
BOB_SHA256 := 0a7487f746c3278dc1f4159f20018fd74214d9982de958fdd4aa602d366f0977

# Outputs

COMMON_DIST_LICENSE := $(DIST_DIR)/LICENSE.md
COMMON_DIST_CHANGELOG := $(DIST_DIR)/CHANGELOG.md

MACOS_ICONSET :=  $(MACOS_ASSETS_DIR)/icon.iconset
MACOS_ICONSET_ALL :=  $(shell find $(MACOS_ICONSET) -type f -name '*.png' | sort -V)
MACOS_ICON := $(MACOS_ASSETS_DIR)/icon.icns
MACOS_DIST_DIR := $(DIST_DIR)/macos
MACOS_DIST_APP := $(MACOS_DIST_DIR)/$(APP_NAME).app
MACOS_DIST_DMG := $(MACOS_DIST_DIR)/$(APP_NAME)-macos.dmg
MACOS_DIST_ZIP := $(MACOS_DIST_DIR)/$(APP_NAME)-macos.zip

# Targets

.PHONY: clean
clean:
	rm -rf "$(RESOLVE_DIR)"
	rm -rf "$(BUILD_DIR)"
	rm -rf "$(COVERAGE_DIR)"
	rm -rf "$(DIST_DIR)"
	rm -rf manifest.*

.PHONY: all
all:
	$(MAKE) version
	$(MAKE) resolve
	$(MAKE) dist-common
	$(MAKE) dist-macos

.PHONY: version
version:
	perl -i -pe 's/game_debug.appmanifest/game_release.appmanifest/g;' \
		-pe 's/0.0.0-development/$(APP_VERSION)/g;' \
		-pe 's/2100000000/$(subst .,,$(APP_VERSION))/g;' \
		game.project

resolve: $(RESOLVE_DIR)
dist-common: $(COMMON_DIST_LICENSE) $(COMMON_DIST_CHANGELOG)
dist-macos: $(MACOS_DIST_ZIP) $(MACOS_DIST_DMG) $(MACOS_DIST_APP)

$(RESOLVE_DIR): $(BOB_PATH)
	java -jar "$(BOB_PATH)" resolve

$(COMMON_DIST_LICENSE): LICENSE.md
	mkdir -p `dirname "$@"`
	cp "$<" "$@"

$(COMMON_DIST_CHANGELOG): CHANGELOG.md
	mkdir -p `dirname "$@"`
	cp "$<" "$@"

$(MACOS_DIST_ZIP): $(MACOS_DIST_DMG)
	hdiutil attach "$<"
	tree -hs "/Volumes/$(APP_NAME)/$(APP_NAME).app"
	file -b "/Volumes/$(APP_NAME)/$(APP_NAME).app/Contents/MacOS/$(APP_NAME)"
	/usr/bin/ditto -c -k -rsrc --sequesterRsrc --keepParent "/Volumes/$(APP_NAME)/$(APP_NAME).app" "$@"
	hdiutil detach "/Volumes/$(APP_NAME)"

$(MACOS_DIST_DMG): $(MACOS_DIST_APP)
	tree -hs "$<"
	file -b "$</Contents/MacOS/$(APP_NAME)"
	mkdir -p "$(MACOS_DIST_DIR)"
	-npx create-dmg --overwrite "$<" "$(MACOS_DIST_DIR)"
	mv "$(MACOS_DIST_DIR)"/*.dmg "$@"

$(MACOS_DIST_APP): $(MACOS_ICON) $(BOB_PATH)
	mkdir -p "$(MACOS_DIST_DIR)"
	java -jar "$(BOB_PATH)" \
		--archive \
		--build-report-html "$(MACOS_DIST_DIR)/report.html" \
		--bundle-output "$(MACOS_DIST_DIR)" \
		--exclude-build-folder test \
		--texture-compression true \
		--platform x86_64-macos \
		distclean build bundle

$(MACOS_ICON): $(MACOS_ICONSET_ALL)
	iconutil -c icns -o "$@" "$(MACOS_ICONSET)"

$(BOB_PATH):
	curl -L -o /tmp/bob.jar "https://github.com/defold/defold/releases/download/$(BOB_VERSION)/bob.jar"
	echo "$(BOB_SHA256) /tmp/bob.jar" | sha256sum --check
	mkdir -p `dirname "$(BOB_PATH)"`
	mv /tmp/bob.jar "$(BOB_PATH)"
	java -jar "$(BOB_PATH)" --version
