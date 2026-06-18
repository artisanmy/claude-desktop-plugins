# Claude Desktop Plugins — Artisan Private Marketplace

Internal plugin registry for Artisan. No more sharing `.plugin` files over Teams or email — install directly from GitHub Releases.

## Installing a Plugin

1. Go to [Releases](https://github.com/artisanmy/claude-desktop-plugins/releases)
2. Download the `.plugin` file for the plugin you want
3. In Claude Desktop: **Settings → Capabilities → Install Plugin** and drag in the file

## Available Plugins

See [`registry.json`](./registry.json) for the full list, or browse the [`plugins/`](./plugins) folder.

## Contributing / Adding a Plugin

See [`docs/adding-a-plugin.md`](./docs/adding-a-plugin.md) for the full guide.

**Quick summary:**
1. Add your plugin under `plugins/<your-plugin-id>/`
2. Write a `plugin.json` manifest (see [`schema/plugin-manifest.schema.json`](./schema/plugin-manifest.schema.json))
3. Register it in `registry.json`
4. Open a PR — CI validates your manifest automatically
5. Tag `your-plugin-id/v1.0.0` to trigger an automated build & release

## Repo Structure

```
claude-desktop-plugins/
├── registry.json                  # Master plugin index
├── plugins/
│   └── <plugin-id>/
│       ├── plugin.json            # Plugin manifest
│       ├── README.md
│       └── skills/
│           └── <skill>/
│               └── SKILL.md
├── schema/
│   ├── registry.schema.json
│   └── plugin-manifest.schema.json
├── scripts/
│   ├── build-plugin.sh            # Build a .plugin zip locally
│   └── validate-registry.js      # Validate registry & manifests
├── docs/
│   └── adding-a-plugin.md
└── .github/workflows/
    ├── validate.yml               # CI: validate on every PR
    └── release.yml                # CI: build & release on tag push
```
