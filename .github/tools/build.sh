#!/bin/bash
set -euox

VERSION="${1:-$(grep '^version=' module.prop | cut -d'=' -f2)}"
DIST_DIR="dist"
BIN_DIR="tailscale/bin"

get_latest_release() {
  curl -s "https://api.github.com/repos/$1/releases/latest" | grep '"browser_download_url"' | grep "$2" | sed 's/.*"browser_download_url": "\([^"]*\)".*/\1/'
}

echo "Building WebUI..."
cd webui
npm install --silent
npm run build --silent
cd ..
echo ""

echo "Building Magisk-Tailscaled ${VERSION}"
echo "========================================"

rm -rf "$DIST_DIR"
mkdir -p "$BIN_DIR" "$DIST_DIR"

echo "Downloading binaries..."
for ARCH in arm arm64; do
  case $ARCH in
    arm) F_ARCH=armv7a ;;
    arm64) F_ARCH=aarch64 ;;
  esac
  
  [ ! -f "$BIN_DIR/tailscaled-$ARCH" ] && {
	echo "- Downloading tailscaled for ${ARCH}..."
	URL=$(get_latest_release "anasfanani/tailscale-android-cli" "tailscale_.*_${ARCH}\.tgz")
	curl -#L "$URL" | tar -xz -C "$BIN_DIR"
	mv "$BIN_DIR/tailscaled" "$BIN_DIR/tailscaled-$ARCH"
  }
  
  [ ! -f "$BIN_DIR/jq-$ARCH" ] && {
	echo "- Downloading jq for ${ARCH}..."
	URL=$(get_latest_release "theshoqanebi/jq-build-for-android" "jq-${F_ARCH}-linux-android")
	curl -#L "$URL" -o "$BIN_DIR/jq-$ARCH"
  }
done

echo ""
EXCLUDE_COMMON=('*.git*' 'dist/*' '*.zip' '*.json' '*.md' '.shellcheckrc' 'webui/*')

echo "Creating zip without binaries..."
zip -9 -r "${DIST_DIR}/Magisk-Tailscaled-${VERSION}.zip" . \
  -x "${EXCLUDE_COMMON[@]}" "${BIN_DIR}/*" >/dev/null

echo "Creating zip with binaries..."
zip -9 -r "${DIST_DIR}/Magisk-Tailscaled-${VERSION}-full.zip" . \
  -x "${EXCLUDE_COMMON[@]}" >/dev/null

# rm -f "$BIN_DIR"/*

echo ""
echo "Build completed successfully!"
echo "========================================"
ls -lh "${DIST_DIR}/"
echo "========================================"
echo "Created: ${DIST_DIR}/Magisk-Tailscaled-${VERSION}.zip (no binaries - downloads on install)"
echo "Created: ${DIST_DIR}/Magisk-Tailscaled-${VERSION}-full.zip (includes all binaries)"

