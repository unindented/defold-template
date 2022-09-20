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
STEAM_ASSETS_DIR := $(ASSETS_DIR)/steam
WINDOWS_ASSETS_DIR := $(ASSETS_DIR)/windows

STEAM_HOME := $(HOME)/Library/Application\ Support/Steam
STEAM_CONFIG_DIR := $(STEAM_HOME)/config
STEAM_CONFIG_FILE := $(STEAM_HOME)/config/config.vdf
STEAM_SSFN_FILE := $(STEAM_HOME)/$(STEAM_SSFN_NAME)

# Tools

BOB_PATH := $(TOOLS_DIR)/bob.jar
BOB_VERSION := 1.3.6
BOB_SHA256 := 2437a306ab20e754700b69c4ea2be277507a358e90b91d928d0788f3c94336be

RCEDIT_PATH := $(TOOLS_DIR)/rcedit.exe
RCEDIT_VERSION := 1.1.1
RCEDIT_SHA256 := 02e8e8c5d430d8b768980f517b62d7792d690982b9ba0f7e04163cbc1a6e7915

BUTLER_PATH := $(TOOLS_DIR)/butler/butler
BUTLER_VERSION := 15.21.0
BUTLER_SHA256 := af8fc2e7c4d4a2e2cb9765c343a88ecafc0dccc2257ecf16f7601fcd73a148ec

STEAMCMD_PATH := $(TOOLS_DIR)/steamcmd/steamcmd
STEAMCMD_SHA256 := 8ecc17c8988e5acadcc78e631c48490f76150f2dfaa6cf8d7b4b67b097bd753b

# Outputs

COMMON_DIST_LICENSE := $(DIST_DIR)/LICENSE.md
COMMON_DIST_CHANGELOG := $(DIST_DIR)/CHANGELOG.md

WINDOWS_ICONSET := $(WINDOWS_ASSETS_DIR)/iconset
WINDOWS_ICONSET_ALL := $(shell find $(WINDOWS_ICONSET) -type f -name '*.png' | sort -rV)
WINDOWS_ICON := $(WINDOWS_ASSETS_DIR)/icon.ico
WINDOWS_DIST_DIR := $(DIST_DIR)/windows
WINDOWS_DIST_APP := $(WINDOWS_DIST_DIR)/$(APP_NAME)
WINDOWS_DIST_ZIP := $(WINDOWS_DIST_DIR)/$(APP_NAME)-windows.zip

MACOS_ICONSET :=  $(MACOS_ASSETS_DIR)/icon.iconset
MACOS_ICONSET_ALL :=  $(shell find $(MACOS_ICONSET) -type f -name '*.png' | sort -V)
MACOS_ICON := $(MACOS_ASSETS_DIR)/icon.icns
MACOS_UNNOTARIZED_DIST_DIR := $(DIST_DIR)/macos-unnotarized
MACOS_UNNOTARIZED_DIST_APP := $(MACOS_UNNOTARIZED_DIST_DIR)/$(APP_NAME).app
MACOS_DIST_DIR := $(DIST_DIR)/macos
MACOS_DIST_APP := $(MACOS_DIST_DIR)/$(APP_NAME).app
MACOS_DIST_DMG := $(MACOS_DIST_DIR)/$(APP_NAME)-macos.dmg
MACOS_DIST_ZIP := $(MACOS_DIST_DIR)/$(APP_NAME)-macos.zip

LINUX_DIST_DIR := $(DIST_DIR)/linux
LINUX_DIST_APP := $(LINUX_DIST_DIR)/$(APP_NAME)
LINUX_DIST_ZIP := $(LINUX_DIST_DIR)/$(APP_NAME)-linux.zip

WEB_DIST_DIR := $(DIST_DIR)/web
WEB_DIST_APP := $(WEB_DIST_DIR)/$(APP_NAME)
WEB_DIST_ZIP := $(WEB_DIST_DIR)/$(APP_NAME)-web.zip

# Targets

.PHONY: release
release:
	npx semantic-release

.PHONY: clean
clean:
	rm -rf "$(RESOLVE_DIR)"
	rm -rf "$(BUILD_DIR)"
	rm -rf "$(COVERAGE_DIR)"
	rm -rf "$(DIST_DIR)"
	rm -rf manifest.*

.PHONY: test
test:
	$(MAKE) resolve
	$(MAKE) test-macos

.PHONY: run
run:
	$(MAKE) resolve
	$(MAKE) run-macos

.PHONY: all
all:
	$(MAKE) version
	$(MAKE) resolve
	$(MAKE) dist-common
	$(MAKE) dist-windows
	$(MAKE) dist-macos
	$(MAKE) dist-linux
	$(MAKE) dist-web

.PHONY: test-windows
test-windows: $(BOB_PATH)
	mkdir -p "$(COVERAGE_DIR)"
	java -jar "$(BOB_PATH)" \
		--variant headless \
		--platform x86_64-win32 \
		build
	"$(BUILD_DIR)/x86_64-win32/dmengine.exe" --config="bootstrap.main_collection=/test/test.collectionc"

.PHONY: test-macos
test-macos: $(BOB_PATH)
	mkdir -p "$(COVERAGE_DIR)"
	java -jar "$(BOB_PATH)" \
		--variant headless \
		--platform x86_64-macos \
		build
	chmod +x "$(BUILD_DIR)/x86_64-osx/dmengine"
	"$(BUILD_DIR)/x86_64-osx/dmengine" --config="bootstrap.main_collection=/test/test.collectionc"

.PHONY: test-linux
test-linux: $(BOB_PATH)
	mkdir -p "$(COVERAGE_DIR)"
	java -jar "$(BOB_PATH)" \
		--variant headless \
		--platform x86_64-linux \
		build
	chmod +x "$(BUILD_DIR)/x86_64-linux/dmengine"
	"$(BUILD_DIR)/x86_64-linux/dmengine" --config="bootstrap.main_collection=/test/test.collectionc"

.PHONY: run-windows
run-windows: $(BOB_PATH)
	java -jar "$(BOB_PATH)" \
		--platform x86_64-win32 \
		build
	"$(BUILD_DIR)/x86_64-win32/dmengine.exe"

.PHONY: run-macos
run-macos: $(BOB_PATH)
	java -jar "$(BOB_PATH)" \
		--platform x86_64-macos \
		build
	chmod +x "$(BUILD_DIR)/x86_64-osx/dmengine"
	rm "$(BUILD_DIR)/x86_64-osx/Info.plist"
	"$(BUILD_DIR)/x86_64-osx/dmengine"

.PHONY: run-linux
run-linux: $(BOB_PATH)
	java -jar "$(BOB_PATH)" \
		--platform x86_64-linux \
		build
	chmod +x "$(BUILD_DIR)/x86_64-linux/dmengine"
	"$(BUILD_DIR)/x86_64-linux/dmengine"

.PHONY: version
version:
	perl -i -pe 's/game_debug.appmanifest/game_release.appmanifest/g;' \
		-pe 's/0.0.0-development/$(APP_VERSION)/g;' \
		-pe 's/2100000000/$(subst .,,$(APP_VERSION))/g;' \
		game.project

.PHONY: publish
publish:
	$(MAKE) publish-itchio
	$(MAKE) publish-steam

.PHONY: publish-itchio
publish-itchio:
	$(MAKE) publish-itchio-windows
	$(MAKE) publish-itchio-macos
	$(MAKE) publish-itchio-linux
	$(MAKE) publish-itchio-web

.PHONY: publish-itchio-windows
publish-itchio-windows: $(WINDOWS_DIST_ZIP) $(BUTLER_PATH)
	"$(BUTLER_PATH)" push "$<" "$(BUTLER_PROJECT):windows" --userversion "$(APP_VERSION)"

.PHONY: publish-itchio-macos
publish-itchio-macos: $(MACOS_DIST_APP) $(BUTLER_PATH)
	"$(BUTLER_PATH)" push "$<" "$(BUTLER_PROJECT):macos" --userversion "$(APP_VERSION)"

.PHONY: publish-itchio-linux
publish-itchio-linux: $(LINUX_DIST_ZIP) $(BUTLER_PATH)
	"$(BUTLER_PATH)" push "$<" "$(BUTLER_PROJECT):linux" --userversion "$(APP_VERSION)"

.PHONY: publish-itchio-web
publish-itchio-web: $(WEB_DIST_ZIP) $(BUTLER_PATH)
	"$(BUTLER_PATH)" push "$<" "$(BUTLER_PROJECT):web" --userversion "$(APP_VERSION)"

.PHONY: publish-steam
publish-steam: $(STEAM_ASSETS_DIR)/app_build_$(STEAM_APP_ID).txt \
		$(STEAM_ASSETS_DIR)/app_build_$(STEAM_APP_ID).vdf \
		$(STEAM_ASSETS_DIR)/depot_build_$(STEAM_COMMON_DEPOT_ID).vdf \
		$(STEAM_ASSETS_DIR)/depot_build_$(STEAM_WINDOWS_DEPOT_ID).vdf \
		$(STEAM_ASSETS_DIR)/depot_build_$(STEAM_MACOS_DEPOT_ID).vdf \
		$(STEAM_ASSETS_DIR)/depot_build_$(STEAM_LINUX_DEPOT_ID).vdf \
		$(STEAM_CONFIG_FILE) \
		$(STEAM_SSFN_FILE) \
		$(STEAMCMD_PATH) \
		$(WINDOWS_DIST_APP) $(MACOS_DIST_APP) $(LINUX_DIST_APP)
	"$(STEAMCMD_PATH)" +runscript "../../$<"

$(STEAM_ASSETS_DIR)/app_build_$(STEAM_APP_ID).txt: $(STEAM_ASSETS_DIR)/app_build_1000.txt
	APP_NAME="$(APP_NAME)" envsubst < "$<" > "$@"

$(STEAM_ASSETS_DIR)/app_build_$(STEAM_APP_ID).vdf: $(STEAM_ASSETS_DIR)/app_build_1000.vdf
	APP_NAME="$(APP_NAME)" envsubst < "$<" > "$@"

$(STEAM_ASSETS_DIR)/depot_build_$(STEAM_COMMON_DEPOT_ID).vdf: $(STEAM_ASSETS_DIR)/depot_build_1001.vdf
	APP_NAME="$(APP_NAME)" envsubst < "$<" > "$@"

$(STEAM_ASSETS_DIR)/depot_build_$(STEAM_WINDOWS_DEPOT_ID).vdf: $(STEAM_ASSETS_DIR)/depot_build_1002.vdf
	APP_NAME="$(APP_NAME)" envsubst < "$<" > "$@"

$(STEAM_ASSETS_DIR)/depot_build_$(STEAM_MACOS_DEPOT_ID).vdf: $(STEAM_ASSETS_DIR)/depot_build_1003.vdf
	APP_NAME="$(APP_NAME)" envsubst < "$<" > "$@"

$(STEAM_ASSETS_DIR)/depot_build_$(STEAM_LINUX_DEPOT_ID).vdf: $(STEAM_ASSETS_DIR)/depot_build_1004.vdf
	APP_NAME="$(APP_NAME)" envsubst < "$<" > "$@"

$(STEAM_CONFIG_FILE):
	mkdir -p $(STEAM_CONFIG_DIR)
	echo "$(STEAM_CONFIG_CONTENTS)" | base64 -d > "$@"
	chmod 777 "$@"

$(STEAM_SSFN_FILE):
	mkdir -p $(STEAM_CONFIG_DIR)
	echo "$(STEAM_SSFN_CONTENTS)" | base64 -d > "$@"
	chmod 777 "$@"

resolve: $(RESOLVE_DIR)
dist-common: $(COMMON_DIST_LICENSE) $(COMMON_DIST_CHANGELOG)
dist-windows: $(WINDOWS_DIST_ZIP) $(WINDOWS_DIST_APP)
dist-macos: $(MACOS_DIST_ZIP) $(MACOS_DIST_DMG) $(MACOS_DIST_APP)
dist-linux: $(LINUX_DIST_ZIP) $(LINUX_DIST_APP)
dist-web: $(WEB_DIST_ZIP)

$(RESOLVE_DIR): $(BOB_PATH)
	java -jar "$(BOB_PATH)" resolve

$(COMMON_DIST_LICENSE): LICENSE.md
	mkdir -p `dirname "$@"`
	cp "$<" "$@"

$(COMMON_DIST_CHANGELOG): CHANGELOG.md
	mkdir -p `dirname "$@"`
	cp "$<" "$@"

$(WINDOWS_DIST_ZIP): $(WINDOWS_DIST_APP)
	(cd "$<" && zip -rX "../$(notdir $@)" .)

$(WINDOWS_DIST_APP): $(WINDOWS_ICON) $(BOB_PATH) $(RCEDIT_PATH)
	mkdir -p "$(WINDOWS_DIST_DIR)"
	java -jar "$(BOB_PATH)" \
		--archive \
		--build-report-html "$(WINDOWS_DIST_DIR)/report.html" \
		--bundle-output "$(WINDOWS_DIST_DIR)" \
		--exclude-build-folder test \
		--texture-compression true \
		--platform x86_64-win32 \
		distclean build bundle
	wine64 "$(RCEDIT_PATH)" "$(WINDOWS_DIST_APP)/$(APP_NAME).exe" --set-file-version "$(APP_VERSION)"
	wine64 "$(RCEDIT_PATH)" "$(WINDOWS_DIST_APP)/$(APP_NAME).exe" --set-product-version "$(APP_VERSION)"

$(WINDOWS_ICON): $(WINDOWS_ICONSET_ALL)
	magick convert $^ -compress jpeg "$@"

$(MACOS_DIST_APP): $(MACOS_DIST_ZIP)
	unzip -o "$<" -d `dirname "$@"`
	xcrun stapler staple "$@"
	xcrun stapler validate "$@"
	spctl -v --assess --type exec "$@"

$(MACOS_DIST_ZIP): $(MACOS_DIST_DMG)
	hdiutil attach "$<"
	/usr/bin/ditto -c -k -rsrc --sequesterRsrc --keepParent "/Volumes/$(APP_NAME)/$(APP_NAME).app" "$@"
	hdiutil detach "/Volumes/$(APP_NAME)"

$(MACOS_DIST_DMG): $(MACOS_UNNOTARIZED_DIST_APP)
	mkdir -p "$(MACOS_DIST_DIR)"
	npx create-dmg --overwrite "$<" "$(MACOS_DIST_DIR)"
	mv "$(MACOS_DIST_DIR)"/*.dmg "$@"
	xcrun notarytool submit "$@" --keychain-profile "AC_PASSWORD" --wait
	xcrun stapler staple "$@"
	xcrun stapler validate "$@"
	spctl -v --assess --type install "$@"

$(MACOS_UNNOTARIZED_DIST_APP): $(MACOS_ICON) $(BOB_PATH)
	mkdir -p "$(MACOS_UNNOTARIZED_DIST_DIR)"
	java -jar "$(BOB_PATH)" \
		--archive \
		--build-report-html "$(MACOS_UNNOTARIZED_DIST_DIR)/report.html" \
		--bundle-output "$(MACOS_UNNOTARIZED_DIST_DIR)" \
		--exclude-build-folder test \
		--texture-compression true \
		--platform x86_64-macos \
		distclean build bundle
	/usr/bin/codesign -vvv --force --deep --timestamp --options runtime --entitlements "$(MACOS_ASSETS_DIR)/Entitlements.plist" --sign $(MACOS_TEAM_ID) "$@"
	/usr/bin/codesign -vvvv --deep "$@"

$(MACOS_ICON): $(MACOS_ICONSET_ALL)
	iconutil -c icns -o "$@" "$(MACOS_ICONSET)"

$(LINUX_DIST_ZIP): $(LINUX_DIST_APP)
	(cd "$<" && zip -rX "../$(notdir $@)" .)

$(LINUX_DIST_APP): $(BOB_PATH)
	mkdir -p "$(LINUX_DIST_DIR)"
	java -jar "$(BOB_PATH)" \
		--archive \
		--build-report-html "$(LINUX_DIST_DIR)/report.html" \
		--bundle-output "$(LINUX_DIST_DIR)" \
		--exclude-build-folder test \
		--texture-compression true \
		--platform x86_64-linux \
		distclean build bundle

$(WEB_DIST_ZIP): $(WEB_DIST_APP)
	(cd "$<" && zip -rX "../$(notdir $@)" .)

$(WEB_DIST_APP): $(BOB_PATH)
	mkdir -p "$(WEB_DIST_DIR)"
	java -jar "$(BOB_PATH)" \
		--archive \
		--build-report-html "$(WEB_DIST_DIR)/report.html" \
		--bundle-output "$(WEB_DIST_DIR)" \
		--exclude-build-folder test \
		--texture-compression true \
		--platform js-web \
		distclean build bundle

$(BOB_PATH):
	curl -L -o /tmp/bob.jar "https://github.com/defold/defold/releases/download/$(BOB_VERSION)/bob.jar"
	echo "$(BOB_SHA256) /tmp/bob.jar" | sha256sum --check
	mkdir -p `dirname "$(BOB_PATH)"`
	mv /tmp/bob.jar "$(BOB_PATH)"
	java -jar "$(BOB_PATH)" --version

$(RCEDIT_PATH):
	curl -L -o /tmp/rcedit.exe "https://github.com/electron/rcedit/releases/download/v$(RCEDIT_VERSION)/rcedit-x64.exe"
	echo "$(RCEDIT_SHA256) /tmp/rcedit.exe" | sha256sum --check
	mkdir -p `dirname "$(RCEDIT_PATH)"`
	mv /tmp/rcedit.exe "$(RCEDIT_PATH)"
	wine64 "$(RCEDIT_PATH)" --help

$(BUTLER_PATH):
	curl -L -o /tmp/butler.zip "https://broth.itch.ovh/butler/darwin-amd64/$(BUTLER_VERSION)/archive/default"
	echo "$(BUTLER_SHA256) /tmp/butler.zip" | sha256sum --check
	mkdir -p `dirname "$(BUTLER_PATH)"`
	unzip /tmp/butler.zip -d `dirname "$(BUTLER_PATH)"`
	rm /tmp/butler.zip
	"$(BUTLER_PATH)" --version

$(STEAMCMD_PATH):
	curl -L -o /tmp/steamcmd.tar.gz https://steamcdn-a.akamaihd.net/client/installer/steamcmd_osx.tar.gz
	echo "$(STEAMCMD_SHA256) /tmp/steamcmd.tar.gz" | sha256sum --check
	mkdir -p `dirname $(STEAMCMD_PATH)`
	tar zxvf /tmp/steamcmd.tar.gz -C `dirname $(STEAMCMD_PATH)`
	rm /tmp/steamcmd.tar.gz
	while ! $(STEAMCMD_PATH) +help +quit; do sleep 1; done
