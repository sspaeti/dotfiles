# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Architecture Overview

This is an **Image Library Browser System** built with Bash scripts for Linux/Hyprland environments. It provides a comprehensive solution for organizing, indexing, and searching screenshots and design images using OCR technology.

### Core Components

**Central Configuration (`image-library-config.sh`)**
- Exports shared environment variables and directory paths
- Defines `IMAGE_DIRS` array with all monitored image directories
- Provides utility functions `find_all_images()` and `count_all_images()`

**Main Browser Interface (`screenshot-browser-gum.sh`)**  
- TUI application using `gum` for beautiful terminal interface
- Provides OCR-based text search, monthly browsing, statistics, and index management
- Integrates with `yazi` file manager for image previews
- Main entry point for end users

**OCR Indexer (`screenshot-indexer-parallel.sh`)**
- Parallel OCR processing using Tesseract with German+English language support
- Three indexing modes: `--rebuild` (full), `--smart` (incremental), `--recent` (post-screenshot)
- Lock file mechanism prevents concurrent indexing
- Uses 4 workers for optimal performance

**Auto Organization (`auto-organize-screenshot.sh`)**
- Post-screenshot hook that moves new screenshots to monthly folders (`YYYY-MM`)
- Automatically triggers background smart indexing
- Handles recent screenshots (within 1 minute)

**Manual Organization (`screenshot-organizer.sh`)**
- Batch organizes screenshots by parsing dates from filenames
- Supports multiple filename formats: hyprshot, screenshot, flame screen
- Creates monthly directory structure in `~/Pictures/Printscreen/`

### Directory Structure
```
~/Pictures/
├── Printscreen/           # Main screenshot storage
│   ├── 2025-01/          # Monthly organization
│   └── 2025-02/
├── Fireshot/             # Browser screenshots
├── Ksnip/               # Ksnip screenshots  
└── Design Blogs/        # Various design image directories
```

### Data Flow
1. Screenshot taken → auto-organize-screenshot.sh moves to monthly folder
2. Background smart indexing extracts OCR text using Tesseract
3. Index stored in `.image_ocr_index.txt` with format: `filepath|ocr_text|file_size|mod_time`
4. Browser interface searches index and opens results in yazi

## Common Development Commands

**Run the main browser:**
```bash
./screenshot-browser-gum.sh
```

**Direct commands:**
```bash
./screenshot-browser-gum.sh search    # Direct to OCR search
./screenshot-browser-gum.sh browse    # Direct to file browser  
./screenshot-browser-gum.sh stats     # Show statistics
```

**Index management:**
```bash
./screenshot-indexer-parallel.sh --smart     # Incremental update (default)
./screenshot-indexer-parallel.sh --rebuild   # Full rebuild
./screenshot-indexer-parallel.sh --recent    # Recent screenshots only
```

**Manual organization:**
```bash
./screenshot-organizer.sh              # Organize loose screenshots
./auto-organize-screenshot.sh [path]   # Organize specific screenshot
```

## Dependencies

Required packages (install via package manager):
- `yazi` or `yazi-git` - File manager with image previews
- `fzf` - Fuzzy finder for fallback search interface
- `tesseract` - OCR engine for text extraction
- `gum` - Terminal UI components for beautiful interface

**Arch Linux:**
```bash
sudo pacman -S yazi-git fzf tesseract gum
```

## Configuration

**Key Environment Variables (set in image-library-config.sh):**
- `PICTURES_DIR`: Base pictures directory (`/home/sspaeti/Pictures`)
- `PRINTSCREEN_DIR`: Screenshot storage (`$PICTURES_DIR/Printscreen`)  
- `INDEX_FILE`: OCR index location (`$SHELL_DIR/.image_ocr_index.txt`)
- `IMAGE_DIRS`: Array of all indexed image directories

**OCR Languages:** 
- Configured for German + English (`deu+eng`)
- Modify `tesseract` language parameter in indexer if needed

## Integration Points

**Hyprland Integration:**
- Auto-organize script intended as post-screenshot hook
- Works with hyprshot, screenshot tools, and manual file placement

**File Manager Integration:**
- Optimized for `yazi` with image preview capabilities
- Creates temporary symlink directories for search results
- Sorts by modification time (newest first)

## Performance Notes

- **Smart indexing** only processes files newer than last index (60s safety margin)
- **Parallel processing** uses 4 workers to avoid resource contention  
- **Lock file mechanism** prevents concurrent indexing operations
- **Recent mode** for fast post-screenshot indexing (2-minute window)