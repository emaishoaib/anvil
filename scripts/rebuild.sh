#!/bin/bash
#
# Builds Anvil in Release, quits the running Anvil and installs the new build into /Applications,
# replacing the copy there, then reopens it. If the build fails, the running Anvil is left alone.

set -euo pipefail

cd "$(dirname "$0")/.."

PROJECT=Anvil.xcodeproj
SCHEME=Anvil-macOS
DERIVED_DATA=build
LOG=$DERIVED_DATA/rebuild.log
APP=$DERIVED_DATA/Build/Products/Release/Anvil.app
INSTALLED_APP=/Applications/Anvil.app

fail() {
    echo "error: $1" >&2
    exit 1
}

mkdir -p "$DERIVED_DATA"

xcodegen generate

echo "Building Anvil"
xcodebuild build \
    -project "$PROJECT" \
    -scheme "$SCHEME" \
    -configuration Release \
    -derivedDataPath "$DERIVED_DATA" \
    > "$LOG" 2>&1 \
    || fail "Building failed. See $LOG"

echo "Installing Anvil in /Applications and reopening it"
pkill -x Anvil || true
while pgrep -x Anvil > /dev/null; do sleep 0.1; done
rm -rf "$INSTALLED_APP"
ditto "$APP" "$INSTALLED_APP"
open "$INSTALLED_APP"
