#!/usr/bin/env bash
# Builds a Debian/Ubuntu (Xubuntu) installable .deb from the Linux release
# bundle. Run from the repository root (or let the script cd itself):
#   ./packaging/build_deb.sh
# Produces: build/gbp-manager_<version>_amd64.deb
set -euo pipefail

cd "$(dirname "$0")/.."

PKG_NAME="gbp-manager"
VERSION="$(grep -m1 '^version:' pubspec.yaml | awk '{print $2}' | cut -d+ -f1)"
ARCH="amd64"
BUNDLE="build/linux/x64/release/bundle"
STAGE="build/deb/${PKG_NAME}_${VERSION}_${ARCH}"
OUT="build/${PKG_NAME}_${VERSION}_${ARCH}.deb"

# Always rebuild so the package never ships a stale bundle
# (set SKIP_FLUTTER_BUILD=1 to package an existing build as-is).
if [[ "${SKIP_FLUTTER_BUILD:-0}" != "1" || ! -d "$BUNDLE" ]]; then
  flutter build linux --release
fi

rm -rf "$STAGE"
mkdir -p \
  "$STAGE/DEBIAN" \
  "$STAGE/opt/$PKG_NAME" \
  "$STAGE/usr/bin" \
  "$STAGE/usr/share/applications" \
  "$STAGE/usr/share/icons/hicolor/256x256/apps"

cp -r "$BUNDLE"/. "$STAGE/opt/$PKG_NAME/"
cp packaging/icon_256.png "$STAGE/usr/share/icons/hicolor/256x256/apps/$PKG_NAME.png"
ln -s "/opt/$PKG_NAME/google_business_profile_manager" "$STAGE/usr/bin/$PKG_NAME"

cat > "$STAGE/usr/share/applications/$PKG_NAME.desktop" <<EOF
[Desktop Entry]
Name=Business Profile Manager
Comment=Local-first, AI-augmented Google Business Profile manager
Exec=/opt/$PKG_NAME/google_business_profile_manager
Icon=$PKG_NAME
Terminal=false
Type=Application
Categories=Office;Network;
Keywords=google;business;profile;gbp;ai;catalog;
StartupWMClass=google_business_profile_manager
EOF

INSTALLED_SIZE=$(du -sk "$STAGE" --exclude=DEBIAN | cut -f1)

cat > "$STAGE/DEBIAN/control" <<EOF
Package: $PKG_NAME
Version: $VERSION
Section: office
Priority: optional
Architecture: $ARCH
Installed-Size: $INSTALLED_SIZE
Depends: libgtk-3-0, libglib2.0-0, libstdc++6, libc6
Maintainer: Johannes Neugschwentner <johannes.neugschwentner@gmail.com>
Homepage: https://github.com/johannes/googlebusinessmanager
Description: AI-augmented Google Business Profile manager
 Local-first Flutter desktop app to manage business.google.com listings:
 multi-business workspaces, voice + vision AI catalog drafting (bring your
 own free Gemini or OpenRouter/Qwen key), OpenStreetMap location picking,
 WhatsApp link helper, staging catalog with verified-price guardrails and
 direct publishing through your own Google Cloud OAuth credentials.
EOF

dpkg-deb --build --root-owner-group "$STAGE" "$OUT"
echo
echo "Built: $OUT"
dpkg-deb --info "$OUT" | sed -n '1,12p'
