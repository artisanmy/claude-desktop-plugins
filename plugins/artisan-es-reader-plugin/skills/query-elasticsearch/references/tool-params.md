# Tool Parameter Reference

## list_indices
| Param | Default | Description |
|---|---|---|
| `pattern` | `*` | Glob pattern, e.g. `logs-*`, `app-2024-*` |

## search_logs
| Param | Default | Description |
|---|---|---|
| `index` | required | Index name or pattern |
| `query` | `""` | Lucene query string. Empty = match all |
| `size` | `20` | Results to return (max 1000) |
| `from_` | `0` | Pagination offset |
| `sort_field` | `@timestamp` | Field to sort by |
| `sort_order` | `desc` | `asc` or `desc` |
| `filters` | `""` | JSON array of extra ES must-clauses |

## get_recent_errors
| Param | Default | Description |
|---|---|---|
| `index` | required | Index name or pattern |
| `size` | `20` | Results to return |
| `level_field` | `level` | Field that holds the log level |
| `level_value` | `ERROR` | Value to filter on (e.g. `ERROR`, `CRITICAL`) |
| `minutes` | `60` | Look-back window in minutes |

## get_index_mapping
| Param | Default | Description |
|---|---|---|
| `index` | required | Index name |

## run_aggregation
| Param | Default | Description |
|---|---|---|
| `index` | required | Index name or pattern |
| `aggs` | required | JSON aggregation object |
| `query` | `""` | Optional Lucene filter |

**Example aggs values:**

Count by log level:
```json
{"by_level": {"terms": {"field": "level", "size": 10}}}
```

Errors over time (hourly):
```json
{"over_time": {"date_histogram": {"field": "@timestamp", "calendar_interval": "1h"}}}
```

## connection_info
No parameters. Returns current connection mode (direct or SSH tunnel) and active settings.
