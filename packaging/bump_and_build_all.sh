#!/usr/bin/env bash
# Bumps the version (patch by default) and builds every distributable this
# host can produce, collecting the results in dist/<version>/:
#
#   Linux host   : .deb (Xubuntu/Debian), Android APK + App Bundle, web build
#   macOS host   : macOS .app (zipped), iOS .ipa (or unsigned build), Android, web
#   Windows host : Windows release folder (zipped), Android, web
#
# Flutter cannot cross-compile: macOS/iOS packages require a Mac with Xcode,
# Windows packages require a Windows machine. Run this same script on each
# platform (after committing the version bump) to fill in the missing targets.
#
#   ./packaging/bump_and_build_all.sh [patch|minor|major]
#   SKIP_BUMP=1 ./packaging/bump_and_build_all.sh   # rebuild current version
set -euo pipefail

cd "$(dirname "$0")/.."

if [[ "${SKIP_BUMP:-0}" != "1" ]]; then
  ./packaging/bump_version.sh "${1:-patch}" >/dev/null
fi
VERSION="$(grep -m1 '^version:' pubspec.yaml | awk '{print $2}' | cut -d+ -f1)"
DIST="dist/${VERSION}"
mkdir -p "$DIST"

HOST="$(uname -s)"
BUILT=()
SKIPPED=()

note()  { printf '\n\033[1m==> %s\033[0m\n' "$*"; }
skip()  { SKIPPED+=("$1 — $2"); printf '\n\033[33mSKIP %s: %s\033[0m\n' "$1" "$2"; }

flutter pub get

# ---------- Linux desktop (.deb) ------------------------------------------
if [[ "$HOST" == "Linux" ]]; then
  note "Linux .deb"
  ./packaging/build_deb.sh
  cp "build/gbp-manager_${VERSION}_amd64.deb" "$DIST/"
  BUILT+=("Linux deb: $DIST/gbp-manager_${VERSION}_amd64.deb")
else
  skip "Linux .deb" "requires a Linux host"
fi

# ---------- macOS desktop ---------------------------------------------------
if [[ "$HOST" == "Darwin" ]]; then
  note "macOS desktop"
  flutter build macos --release
  APP="$(ls -d build/macos/Build/Products/Release/*.app | head -1)"
  ditto -c -k --keepParent "$APP" "$DIST/gbp-manager_${VERSION}_macos.zip"
  BUILT+=("macOS app: $DIST/gbp-manager_${VERSION}_macos.zip")
else
  skip "macOS desktop" "requires macOS + Xcode (run this script on a Mac)"
fi

# ---------- Windows desktop -------------------------------------------------
if [[ "$HOST" == MINGW* || "$HOST" == MSYS* || "$HOST" == CYGWIN* || "${OS:-}" == "Windows_NT" ]]; then
  note "Windows desktop"
  flutter build windows --release
  RUNNER="build/windows/x64/runner/Release"
  (cd "$RUNNER" && powershell.exe -NoProfile -Command \
    "Compress-Archive -Force -Path * -DestinationPath '$(pwd)/../../../../../$DIST/gbp-manager_${VERSION}_windows.zip'") \
    || (cd "$RUNNER" && zip -r "../../../../../$DIST/gbp-manager_${VERSION}_windows.zip" .)
  BUILT+=("Windows zip: $DIST/gbp-manager_${VERSION}_windows.zip")
else
  skip "Windows desktop" "requires a Windows host (run this script there)"
fi

# ---------- Android (APK + Play Store bundle) -------------------------------
if flutter doctor 2>/dev/null | grep -qi 'Android toolchain.*✓\|Android toolchain.*\[√\]'; then
  note "Android APK + App Bundle"
  flutter build apk --release
  flutter build appbundle --release
  cp build/app/outputs/flutter-apk/app-release.apk "$DIST/gbp-manager_${VERSION}_android.apk"
  cp build/app/outputs/bundle/release/app-release.aab "$DIST/gbp-manager_${VERSION}_android.aab"
  BUILT+=("Android APK: $DIST/gbp-manager_${VERSION}_android.apk")
  BUILT+=("Android AAB (Play Store): $DIST/gbp-manager_${VERSION}_android.aab")
else
  skip "Android" "Android SDK not detected by 'flutter doctor'"
fi

# ---------- iOS --------------------------------------------------------------
if [[ "$HOST" == "Darwin" ]]; then
  note "iOS"
  if flutter build ipa --release; then
    IPA="$(ls build/ios/ipa/*.ipa 2>/dev/null | head -1 || true)"
    if [[ -n "$IPA" ]]; then
      cp "$IPA" "$DIST/gbp-manager_${VERSION}_ios.ipa"
      BUILT+=("iOS IPA: $DIST/gbp-manager_${VERSION}_ios.ipa")
    fi
  else
    echo "Signed IPA failed — building unsigned .app for manual signing."
    flutter build ios --release --no-codesign
    ditto -c -k --keepParent build/ios/iphoneos/Runner.app "$DIST/gbp-manager_${VERSION}_ios_unsigned.zip"
    BUILT+=("iOS unsigned app: $DIST/gbp-manager_${VERSION}_ios_unsigned.zip (sign in Xcode)")
  fi
else
  skip "iOS" "requires macOS + Xcode (run this script on a Mac)"
fi

# ---------- Web ---------------------------------------------------------------
note "Web"
flutter build web --release
tar -czf "$DIST/gbp-manager_${VERSION}_web.tar.gz" -C build/web .
BUILT+=("Web bundle: $DIST/gbp-manager_${VERSION}_web.tar.gz (unpack onto any static host)")

# ---------- Summary ------------------------------------------------------------
printf '\n\033[1m================ Release %s ================\033[0m\n' "$VERSION"
printf 'Built:\n'
for b in "${BUILT[@]}"; do printf '  ✓ %s\n' "$b"; done
if [[ ${#SKIPPED[@]} -gt 0 ]]; then
  printf 'Skipped on this host:\n'
  for s in "${SKIPPED[@]}"; do printf '  - %s\n' "$s"; done
fi
