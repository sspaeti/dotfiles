# duckdb.yazi

[duckdb](https://github.com/duckdb/duckdb) now in [yazi](https://github.com/sxyazi/yazi).

<img width="1710" alt="Screenshot 2025-03-22 at 18 00 06" src="https://github.com/user-attachments/assets/db09fff9-2db1-4273-9ddf-34d0bf087967" />

## Installation

To install, use the command:

ya pack -a wylie102/duckdb

and add to your yazi.toml:

[plugin]  
prepend_previewers = [  
  { mime = "text/csv", run = "duckdb" },  
  { name = "*.tsv", run = "duckdb" },  
  { name = "*.json", run = "duckdb" },  
  { name = "*.parquet", run = "duckdb" },  
]

prepend_preloaders = [  
  { mime = "text/csv", run = "duckdb", multi = false },  
  { name = "*.tsv", run = "duckdb", multi = false },  
  { name = "*.json", run = "duckdb", multi = false },  
  { name = "*.parquet", run = "duckdb", multi = false },  
]

### Yazi

[Installation installations](https://yazi-rs.github.io/docs/installation)

### duckdb

[Installation instructions](https://duckdb.org/docs/installation/?version=stable&environment=cli&platform=macos&download_method=direct)

## Recommended plugins

Use with a larger preview window or maximize the preview pane plugin:  
<https://github.com/yazi-rs/plugins/tree/main/toggle-pane.yazi>

## What does it do?

This plugin previews your data files in yazi using DuckDB, with two available view modes:

- Standard mode (default): Displays the file as a table.
- Summarized mode: Uses DuckDB's summarize function, enhanced with custom formatting for readability.

Supported file types:

- .csv  
- .json  
- .parquet  
- .tsv  

## New Features

- Default preview mode is now "standard."
- Preview mode can be toggled within yazi:
  - Press "K" at the top of the file to toggle between "standard" and "summarized."
- Preview mode is remembered per file, even after switching files or restarting yazi.
- Performance improvements through caching:
  - "Standard" and "summarized" views are cached upon first load, improving scrolling performance.

## Setup and usage changes

Previously, preview mode was selected by setting an environment variable (`DUCKDB_PREVIEW_MODE`).

The new version no longer uses environment variables. Toggle preview modes directly within yazi using the keybinding described above.

Scrolling within both views (standard and summarized) is handled by pressing J (down) and K (up). Performance is significantly better due to caching.

## Preview

<img width="1710" alt="Screenshot 2025-03-22 at 17 59 21" src="https://github.com/user-attachments/assets/ac006667-4281-4e0a-87a4-bfaeefc6f20b" />
