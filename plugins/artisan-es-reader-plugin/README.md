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

### 3. Configure the MCP server

Open `claude_desktop_config.json`:

```
Windows:  %APPDATA%\Claude\claude_desktop_config.json
macOS:    ~/Library/Application Support/Claude/claude_desktop_config.json
```

Add the entry inside `"mcpServers": { }`:

```json
{
  "mcpServers": {
    "elasticsearch-logs": {
      "command": "uvx",
      "args": ["artisan-es-reader-plugin@latest", "artisan-es-reader-plugin"],
      "env": {
        "ES_HOST": "localhost",
        "ES_PORT": "9200",
        "ES_USERNAME": "your-es-username",
        "ES_PASSWORD": "your-es-password",
        "ES_USE_SSL": "true",
        "ES_VERIFY_CERTS": "false",
        "SSH_HOST": "your-bastion-ip",
        "SSH_PORT": "22",
        "SSH_USERNAME": "ubuntu",
        "SSH_PEM_FILE": "C:\\Users\\your-name\\path\\to\\key.pem",
        "SSH_REMOTE_ES_HOST": "localhost",
        "SSH_REMOTE_ES_PORT": "9200",
        "SSH_LOCAL_PORT": "0"
      }
    }
  }
}
```

Each team member only needs to fill in these personal values:

| Variable | Description |
|---|---|
| `ES_USERNAME` | Elasticsearch username |
| `ES_PASSWORD` | Elasticsearch password |
| `SSH_HOST` | Bastion / jump host IP or hostname |
| `SSH_PEM_FILE` | Absolute path to your local PEM key file |

> **Windows paths** must use double backslashes in JSON: `C:\\Users\\your-name\\key.pem`

### 4. Restart Cowork

The SSH tunnel starts automatically on first tool use.

---

## Notes

- `ES_HOST` is only used for direct connect