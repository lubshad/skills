#!/usr/bin/env bash
set -euo pipefail

# Pre-pass to find --env-file so it can set defaults
for ((i=1; i<=$#; i++)); do
  if [[ "${!i}" == "--env-file" ]]; then
    next=$((i+1))
    ENV_FILE="${!next}"
    if [[ -f "$ENV_FILE" ]]; then
      set -a
      source "$ENV_FILE"
      set +a
    else
      echo -e "\033[0;31m[ERROR]\033[0m Env file not found: $ENV_FILE" >&2
      exit 1
    fi
    break
  fi
done

# Set Defaults (can be overridden by environment variables from --env-file)
PROJECT_DIR="${PROJECT_DIR:-$PWD}"
DOCKERFILE="${DOCKERFILE:-Dockerfile}"
CONTEXT="${CONTEXT:-}"
IMAGE="${IMAGE:-}"
TAG="${TAG:-latest}"
PLATFORM="${PLATFORM:-linux/amd64}"
NO_GIT_SHA="${NO_GIT_SHA:-0}"
NO_PUSH="${NO_PUSH:-0}"
DRY_RUN="${DRY_RUN:-0}"
BUILD_ARGS=()

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1" >&2; }

usage() {
  cat <<EOF
Usage: $0 --image IMAGE [OPTIONS]

Generic Docker build and push helper script.

Required:
  --image IMAGE            Image repository/name, e.g. ghcr.io/org/repo

Options:
  --env-file PATH          Load default values from a dotenv file (e.g. IMAGE, TAG, PLATFORM)
  --project-dir PATH       Project root, default: current directory
  --dockerfile PATH        Dockerfile path relative to project dir, default: Dockerfile
  --context PATH           Build context relative to project dir, default: directory of Dockerfile
  --tag TAG                Image tag, default: latest
  --platform PLATFORM      Docker build platform, default: linux/amd64
  --build-arg KEY=VALUE    Repeatable Docker build arg
  --no-git-sha             Do not add a short git SHA tag
  --no-push                Build only, do not push
  --dry-run                Print commands without running
  -h, --help               Show usage
EOF
}

fail() {
  print_error "$1"
  exit 1
}

require_command() {
  command -v "$1" >/dev/null 2>&1 || fail "Required command not found: $1"
}

# Parse CLI arguments (these override the env-file defaults)
while [[ $# -gt 0 ]]; do
  case "$1" in
    --env-file)
      # Already processed in pre-pass
      shift 2
      ;;
    --project-dir)
      PROJECT_DIR="$2"
      shift 2
      ;;
    --dockerfile)
      DOCKERFILE="$2"
      shift 2
      ;;
    --context)
      CONTEXT="$2"
      shift 2
      ;;
    --image)
      IMAGE="$2"
      shift 2
      ;;
    --tag)
      TAG="$2"
      shift 2
      ;;
    --platform)
      PLATFORM="$2"
      shift 2
      ;;
    --build-arg)
      BUILD_ARGS+=("--build-arg" "$2")
      shift 2
      ;;
    --no-git-sha)
      NO_GIT_SHA=1
      shift
      ;;
    --no-push)
      NO_PUSH=1
      shift
      ;;
    --dry-run)
      DRY_RUN=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      fail "Unknown option: $1"
      ;;
  esac
done

[[ -n "$IMAGE" ]] || fail "--image is required"
[[ -d "$PROJECT_DIR" ]] || fail "Project directory does not exist: $PROJECT_DIR"

# Resolve paths
ABS_PROJECT_DIR="$(cd "$PROJECT_DIR" && pwd)"
ABS_DOCKERFILE="$ABS_PROJECT_DIR/$DOCKERFILE"

[[ -f "$ABS_DOCKERFILE" ]] || fail "Dockerfile does not exist: $ABS_DOCKERFILE"

if [[ -z "$CONTEXT" ]]; then
  ABS_CONTEXT="$(dirname "$ABS_DOCKERFILE")"
else
  ABS_CONTEXT="$ABS_PROJECT_DIR/$CONTEXT"
fi

[[ -d "$ABS_CONTEXT" ]] || fail "Build context directory does not exist: $ABS_CONTEXT"

require_command docker

execute() {
  local cmd=("$@")
  if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "[dry-run] ${cmd[*]}"
  else
    echo "+ ${cmd[*]}"
    "${cmd[@]}"
  fi
}

GIT_SHA=""
if [[ "$NO_GIT_SHA" -eq 0 ]] && command -v git >/dev/null 2>&1; then
  if git -C "$ABS_PROJECT_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    GIT_SHA="$(git -C "$ABS_PROJECT_DIR" rev-parse --short HEAD)"
  fi
fi

PRIMARY_TAG="$IMAGE:$TAG"
print_status "Building image: $PRIMARY_TAG"
print_status "Context: $ABS_CONTEXT"
print_status "Dockerfile: $ABS_DOCKERFILE"

BUILD_CMD=("docker" "build" "-t" "$PRIMARY_TAG" "-f" "$ABS_DOCKERFILE")

if [[ -n "$PLATFORM" ]]; then
  BUILD_CMD+=("--platform" "$PLATFORM")
fi

if [[ ${#BUILD_ARGS[@]} -gt 0 ]]; then
  BUILD_CMD+=("${BUILD_ARGS[@]}")
fi

BUILD_CMD+=("$ABS_CONTEXT")

execute "${BUILD_CMD[@]}"

TAGS_TO_PUSH=("$PRIMARY_TAG")

if [[ -n "$GIT_SHA" ]]; then
  SHA_TAG="$IMAGE:$GIT_SHA"
  print_status "Tagging with git SHA: $SHA_TAG"
  execute docker tag "$PRIMARY_TAG" "$SHA_TAG"
  TAGS_TO_PUSH+=("$SHA_TAG")
fi

if [[ "$NO_PUSH" -eq 0 ]]; then
  print_status "Pushing image tags..."
  for tag in "${TAGS_TO_PUSH[@]}"; do
    execute docker push "$tag"
  done
  print_success "Build and push completed successfully."
else
  print_success "Build completed. Push skipped (--no-push)."
fi
