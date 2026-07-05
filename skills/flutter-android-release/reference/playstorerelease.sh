#!/bin/bash
set -e

echo "📦 Building Android App Bundle..."

flutter clean
flutter pub get
flutter build appbundle --release -t lib/main.dart

echo "🚀 Uploading to Play Store with fastlane..."

cd android
fastlane release
