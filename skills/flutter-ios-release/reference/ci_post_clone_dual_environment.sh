#!/bin/sh
set -eu

# Xealth two-environment contract; adapt the variable prefix for another app.
: "${CI_PRIMARY_REPOSITORY_PATH:?Missing Xcode Cloud repository path}"
: "${CI_BRANCH:?Missing Xcode Cloud branch}"
: "${XEALTH_APP_ENVIRONMENT:?Set XEALTH_APP_ENVIRONMENT to development or production in the Xcode Cloud workflow}"

case "$XEALTH_APP_ENVIRONMENT" in
  development) FLUTTER_TARGET=lib/main_dev.dart ;;
  production) FLUTTER_TARGET=lib/main_prod.dart ;;
  *) echo "Unsupported XEALTH_APP_ENVIRONMENT: $XEALTH_APP_ENVIRONMENT" >&2; exit 1 ;;
esac

branch="${CI_BRANCH#refs/heads/}"
if [ "$branch" != "$XEALTH_APP_ENVIRONMENT" ]; then
  echo "Xcode Cloud environment $XEALTH_APP_ENVIRONMENT must build its matching branch, not $branch." >&2
  exit 1
fi

cd "$CI_PRIMARY_REPOSITORY_PATH"
test -f "$FLUTTER_TARGET" || { echo "Missing Flutter entrypoint: $FLUTTER_TARGET" >&2; exit 1; }
echo "Configuring iOS for $XEALTH_APP_ENVIRONMENT using $FLUTTER_TARGET"

if [ ! -d "$HOME/flutter" ]; then
  git clone https://github.com/flutter/flutter.git --depth 1 -b stable "$HOME/flutter"
fi
export PATH="$PATH:$HOME/flutter/bin"

flutter precache --ios
flutter pub get
flutter build ios --release --config-only --no-codesign -t "$FLUTTER_TARGET"

if [ -f ios/Podfile ]; then
  cd ios
  pod install --repo-update
fi
