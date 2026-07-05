#!/usr/bin/env bash
# Bumps the version (patch by default) and builds the Xubuntu/Debian .deb.
#   ./packaging/bump_and_build_deb.sh [patch|minor|major]
# Produces: build/gbp-manager_<new-version>_amd64.deb
set -euo pipefail

cd "$(dirname "$0")/.."

./packaging/bump_version.sh "${1:-patch}"
./packaging/build_deb.sh
