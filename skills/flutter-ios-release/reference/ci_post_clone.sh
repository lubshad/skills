#!/bin/sh

set -e
set -x

echo "===== CI STEP 1: Move to repository root ====="
cd "$CI_PRIMARY_REPOSITORY_PATH"

echo "===== CI STEP 2: Install Flutter ====="
if [ ! -d "$HOME/flutter" ]; then
  git clone https://github.com/flutter/flutter.git --depth 1 -b stable "$HOME/flutter"
fi
export PATH="$PATH:$HOME/flutter/bin"

echo "===== CI STEP 3: Check Flutter Version ====="
flutter --version

echo "===== CI STEP 4: Precache iOS artifacts ====="
flutter precache --ios

echo "===== CI STEP 5: Install Flutter dependencies ====="
flutter pub get

echo "===== CI STEP 6: Configure iOS Flutter target ====="
# Use --config-only to set the target for Xcode without doing a full build
flutter build ios \
  --release \
  --config-only \
  --no-codesign \
  -t lib/main_prod.dart

echo "===== CI STEP 7: Install CocoaPods only if used ====="
# Flutter plugins use SPM by default in recent versions.
# Only run CocoaPods if a Podfile exists.
if [ -f ios/Podfile ]; then
  cd ios
  pod install --repo-update
  cd ..
else
  echo "No ios/Podfile found; using Swift Package Manager."
fi

echo "===== CI SUCCESS: Post-clone setup completed ====="

exit 0