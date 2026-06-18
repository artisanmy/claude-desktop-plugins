# Adding a Plugin to the Marketplace

## 1. Create your plugin directory

```
plugins/
└── your-plugin-id/
    ├── plugin.json          # Required manifest
    ├── README.md            # Optional but recommended
    └── skills/
        └── your-skill/
            └── SKILL.md
```

Plugin IDs must be lowercase, hyphen-separated (e.g. `jira-helper`, `slack-digest`).

## 2. Write your plugin.json

```json
{
  "$schema": "../../schema/plugin-manifest.schema.json",
  "id": "your-plugin-id",
  "name": "Your Plugin Name",
  "version": "1.0.0",
  "description": "One-sentence description shown in the marketplace.",
  "author": "Your Name",
  "category": "productivity",
  "tags": ["jira", "project-management"],
  "skills": [
    {
      "name": "your-skill",
      "description": "What this skill does.",
      "path": "skills/your-skill"
    }
  ]
}
```

## 3. Register in registry.json

Add an entry to the `plugins` array:

```json
{
  "id": "your-plugin-id",
  "name": "Your Plugin Name",
  "description": "One-sentence description.",
  "version": "1.0.0",
  "author": "Your Name",
  "category": "productivity",
  "tags": ["tag1", "tag2"],
  "path": "plugins/your-plugin-id",
  "releaseUrl": "https://github.com/artisanmy/claude-desktop-plugins/releases/download/your-plugin-id-v1.0.0/your-plugin-id.plugin"
}
```

## 4. Open a Pull Request

Push your branch and open a PR against `main`. The `validate` CI workflow checks your manifest automatically.

## 5. Release

Tag `your-plugin-id/v1.0.0` — the `release` CI workflow builds the `.plugin` file and attaches it to a GitHub Release automatically.

## Installing a plugin

Download the `.plugin` file from [Releases](https://github.com/artisanmy/claude-desktop-plugins/releases) and drag it into Claude Desktop → Settings → Capabilities → Install Plugin.
