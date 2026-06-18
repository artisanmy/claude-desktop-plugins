#!/usr/bin/env node
// validate-registry.js — Validates registry.json and all plugin.json manifests
const fs = require("fs");
const path = require("path");

const registry = JSON.parse(fs.readFileSync("registry.json", "utf8"));
let errors = 0;

console.log(`Validating ${registry.plugins.length} plugin(s)...\n`);

for (const plugin of registry.plugins) {
  const manifestPath = path.join(plugin.path, "plugin.json");

  if (!fs.existsSync(manifestPath)) {
    console.error(`  [FAIL] ${plugin.id}: missing ${manifestPath}`);
    errors++;
    continue;
  }

  const manifest = JSON.parse(fs.readFileSync(manifestPath, "utf8"));

  if (manifest.id !== plugin.id) {
    console.error(`  [FAIL] ${plugin.id}: plugin.json id mismatch (got "${manifest.id}")`);
    errors++;
  } else if (manifest.version !== plugin.version) {
    console.error(`  [FAIL] ${plugin.id}: version mismatch — registry says ${plugin.version}, plugin.json says ${manifest.version}`);
    errors++;
  } else {
    console.log(`  [OK]   ${plugin.id} v${plugin.version}`);
  }
}

if (errors > 0) {
  console.error(`\n${errors} error(s) found.`);
  process.exit(1);
} else {
  console.log("\nAll plugins valid.");
}
