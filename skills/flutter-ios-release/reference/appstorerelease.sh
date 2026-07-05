#!/bin/bash
set -e

echo "📦 Building iOS IPA for App Store..."

flutter clean
flutter pub get
flutter build ipa --release -t lib/main_prod.dart

echo "🚀 Opening Xcode archive..."

open -a Xcode build/ios/archive/Runner.xcarchive

echo "✅ Use Xcode Organizer to validate and upload the archive to App Store Connect."
