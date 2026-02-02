#!/usr/bin/env bash
set -e

# Define cache options
# These are from rpi-image/modules/trusted-nix-caches.nix
CACHIX_URL="https://nixos-raspberrypi.cachix.org"
CACHIX_KEY="nixos-raspberrypi.cachix.org-1:4iMO9LXa8BqhU+Rpg6LQKiGa2lsNh/j2oiYLNOQ5sPI="

echo "Building RPi Image with NixOS Raspberry Pi Cache..."
echo "Using Cache: $CACHIX_URL"

# We supply both the custom cache and the standard cache
# --option substituters overrides the list, so we must include the default one.
nix-build ./rpi-image/default.nix \
  --option substituters "$CACHIX_URL https://cache.nixos.org" \
  --option trusted-public-keys "$CACHIX_KEY cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=" \
  "$@"

echo "Build complete. Result linked in ./result"
