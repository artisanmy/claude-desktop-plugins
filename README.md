# Claude Desktop Plugins — Artisan Private Marketplace

Internal plugin marketplace for Artisan. Add it once and install (and update) plugins directly inside Claude — no more sharing `.plugin` files over Teams or email.

---

## Adding the Marketplace

1. Open **Customize** in the left sidebar → **Plugins** tab.
2. In **Personal plugins**, click **"+"** → **Add marketplace** → **Add from a repository**.
3. Paste: `https://github.com/artisanmy/claude-desktop-plugins`
4. Click **Browse plugins**, find the plugin you want, and click **Install**.

> Prefer a manual install? Download a `.plugin` from [Releases](https://github.com/artisanmy/claude-desktop-plugins/releases) and use **Upload a custom plugin** from the Plugins tab.

### Updating a plugin

Marketplace updates may not appear automatically. To force a refresh: Plugins tab → **⋯** next to the Artisan marketplace → re-sync → re-install the plugin from **Browse plugins**.

> **Claude Code (terminal):** `/plugin marketplace add artisanmy/claude-desktop-plugins`, then `/plugin install <plugin-id>`.

---

## Available Plugins

| Plugin | Description | Setup Guide |
|---|---|---|
| **Artisan ES Reader** | Query Elasticsearch logs from Claude — SSH tunnel, multi-profile support | [README](./plugins/artisan-es-reader-plugin/README.md) |

---

## Developer Guide

### Releasing a new version

```powershell
powershell -ExecutionPolicy Bypass -File scripts\bump-version.ps1 -Version 0.4.0
powershell -ExecutionPolicy Bypass -File scripts\republish-release.ps1 -Version 0.4.0
```

`bump-version.ps1` updates the version across all manifests (`plugin.json`, `marketplace.json`, `registry.json`). `republish-release.ps1` commits, pushes, and tags — which triggers the GitHub Action that builds and uploads the `.plugin` release asset.

After the Action completes, re-sync the marketplace in Claude Desktop to pick up the new version.

> Both scripts default to `artisan-es-reader-plugin`. Use `-PluginId <id>` for other plugins.

### Adding a new plugin

See [`docs/adding-a-plugin.md`](./docs/adding-a-plugin.md).

### Repo structure

```
claude-desktop-plugins/
├── .claude-plugin/marketplace.json   # Marketplace index
├── registry.json                     # Master plugin list
├── plugins/<plugin-id>/
│   ├── .claude-plugin/plugin.json    # Version Claude Desktop reads
│   ├── plugin.json                   # Root manifest
│   ├── README.md                     # ← Setup guide for that plugin
│   └── skills/<skill>/SKILL.md
├── schema/                           # JSON schemas for manifests
├── scripts/                          # bump-version, republish-release, build-plugin
├── docs/adding-a-plugin.md
└── .github/workflows/                # validate (PR) + release (tag)
```
