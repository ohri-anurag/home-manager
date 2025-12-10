#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

# Path to JSON file
VERSIONS_FILE="package-versions.json"
PACKAGE_NAME="$1"

# Extract current version from JSON
CURRENT_VERSION=$(jq -r ".packages.\"${PACKAGE_NAME}\".version" "$VERSIONS_FILE")

echo "Current Claude Code version: $CURRENT_VERSION"

# Read the check command from JSON
CHECK_CMD=$(jq -r ".packages.\"${PACKAGE_NAME}\".check" "$VERSIONS_FILE")

# Execute it to get latest version
LATEST_VERSION=$(eval "$CHECK_CMD")

echo "Latest version on npm: $LATEST_VERSION"

# Determine which version to use
if [ "$CURRENT_VERSION" != "$LATEST_VERSION" ]; then
    echo ""
    echo "New version available! Updating to $LATEST_VERSION..."
    VERSION="$LATEST_VERSION"

    # Update version in JSON using jq
    jq ".packages.\"${PACKAGE_NAME}\".version = \"${VERSION}\"" "$VERSIONS_FILE" > "${VERSIONS_FILE}.tmp"
    mv "${VERSIONS_FILE}.tmp" "$VERSIONS_FILE"

    echo "Updated version to $VERSION in $VERSIONS_FILE"
else
    VERSION="$CURRENT_VERSION"
    echo "Already on latest version"
    exit 0;
fi

# Fetch the correct hash
echo ""
echo "Fetching hash for version $VERSION..."
URL="https://registry.npmjs.org/@anthropic-ai/claude-code/-/claude-code-${VERSION}.tgz"
HASH=$(nix-prefetch-url --unpack --type sha256 "$URL" 2>&1 | tail -n1)

# Convert to SRI hash format (sha256-...)
SRI_HASH=$(nix hash convert --hash-algo sha256 --to sri "$HASH")

echo "Computed hash: $SRI_HASH"

# Update hash in JSON using jq
jq ".packages.\"${PACKAGE_NAME}\".hash = \"${SRI_HASH}\"" "$VERSIONS_FILE" > "${VERSIONS_FILE}.tmp"
mv "${VERSIONS_FILE}.tmp" "$VERSIONS_FILE"

echo "Updated hash in $VERSIONS_FILE"

# Validate JSON structure
if ! jq empty "$VERSIONS_FILE" 2>/dev/null; then
    echo "ERROR: JSON file is malformed!"
    exit 1
fi

echo ""
echo "Running home-manager switch..."

# Run home-manager switch
home-manager switch

git add .
git commit -m "Updated Claude Code"
git push
