# Elasticsearch MCP Server

Query Elasticsearch logs directly from Claude Cowork — with or without an SSH tunnel.

---

## Installation

### 1. Install the plugin

Get **es-mcp** from the Cowork plugin marketplace and install it.

### 2. Install `uv`

The MCP server runs via `uvx`, which requires `uv` to be installed on your machine:

```powershell
# Windows
powershell -ExecutionPolicy Bypass -c "irm https://astral.sh/uv/install.ps1 | iex"
```

```bash
# macOS / Linux
curl -LsSf https://astral.sh/uv/install.sh | sh
```

### 3. Add the MCP entry to claude_desktop_config.json

Open the file at:

```
Windows:  %APPDATA%\Claude\claude_desktop_config.json
macOS:    ~/Library/Application Support/Claude/claude_desktop_config.json
```

Add this minimal entry inside `"mcpServers": { }`:

```json
{
  "mcpServers": {
    "elasticsearch-logs": {
      "command": "uvx",
      "args": ["artisan-es-reader-plugin@latest", "artisan-es-reader-plugin"]
    }
  }
}
```

That's it — no env vars needed.

### 4. Configure your profiles by asking Claude

Restart Cowork, then just ask Claude to add your Elasticsearch connections:

> "Add a tealive_production profile — bastion is 43.216.208.205, pem is at ~/keys/prod.pem"

Claude will call `configure_profile` and save your settings to `~/.es-mcp/profiles.json`
automatically. You can add as many profiles as you like this way.

### 5. Restart Cowork

The SSH tunnel starts automatically on first tool use.

---

## How profiles are stored

Profiles are saved to `~/.es-mcp/profiles.json` — a plain, human-readable JSON file
you can also edit directly if you prefer:

```json
{
  "default": "tealive_production",
  "profiles": {
    "tealive_production": {
      "es_use_ssl": true,
      "es_verify_certs": false,
      "es_username": "your-username",
      "es_password": "your-password",
      "ssh_host": "43.216.208.205",
      "ssh_username": "ubuntu",
      "ssh_pem_file": "~/keys/prod.pem"
    },
    "baskbear": {
      "es_use_ssl": true,
      "es_verify_certs": false,
      "ssh_host": "baskbear-bastion-ip",
      "ssh_username": "ubuntu",
      "ssh_pem_file": "~/keys/baskbear.pem"
    }
  }
}
```

### Config priority order

The server looks for profiles in this order — the first match wins:

1. `ES_PROFILES` env var (JSON string) — backward compat for existing users
2. `ES_PROFILES_FILE` env var — path to a custom JSON file
3. `~/.es-mcp/profiles.json` — auto-discovered (written by `configure_profile`)
4. Legacy flat `ES_*` / `SSH_*` env vars — single profile named "default"

---

## Selecting a profile

Every tool accepts an optional `profile` argument. Just ask naturally:

> "Search **baskbear** logs for payment errors"
> "Show recent errors in **tealive production**"

Omit it and the `default` profile is used. Call `list_profiles` to see what's
configured, or `connection_info` to inspect a specific one.

---

## Per-profile settings reference

| Key | Description | Default |
|---|---|---|
| `es_host` / `es_port` | ES host/port for **direct** connections (ignored when `ssh_host` is set) | `localhost` / `9200` |
| `es_username` / `es_password` | Elasticsearch credentials | empty |
| `es_use_ssl` | `true` if ES runs HTTPS | `false` |
| `es_verify_certs` | `false` for self-signed certs | `false` |
| `ssh_host` | Bastion / jump host IP or hostname. Leave unset for a direct connection | empty |
| `ssh_port` / `ssh_username` | SSH port / user | `22` / `ubuntu` |
| `ssh_pem_file` | Path to the PEM key on this machine (e.g. `~/keys/prod.pem`) | `~/.ssh/id_rsa` |
| `ssh_remote_es_host` / `ssh_remote_es_port` | ES host/port as seen from the bastion | `localhost` / `9200` |
| `ssh_local_port` | Local tunnel port (`0` = auto) | `0` |

---

## Available tools

All tools accept an optional `profile` argument to choose the Elasticsearch source.

| Tool | What it does |
|---|---|
| `configure_profile` | Add or update a profile — saves to `~/.es-mcp/profiles.json` |
| `delete_profile` | Remove a profile |
| `list_profiles` | List configured profiles and the default |
| `list_indices` | List indices (supports glob pattern) |
| `search_logs` | Full-text search with filters, sort, pagination |
| `get_recent_errors` | Error-level entries from the last N minutes |
| `get_index_mapping` | Field schema for an index |
| `run_aggregation` | Run a custom ES aggregation |
| `connection_info` | Show active connection / tunnel status |

---

## Updating

### For users

Updates are automatic — just restart Cowork and `uvx` will pull the latest version from PyPI.

### For maintainers

1. Make changes to `src/es_mcp/server.py`
2. Bump the version in `pyproject.toml`
3. Build and publish:
   ```bash
   python -m build
   twine upload dist/*
   ```
4. Users get the new version automatically on next Cowork restart — no action needed on their end
