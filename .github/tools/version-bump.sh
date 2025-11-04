#!/bin/bash
set -e

BUMP_TYPE="${1:-patch}"

if [[ ! "$BUMP_TYPE" =~ ^(major|minor|patch|build)$ ]]; then
  echo "Usage: $0 [major|minor|patch|build]"
  exit 1
fi

CURRENT=$(grep '^version=' module.prop | cut -d'=' -f2 | tr -d 'v')
IFS='.' read -r MAJOR MINOR PATCH BUILD <<< "$CURRENT"

case $BUMP_TYPE in
  major) MAJOR=$((MAJOR + 1)); MINOR=0; PATCH=0; BUILD=0 ;;
  minor) MINOR=$((MINOR + 1)); PATCH=0; BUILD=0 ;;
  patch) PATCH=$((PATCH + 1)); BUILD=0 ;;
  build) BUILD=$((BUILD + 1)) ;;
esac

NEW_VERSION="v${MAJOR}.${MINOR}.${PATCH}.${BUILD}"
NEW_VERSION_CODE=$(printf "%02d%02d%02d%02d" "$MAJOR" "$MINOR" "$PATCH" "$BUILD")

sed -i "s/^version=.*/version=$NEW_VERSION/" module.prop
sed -i "s/^versionCode=.*/versionCode=$NEW_VERSION_CODE/" module.prop

jq --arg v "$NEW_VERSION" --arg vc "$NEW_VERSION_CODE" \
  '.version = $v | .versionCode = $vc | .zipUrl = "https://github.com/anasfanani/Magisk-Tailscaled/releases/download/\($v)/Magisk-Tailscaled-\($v).zip"' \
  update.json > update.json.tmp && mv update.json.tmp update.json

echo "Bumped $BUMP_TYPE: v$CURRENT → $NEW_VERSION (code: $NEW_VERSION_CODE)"
