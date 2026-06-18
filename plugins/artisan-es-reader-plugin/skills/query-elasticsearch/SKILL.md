---
name: query-elasticsearch
description: >
  Query Elasticsearch logs and indices using the elasticsearch-logs MCP tools.
  Use when the user wants to search logs, trace an error, check recent errors,
  list indices, inspect field mappings, or run aggregations against Elasticsearch.
  Trigger phrases: "search logs", "check logs", "find errors", "trace this error",
  "list indices", "what happened", "show me logs", "recent errors", "query ES",
  "check elasticsearch".
tools:
  - mcp__elasticsearch-logs__list_indices
  - mcp__elasticsearch-logs__search_logs
  - mcp__elasticsearch-logs__get_recent_errors
  - mcp__elasticsearch-logs__get_index_mapping
  - mcp__elasticsearch-logs__run_aggregation
  - mcp__elasticsearch-logs__connection_info
---

## Querying Elasticsearch Logs

**IMPORTANT: Always use the MCP tools below. Never run SSH commands, curl, or shell scripts to query Elasticsearch directly. All queries must go through the MCP tools.**

### Defaults — apply these automatically unless the user says otherwise

- **size: 20** — always limit results to the latest 20 logs
- **sort: @timestamp desc** — always show newest first
- Never fetch more than 20 results unless the user explicitly asks for more

### Choosing the right tool

| User intent | Tool to use |
|---|---|
| "what indices exist", "show me indices" | `list_indices` |
| "search for X", "find logs with Y" | `search_logs` with `size=20` |
| "recent errors", "what errors in the last hour" | `get_recent_errors` with `size=20` |
| "what fields does this index have" | `get_index_mapping` |
| "count by X", "group by Y" | `run_aggregation` |
| "is the connection working", "which ES are we on" | `connection_info` |

### Workflow

1. If the user hasn't specified an index, call `list_indices` first to show available options and ask which one to search.
2. Call `get_index_mapping` if you need to know which fields are available before constructing a query.
3. For open-ended searches use `search_logs` with `size=20`.
4. For error triage use `get_recent_errors` with `size=20`.
5. Present results as a readable summary, not raw JSON. Highlight key fields (timestamp, message, level, service).

### Query syntax tips

- Exact phrase: `"connection refused"`
- Field match: `service:payment AND level:ERROR`
- Wildcards: `service:order*`
- Time range is handled by the `minutes` param in `get_recent_errors`, or via the `filters` param in `search_logs` as:
  `[{"range": {"@timestamp": {"gte": "now-1h"}}}]`

See `references/tool-params.md` for full parameter reference.
