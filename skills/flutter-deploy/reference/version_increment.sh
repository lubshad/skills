#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PUBSPEC_FILE="$SCRIPT_DIR/pubspec.yaml"
BUMP_TYPE="patch"
DRY_RUN=false

show_usage() {
    echo "Usage: $0 [major|minor|patch|build] [--dry-run]"
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        major|minor|patch|build)
            BUMP_TYPE="$1"
            shift
            ;;
        --major|--minor|--patch|--build)
            BUMP_TYPE="${1#--}"
            shift
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        -h|--help)
            show_usage
            exit 0
            ;;
        *)
            echo "Unknown argument: $1" >&2
            show_usage
            exit 1
            ;;
    esac
done

if [ ! -f "$PUBSPEC_FILE" ]; then
    echo "pubspec.yaml not found: $PUBSPEC_FILE" >&2
    exit 1
fi

version_line="$(grep -E '^version: [0-9]+\.[0-9]+\.[0-9]+\+[0-9]+$' "$PUBSPEC_FILE" || true)"
if [ -z "$version_line" ]; then
    echo "Could not find a version line like 'version: 1.0.0+1' in $PUBSPEC_FILE" >&2
    exit 1
fi

current_full="${version_line#version: }"
current_version="${current_full%%+*}"
current_build="${current_full##*+}"
IFS='.' read -r major minor patch <<< "$current_version"

case "$BUMP_TYPE" in
    major) new_version="$((major + 1)).0.0" ;;
    minor) new_version="$major.$((minor + 1)).0" ;;
    patch) new_version="$major.$minor.$((patch + 1))" ;;
    build) new_version="$current_version" ;;
esac

new_full="$new_version+$((current_build + 1))"
if [ "$DRY_RUN" = true ]; then
    echo "$current_full -> $new_full"
    exit 0
fi

sed -i.bak -E \
    "s/^version: [0-9]+\.[0-9]+\.[0-9]+\+[0-9]+$/version: $new_full/" \
    "$PUBSPEC_FILE"
rm -f "$PUBSPEC_FILE.bak"

echo "Updated version: $current_full -> $new_full"
