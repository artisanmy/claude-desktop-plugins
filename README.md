# Claude Desktop Plugins — Artisan Private Marketplace

Internal plugin marketplace for Artisan. No more sharing `.plugin` files over Teams or email — add the marketplace once and install (and update) plugins directly inside Claude.

## Adding the Marketplace to Claude Desktop

Add this repo as a marketplace one time, using Claude Desktop's UI (no terminal
needed). After that, every plugin in it is installable from inside Claude.

1. Open the **Customize** menu in the left sidebar, then open the **Plugins** tab.
2. In the **Personal plugins** section, click the **"+"** button and select **Add marketplace**.
3. Choose **Add from a repository** and paste this repo:
   `https://github.com/artisanmy/claude-desktop-plugins` (or the git URL ending in `.git`).
4. Back in the **Plugins** tab, click **Browse plugins**, find **Artisan ES Reader**, and click **Install**.

> Prefer a manual file? You can still download a `.plugin` from
> [Releases](https://github.com/artisanmy/claude-desktop-plugins/releases) and
> use **Upload a custom plugin** from the same Plugins tab.

### Updating to a new version

Internal marketplaces don't always refresh automatically, so a newly released
version may not appear right away. To force it: in the **Plugins** tab, open the
marketplace's menu (the **⋯** button on the Artisan marketplace entry) and
re-sync it, then re-install the plugin from **Browse plugins** to pick up the
new version. If a re-sync option isn't shown, removing and re-adding the
marketplace forces a fresh pull.

> Using Claude Code (terminal) instead of Desktop? The equivalent commands are
> `/plugin marketplace add artisanmy/claude-desktop-plugins`,
> `/plugin marketplace update artisan-plugins`, and
> `/plugin install artisan-es-reader-plugin`. These are CLI-only and do **not**
> work in the Desktop chat box.

## Available Plugins

See [`registry.json`](./registry.json) for the full list, or browse the [`plugins/`](./plugins) folder.

---

## Developer Guide

### Releasing a new version

Two scripts handle a release. Run both from the repo root in PowerShell, then
refresh the marketplace in Claude Desktop.

```powershell
powershell -ExecutionPolicy Bypass -File scripts\bump-version.ps1 -Version 0.3.0
powershell -ExecutionPolicy Bypass -File scripts\republish-release.ps1 -Version 0.3.0
```

**`bump-version.ps1`** sets the version consistently across all manifest files
in one step, so they never drift apart:

- `plugins/<id>/.claude-plugin/plugin.json` — the version Claude Desktop reads (source of truth)
- `.claude-plugin/marketplace.json` — the marketplace entry
- `plugins/<id>/plugin.json` — the custom root manifest
- `registry.json` — the entry version, the `releaseUrl`, and the `updated` date

It rejects non-semver input and leaves the top-level `registry.json` format
version untouched. Run `git diff` afterward to review.

**`republish-release.ps1`** publishes that version: it clears any stale git
locks, verifies the manifest version matches the version you're releasing,
commits, pushes `main`, then creates and pushes the tag
`<id>/v<version>`. Pushing the tag triggers `.github/workflows/release.yml`,
which builds the `.plugin` and uploads it to a GitHub Release.

After the GitHub Action finishes, refresh in Claude Desktop (Customize →
Plugins → re-sync the Artisan marketplace via its **⋯** menu, then re-install
the plugin from **Browse plugins**). See
[Updating to a new version](#updating-to-a-new-version) above.

> Both scripts default to `artisan-es-reader-plugin`. Target a different plugin
> with `-PluginId <plugin-id>`.

**The one rule:** bump the version *before* tagging, and never reuse a version
number. The release workflow enforces this — it fails the build if the tag
version doesn't match the manifest — which is what prevents "Claude Desktop
won't detect the new version" problems.

### Adding a new plugin

See [`docs/adding-a-plugin.md`](./docs/adding-a-plugin.md) for the full guide.

**Quick summary:**

1. Add your plugin under `plugins/<your-plugin-id>/`
2. Write a `plugin.json` manifest (see [`schema/plugin-manifest.schema.json`](./schema/plugin-manifest.schema.json)) and a `.claude-plugin/plugin.json`
3. Register it in `registry.json` and `.claude-plugin/marketplace.json`
4. Open a PR — CI validates your manifest automatically
5. Release with the scripts above

### Repo Structure

```
claude-desktop-plugins/
├── .claude-plugin/
│   └── marketplace.json          # Marketplace index Claude Desktop reads
├── registry.json                 # Master plugin index
├── plugins/
│   └── <plugin-id>/
│       ├── .claude-plugin/
│       │   └── plugin.json        # Version Claude Desktop reads
│       ├── plugin.json            # Custom root manifest
│       ├── README.md
│       └── skills/
│           └── <skill>/
│               └── SKILL.md
├── schema/
│   ├── registry.schema.json
│   └── plugin-manifest.schema.json
├── scripts/
│   ├── bump-version.ps1          # Set version across all manifests
│   ├── republish-release.ps1     # Commit, tag & trigger a release
│   ├── build-plugin.sh           # Build a .plugin zip locally
│   └── validate-registry.js      # Validate registry & manifests
├── docs/
│   └── adding-a-plugin.md
└── .github/workflows/
    ├── validate.yml               # CI: validate on every PR
    └── release.yml                # CI: build & release on tag push (version-guarded)
```
