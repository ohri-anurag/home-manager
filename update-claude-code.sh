#!/usr/bin/env bash
# Weekly update: bump claude-code in home.nix, update the flake, switch, then commit and push with jj.
set -euo pipefail

cd "$(dirname "$0")"

BASE="https://storage.googleapis.com/claude-code-dist-86c565f3-f756-42ad-8dfa-d59b1c096819/claude-code-releases"

# 1. Fetch the latest version
latest=$(curl -fsS "$BASE/latest" | tr -d '[:space:]')
[[ "$latest" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || { echo "Unexpected version: $latest" >&2; exit 1; }

# Only the claude-code block (first match) is edited.
current=$(rg -m1 -o 'version = "([0-9.]+)"' -r '$1' home.nix)
echo "claude-code: current=$current latest=$latest"

if [[ "$latest" != "$current" ]]; then
  # 2. Replace the version
  sed -i "0,/version = \"$current\"/s//version = \"$latest\"/" home.nix

  # 3. Recalculate the sha256
  hash=$(nix-prefetch-url "$BASE/$latest/linux-x64/claude")
  sed -i "0,/sha256 = \"sha256:[a-z0-9]*\"/s//sha256 = \"sha256:$hash\"/" home.nix
fi

# 4. Update the flake
nix flake update

# 5. Switch
home-manager switch

# 6. On success: commit, push, and remove old generations
jj describe -m "Update claude and flake.lock"
jj bookmark set main -r @
jj git push --bookmark main
jj new

home-manager expire-generations now
nix-collect-garbage -d
