#!/usr/bin/env bash
# Bumps the version in pubspec.yaml (semver + build number).
#   ./packaging/bump_version.sh [patch|minor|major]   (default: patch)
# The build number after "+" always increments by 1.
# Prints the new version on stdout (last line) so callers can capture it.
set -euo pipefail

cd "$(dirname "$0")/.."

PART="${1:-patch}"

CURRENT="$(grep -m1 '^version:' pubspec.yaml | awk '{print $2}')"
SEMVER="${CURRENT%%+*}"
BUILD="${CURRENT##*+}"
[[ "$BUILD" == "$CURRENT" ]] && BUILD=0

IFS='.' read -r MAJOR MINOR PATCH <<< "$SEMVER"

case "$PART" in
  major) MAJOR=$((MAJOR + 1)); MINOR=0; PATCH=0 ;;
  minor) MINOR=$((MINOR + 1)); PATCH=0 ;;
  patch) PATCH=$((PATCH + 1)) ;;
  *) echo "Usage: $0 [patch|minor|major]" >&2; exit 1 ;;
esac

NEW_VERSION="${MAJOR}.${MINOR}.${PATCH}+$((BUILD + 1))"

sed -i "s/^version: .*/version: ${NEW_VERSION}/" pubspec.yaml

echo "Version: ${CURRENT} -> ${NEW_VERSION}" >&2
echo "${NEW_VERSION}"
