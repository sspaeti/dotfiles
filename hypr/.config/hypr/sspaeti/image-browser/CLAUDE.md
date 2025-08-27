# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a screenshot management and OCR indexing system for Linux. It provides automated organization of screenshots by date and powerful text-based search functionality using OCR (Optical Character Recognition).

## Core Scripts

### Screenshot Organization
- `screenshot-organizer.sh` - Bulk organizes existing screenshots into monthly folders
- `auto-organize-screenshot.sh` - Auto-organizes new screenshots (hooks into screenshot tools)

### OCR Indexing and Search
- `screenshot-indexer-parallel.sh` - Fast parallel OCR indexing with smart incremental updates
- `screenshot-browser.sh` - Interactive TUI for browsing and searching screenshots

### Configuration
- `image-library-config.sh` - Central configuration file defining directories and paths

## Key Commands

### Build/Index Screenshots
```bash
# Full rebuild of OCR index (slow)
./screenshot-indexer-parallel.sh --rebuild

# Smart incremental update (fast, default)
./screenshot-indexer-parallel.sh --smart

# Index only recent screenshots (post-screenshot hook)
./screenshot-indexer-parallel.sh --recent
```

### Organize Screenshots
```bash
# Organize all screenshots in Pictures directory into monthly folders
./screenshot-organizer.sh

# Auto-organize recent screenshots (for automation)
./auto-organize-screenshot.sh
```

### Browse and Search
```bash
# Interactive TUI browser with search
./screenshot-browser.sh

# Direct search mode
./screenshot-browser.sh search

# Browse by month
./screenshot-browser.sh month 2025-08

# Show statistics
./screenshot-browser.sh stats
```

## Architecture

### Directory Structure
```
/home/sspaeti/Pictures/
├── Printscreen/           # Main screenshot directory
│   ├── 2025-07/          # Monthly organization
│   ├── 2025-08/
│   └── .screenshot_index.txt  # OCR search index
├── Fireshot/             # Browser extension screenshots
├── Ksnip/               # Screenshot tool captures
└── [organization scripts]
```

### OCR Index System
- **Index File**: `.image_ocr_index.txt` contains `filepath|ocr_text|file_size|mod_time`
- **Languages**: Supports German (`deu`) and English (`eng`) OCR
- **Smart Updates**: Only processes new/modified files for speed
- **Parallel Processing**: Uses 4 workers for fast bulk processing

### Dependencies
- `tesseract` - OCR text extraction (with German and English language packs)
- `yazi` - File manager for browsing
- `fzf` - Fuzzy finder for search interface
- `parallel` or manual batch processing for parallel OCR

## Configuration

The `image-library-config.sh` file defines:
- Base directories (`PICTURES_DIR`, `PRINTSCREEN_DIR`)
- Image directories to index (`IMAGE_DIRS` array)
- Supported file extensions (`IMAGE_EXTENSIONS`)
- Central index file location (`INDEX_FILE`)

To add new directories for indexing, modify the `IMAGE_DIRS` array in `image-library-config.sh`.

## Integration Patterns

### Post-Screenshot Automation
The system supports integration with screenshot tools through:
- `auto-organize-screenshot.sh` - Moves new screenshots to monthly folders
- `screenshot-indexer-parallel.sh --recent` - Fast OCR indexing of recent captures
- Lock file system prevents concurrent indexing conflicts

### Screenshot Naming Patterns
Supports multiple screenshot naming conventions:
- `screenshot-YYYY-MM-DD_HH-MM-SS.png` (default format)
- `YYYY-MM-DD-HHMMSS_hyprshot.png` (Hyprshot format)
- `flame screen-YYYY-MM-DD_HH-MM.png` (Flame screenshot format)

### Search and Browse Workflow
1. Screenshots are automatically organized into monthly directories
2. OCR indexing extracts searchable text from images
3. Interactive TUI allows fuzzy searching through OCR content
4. Results open in yazi file manager for viewing/actions
