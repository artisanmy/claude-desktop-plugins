# Claude Desktop Plugins

## Bump Version

When the user says **"bump version"** or asks to release a new version, run these steps in order. Ask for the target version if not provided.

**Variables:** `<id>` = plugin id (default: `artisan-es-reader-plugin`), `<ver>` = semver like `0.5.0`.

### Step 1 — Update all manifests and commit

```powershell
powershell -ExecutionPolicy Bypass -File scripts\bump-version.ps1 -Version <ver>
```

Updates 4 manifest files and commits them as `"v<ver>"`:
- `plugins/<id>/.claude-plugin/plugin.json`
- `.claude-plugin/marketplace.json`
- `plugins/<id>/plugin.json`
- `registry.json` (version, releaseUrl, updated date)

### Step 2 — Publish the release

```powershell
powershell -ExecutionPolicy Bypass -File scripts\republish-release.ps1 -Version <ver>
```

This script:
1. Verifies manifest version matches the tag (throws if not)
2. Commits `.github/workflows/release.yml` if changed (skips if clean)
3. Pushes the branch
4. Deletes old local + remote tag, creates and pushes a fresh tag
5. If `gh` CLI available, deletes any stale GitHub release so assets rebuild clean

### Step 4 — Confirm to user

Tell the user the tag `<id>/v<ver>` has been pushed and GitHub Actions is rebuilding `<id>.plugin`. Remind them to run `/plugin marketplace update artisan-plugins` in Claude Desktop once the release finishes.

---

## Project layout

```
scripts/
  bump-version.ps1       # updates all 4 manifests to a new semver
  republish-release.ps1  # commits, pushes branch + tag, triggers CI release
  build-plugin.sh        # zips plugin dir into .plugin file (runs in CI)
  validate-registry.js   # validates registry.json + all plugin.json manifests (runs in CI)
plugins/<id>/
  plugin.json                    # root manifest (schema-validated)
  .claude-plugin/plugin.json     # Claude Desktop source of truth
.claude-plugin/marketplace.json  # marketplace listing
registry.json                    # master plugin registry
schema/                          # JSON schema files used by validate-registry.js
.github/workflows/
  validate.yml   # runs on every push/PR — validates manifests
  release.yml    # triggered by tags like `<id>/v<ver>` — builds and uploads .plugin
```

## CI rules

- The release workflow tag format is `<plugin-id>/v<version>` (e.g. `artisan-es-reader-plugin/v0.5.0`).
- CI will **fail** if the tag version does not match the manifest version — always run `bump-version.ps1` and commit before tagging.
- `validate.yml` runs `node scripts/validate-registry.js` on every push; fix any validation errors before tagging.
