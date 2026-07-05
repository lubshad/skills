#!/bin/bash

# Extract current version and build number from pubspec.yaml
version_line=$(grep -o 'version: [0-9]*\.[0-9]*\.[0-9]*+[0-9]*' pubspec.yaml)
current_version=$(echo $version_line | grep -o '[0-9]*\.[0-9]*\.[0-9]*')
current_build=$(echo $version_line | grep -o '+[0-9]*' | tr -d '+')

echo "Current version: $current_version+$current_build"
echo ""
echo "What type of update is this?"
echo "1) Major update (1.0.1 → 2.0.0) - Breaking changes"
echo "2) Feature update (1.0.1 → 1.1.0) - New features"
echo "3) Bug fix (1.0.1 → 1.0.2) - Bug fixes"
echo "4) Build only (1.0.1+2 → 1.0.1+3) - Same version, new build"
echo ""
read -p "Enter your choice (1-4): " choice

# Parse version numbers
IFS='.' read -r major minor patch <<< "$current_version"

case $choice in
    1)
        # Major update: increment major, reset minor and patch
        new_major=$((major + 1))
        new_version="$new_major.0.0"
        new_build=$((current_build + 1))
        ;;
    2)
        # Feature update: increment minor, reset patch
        new_minor=$((minor + 1))
        new_version="$major.$new_minor.0"
        new_build=$((current_build + 1))
        ;;
    3)
        # Bug fix: increment patch
        new_patch=$((patch + 1))
        new_version="$major.$minor.$new_patch"
        new_build=$((current_build + 1))
        ;;
    4)
        # Build only: keep same version, increment build
        new_version="$current_version"
        new_build=$((current_build + 1))
        ;;
    *)
        echo "Invalid choice. Exiting."
        exit 1
        ;;
esac

# Update pubspec.yaml with new version
sed -i '' "s/version: [0-9]*\.[0-9]*\.[0-9]*+[0-9]*/version: $new_version+$new_build/" pubspec.yaml

echo "Updated version to $new_version+$new_build"
