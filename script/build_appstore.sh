#!/usr/bin/env bash
# Build the Mac App Store flavor of CLAW AGENT BUILDER.
#
# Differences from script/build_and_run.sh:
#  - Passes -DAPPSTORE_BUILD so the compiler strips the install wizard
#    (Process, NSAppleScript, shell-out code) out of the binary.
#  - Builds release.
#  - Wraps the binary in an .app, signs it with the sandbox entitlements,
#    and optionally wraps the .app in an installer .pkg suitable for
#    App Store Connect / Transporter upload.
#
# Requires:
#  - Xcode command line tools (swift, codesign, productbuild).
#  - A "3rd Party Mac Developer Application" certificate for signing the
#    .app, and a "3rd Party Mac Developer Installer" certificate for the
#    .pkg, both installed in the login keychain.
#  - APP_SIGN_IDENTITY and INSTALLER_SIGN_IDENTITY env vars (or edit the
#    defaults below).
#
# Usage:
#   script/build_appstore.sh              # build + sign .app only
#   script/build_appstore.sh pkg          # build + sign .app + .pkg
#   script/build_appstore.sh unsigned     # build .app without signing (smoke test)

set -euo pipefail

MODE="${1:-app}"

EXECUTABLE_NAME="ClawAgentBuilder"
APP_DISPLAY_NAME="CLAW AGENT BUILDER"
BUNDLE_ID="com.shadowfetch.clawagentbuilder"
MIN_SYSTEM_VERSION="14.0"
APP_VERSION="1.0.0"
APP_BUILD="1"
COPYRIGHT="© 2026 Shadowfetch. All rights reserved."

APP_SIGN_IDENTITY="${APP_SIGN_IDENTITY:-3rd Party Mac Developer Application}"
INSTALLER_SIGN_IDENTITY="${INSTALLER_SIGN_IDENTITY:-3rd Party Mac Developer Installer}"

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DIST_DIR="$ROOT_DIR/dist-appstore"
APP_BUNDLE="$DIST_DIR/$APP_DISPLAY_NAME.app"
APP_CONTENTS="$APP_BUNDLE/Contents"
APP_MACOS="$APP_CONTENTS/MacOS"
APP_RESOURCES="$APP_CONTENTS/Resources"
APP_BINARY="$APP_MACOS/$EXECUTABLE_NAME"
INFO_PLIST="$APP_CONTENTS/Info.plist"
ENTITLEMENTS="$ROOT_DIR/script/ClawAgentBuilder.entitlements"
PKG_PATH="$DIST_DIR/$EXECUTABLE_NAME-appstore.pkg"

if [[ ! -f "$ENTITLEMENTS" ]]; then
  echo "error: entitlements not found at $ENTITLEMENTS" >&2
  exit 1
fi

echo "==> Building release with -DAPPSTORE_BUILD"
swift build -c release -Xswiftc -DAPPSTORE_BUILD
BUILD_BINARY="$(swift build -c release --show-bin-path)/$EXECUTABLE_NAME"

echo "==> Assembling $APP_BUNDLE"
rm -rf "$APP_BUNDLE"
mkdir -p "$APP_MACOS" "$APP_RESOURCES"
cp "$BUILD_BINARY" "$APP_BINARY"
chmod +x "$APP_BINARY"

# If the Assets/ dir has an icon, copy it in.
if [[ -f "$ROOT_DIR/Assets/AppIcon.icns" ]]; then
  cp "$ROOT_DIR/Assets/AppIcon.icns" "$APP_RESOURCES/AppIcon.icns"
fi

cat >"$INFO_PLIST" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleExecutable</key>
  <string>$EXECUTABLE_NAME</string>
  <key>CFBundleIdentifier</key>
  <string>$BUNDLE_ID</string>
  <key>CFBundleName</key>
  <string>$APP_DISPLAY_NAME</string>
  <key>CFBundleDisplayName</key>
  <string>$APP_DISPLAY_NAME</string>
  <key>CFBundleShortVersionString</key>
  <string>$APP_VERSION</string>
  <key>CFBundleVersion</key>
  <string>$APP_BUILD</string>
  <key>CFBundlePackageType</key>
  <string>APPL</string>
  <key>CFBundleInfoDictionaryVersion</key>
  <string>6.0</string>
  <key>CFBundleDevelopmentRegion</key>
  <string>en</string>
  <key>CFBundleIconFile</key>
  <string>AppIcon</string>
  <key>LSMinimumSystemVersion</key>
  <string>$MIN_SYSTEM_VERSION</string>
  <key>LSApplicationCategoryType</key>
  <string>public.app-category.developer-tools</string>
  <key>NSPrincipalClass</key>
  <string>NSApplication</string>
  <key>NSHighResolutionCapable</key>
  <true/>
  <key>NSSupportsAutomaticTermination</key>
  <true/>
  <key>NSSupportsSuddenTermination</key>
  <false/>
  <key>NSHumanReadableCopyright</key>
  <string>$COPYRIGHT</string>
</dict>
</plist>
PLIST

if [[ "$MODE" == "unsigned" ]]; then
  echo "==> Built unsigned bundle at $APP_BUNDLE"
  echo "    (skip signing because MODE=unsigned)"
  exit 0
fi

echo "==> Signing $APP_BUNDLE with \"$APP_SIGN_IDENTITY\""
codesign --force \
  --sign "$APP_SIGN_IDENTITY" \
  --entitlements "$ENTITLEMENTS" \
  --options runtime \
  --timestamp \
  "$APP_BUNDLE"

echo "==> Verifying signature"
codesign --verify --deep --strict --verbose=2 "$APP_BUNDLE"

if [[ "$MODE" == "pkg" ]]; then
  echo "==> Building installer .pkg at $PKG_PATH"
  rm -f "$PKG_PATH"
  productbuild \
    --component "$APP_BUNDLE" /Applications \
    --sign "$INSTALLER_SIGN_IDENTITY" \
    "$PKG_PATH"
  echo "==> Done. Upload $PKG_PATH via Transporter or xcrun altool."
else
  echo "==> Done. Signed bundle at $APP_BUNDLE"
  echo "    Run 'script/build_appstore.sh pkg' to also build the App Store .pkg."
fi
