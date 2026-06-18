# es-mcp Plugin

Query Elasticsearch logs directly from Claude Cowork — with or without an SSH tunnel.

## What this plugin does

- Search logs across any Elasticsearch index
- Fetch recent errors filtered by level and time window
- List available indices
- Inspect field mappings
- Run aggregations (count by field, time histograms, etc.)

## Setup (required before first use)

This plugin connects to Elasticsearch via the `elasticsearch-logs` MCP server.
Each team member must configure their own credentials and connection details.

### 1. Install `uv`

```bash
# macOS / Linux
curl -LsSf https://astral.sh/uv/install.sh | sh

# Windows
powershell -ExecutionPolicy Bypass -c "irm https://astral.sh/uv/install.ps1 | iex"
```

### 2. Configure connection details

After installing the plugin, open its MCP settings and fill in the env vars:

| Variable | Required | Description |
|---|---|---|
| `ES_HOST` | Yes (direct) | Elasticsearch hostname |
| `ES_PORT` | Yes (direct) | Elasticsearch port (default 9200) |
| `ES_USERNAME` | If auth enabled | Basic auth username |
| `ES_PASSWORD` | If auth enabled | Basic auth password |
| `ES_USE_SSL` | No | `true` for HTTPS |
| `ES_VERIFY_CERTS` | No | `false` for self-signed certs |
| `SSH_HOST` | SSH only | Bastion/jump host address |
| `SSH_PORT` | SSH only | SSH port (default 22) |
| `SSH_USERNAME` | SSH only | SSH login username |
| `SSH_PEM_FILE` | SSH only | **Your** local path to the PEM key |
| `SSH_REMOTE_ES_HOST` | SSH only | ES host as seen from the SSH server |
| `SSH_REMOTE_ES_PORT` | SSH only | ES port on the remote side |
| `SSH_LOCAL_PORT` | No | Local tunnel port (0 = auto) |

Leave `SSH_HOST` empty to use a direct connection instead of a tunnel.

## Usage

Just ask Claude naturally:

- "Show me recent errors in the app-logs index"
- "Search logs for connection refused in the last 30 minutes"
- "What indices are available?"
- "Count errors by service in logs-2024-*"
- "Is the Elasticsearch connection working?"
