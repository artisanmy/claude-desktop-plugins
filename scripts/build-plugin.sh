#!/usr/bin/env bash
# build-plugin.sh — Packages a plugin directory into a .plugin file
# Usage: ./scripts/build-plugin.sh <plugin-id>
# Example: ./scripts/build-plugin.sh example-plugin

set -euo pipefail

PLUGIN_ID="${1:?Usage: $0 <plugin-id>}"
PLUGIN_DIR="plugins/$PLUGIN_ID"
RELEASES_DIR="releases"
OUT="$RELEASES_DIR/$PLUGIN_ID.plugin"

if [ ! -d "$PLUGIN_DIR" ]; then
  echo "ERROR: Plugin directory '$PLUGIN_DIR' not found."
  exit 1
fi

if [ ! -f "$PLUGIN_DIR/plugin.json" ]; then
  echo "ERROR: Missing plugin.json in '$PLUGIN_DIR'."
  exit 1
fi

mkdir -p "$RELEASES_DIR"
(cd "$PLUGIN_DIR" && zip -r "../../$OUT" . --exclude "*.DS_Store" --exclude "__pycache__/*")

echo "Built: $OUT"
