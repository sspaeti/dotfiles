#!/bin/bash

# Safe dotfiles restore script
# This script provides multiple restoration modes to safely restore dotfiles
# without overwriting existing configurations

set -e  # Exit on any error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
DOTFILES_DIR="$HOME/dotfiles"  # Adjust this path
BACKUP_DIR="$HOME/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"
DRY_RUN=false
INTERACTIVE=true
FORCE=false

# Usage function
usage() {
    echo "Usage: $0 [OPTIONS]"
    echo "Options:"
    echo "  -d, --dotfiles-dir DIR    Dotfiles directory (default: $DOTFILES_DIR)"
    echo "  -b, --backup-dir DIR      Backup directory (default: $BACKUP_DIR)"
    echo "  -n, --dry-run             Show what would be done without making changes"
    echo "  -y, --yes                 Non-interactive mode (assume yes)"
    echo "  -f, --force               Force overwrite existing files"
    echo "  -h, --help                Show this help"
    echo ""
    echo "Restoration modes:"
    echo "  1. Interactive mode (default): Ask before each file"
    echo "  2. Backup mode: Backup existing files before restore"
    echo "  3. Merge mode: Attempt to merge configurations"
    echo "  4. Symlink mode: Create symlinks instead of copying"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -d|--dotfiles-dir)
            DOTFILES_DIR="$2"
            shift 2
            ;;
        -b|--backup-dir)
            BACKUP_DIR="$2"
            shift 2
            ;;
        -n|--dry-run)
            DRY_RUN=true
            shift
            ;;
        -y|--yes)
            INTERACTIVE=false
            shift
            ;;
        -f|--force)
            FORCE=true
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            usage
            exit 1
            ;;
    esac
done

# Utility functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

ask_user() {
    if [[ "$INTERACTIVE" == false ]]; then
        return 0
    fi
    
    local prompt="$1"
    local default="${2:-n}"
    
    while true; do
        read -p "$prompt [y/N]: " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            return 0
        elif [[ $REPLY =~ ^[Nn]$ ]] || [[ -z $REPLY ]]; then
            return 1
        else
            echo "Please answer y or n."
        fi
    done
}

# Create backup directory
create_backup_dir() {
    if [[ ! -d "$BACKUP_DIR" ]]; then
        log_info "Creating backup directory: $BACKUP_DIR"
        if [[ "$DRY_RUN" == false ]]; then
            mkdir -p "$BACKUP_DIR"
        fi
    fi
}

# Backup existing file
backup_file() {
    local target="$1"
    local backup_path="$BACKUP_DIR/$(dirname "$target")"
    
    if [[ -e "$target" ]]; then
        log_info "Backing up existing file: $target"
        if [[ "$DRY_RUN" == false ]]; then
            mkdir -p "$backup_path"
            cp -r "$target" "$backup_path/"
        fi
        return 0
    fi
    return 1
}

# Safe copy function
safe_copy() {
    local source="$1"
    local target="$2"
    local action="$3"  # copy, symlink, or merge
    
    # Check if source exists
    if [[ ! -e "$source" ]]; then
        log_warning "Source file does not exist: $source"
        return 1
    fi
    
    # Create target directory if it doesn't exist
    local target_dir="$(dirname "$target")"
    if [[ ! -d "$target_dir" ]]; then
        log_info "Creating directory: $target_dir"
        if [[ "$DRY_RUN" == false ]]; then
            mkdir -p "$target_dir"
        fi
    fi
    
    # Handle existing target
    if [[ -e "$target" ]]; then
        if [[ "$FORCE" == true ]]; then
            log_info "Force overwriting: $target"
            backup_file "$target"
        elif ask_user "File exists: $target. Overwrite?"; then
            backup_file "$target"
        else
            log_info "Skipping: $target"
            return 0
        fi
    fi
    
    # Perform the action
    case "$action" in
        copy)
            log_info "Copying: $source -> $target"
            if [[ "$DRY_RUN" == false ]]; then
                cp -r "$source" "$target"
            fi
            ;;
        symlink)
            log_info "Symlinking: $source -> $target"
            if [[ "$DRY_RUN" == false ]]; then
                ln -sf "$source" "$target"
            fi
            ;;
        merge)
            log_info "Merging: $source -> $target"
            # This is a placeholder - implement specific merge logic per file type
            if [[ "$DRY_RUN" == false ]]; then
                cp -r "$source" "$target"
            fi
            ;;
    esac
}

# Platform detection
detect_platform() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "linux"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    else
        echo "unknown"
    fi
}

# Adjust paths for different platforms
adjust_path() {
    local original_path="$1"
    local platform="$2"
    
    case "$platform" in
        linux)
            # Convert macOS paths to Linux equivalents
            echo "$original_path" | sed \
                -e 's|~/Library/ApplicationSupport/Code/User/|~/.config/Code/User/|g' \
                -e 's|~/Library/Application Support/lazygit/|~/.config/lazygit/|g'
            ;;
        macos)
            # Convert Linux paths to macOS equivalents
            echo "$original_path" | sed \
                -e 's|~/.config/Code/User/|~/Library/ApplicationSupport/Code/User/|g' \
                -e 's|~/.config/lazygit/|~/Library/Application Support/lazygit/|g'
            ;;
        *)
            echo "$original_path"
            ;;
    esac
}

# Main restoration function
restore_dotfiles() {
    local platform=$(detect_platform)
    local mode="$1"
    
    log_info "Detected platform: $platform"
    log_info "Restoration mode: $mode"
    
    if [[ "$DRY_RUN" == true ]]; then
        log_warning "DRY RUN MODE - No changes will be made"
    fi
    
    create_backup_dir
    
    # Define file mappings (source -> target)
    declare -A file_mappings=(
        # VS Code
        ["vscode/settings.json"]="$(adjust_path "~/Library/ApplicationSupport/Code/User/settings.json" "$platform")"
        ["vscode/keybindings.json"]="$(adjust_path "~/Library/ApplicationSupport/Code/User/keybindings.json" "$platform")"
        
        # Neovim
        ["nvim/init.vim"]="~/.config/nvim/init.vim"
        ["nvim-wp/init.vim"]="~/.config/nvim-wp/init.vim"
        
        # Tmux
        ["tmux/tmux.conf"]="~/.tmux.conf"
        ["tmux/ide"]="~/.tmux/ide"
        
        # Zsh
        ["zsh/zshrc"]="~/.zshrc"
        ["zsh/.secrets"]="~/.dotfiles/zsh/.secrets"
        ["zsh/aliases.shrc"]="~/.dotfiles/zsh/aliases.shrc"
        
        # Kitty
        ["kitty/kitty.conf"]="~/.config/kitty/kitty.conf"
        ["kitty/gruvbox-kitty.conf"]="~/.config/kitty/gruvbox-kitty.conf"
        
        # Ghostty
        ["ghostty/config"]="~/.config/ghostty/config"
        
        # Yabai & SKHD (macOS only)
        ["yabai/yabairc"]="~/.config/yabai/yabairc"
        ["skhd/skhdrc"]="~/.config/skhd/skhdrc"
        
        # Helix
        ["helix/config.toml"]="~/.config/helix/config.toml"
        
        # Git (be careful with this one)
        # ["git/gitconfig"]="~/.gitconfig"
        
        # Ranger
        ["ranger/rc.conf"]="~/.config/ranger/rc.conf"
        
        # Yazi
        ["yazi/yazi.toml"]="~/.config/yazi/yazi.toml"
        
        # Linting
        ["linting/pylintrc"]="~/.pylintrc"
        ["linting/flake8"]="~/.config/flake8"
        
        # Karabiner (macOS only)
        ["karabiner/karabiner.json"]="~/.config/karabiner/karabiner.json"
        
        # Lazygit
        ["lazygit/config.yml"]="$(adjust_path "~/Library/Application Support/lazygit/config.yml" "$platform")"
    )
    
    # Process each file
    for source_file in "${!file_mappings[@]}"; do
        local source_path="$DOTFILES_DIR/$source_file"
        local target_path="${file_mappings[$source_file]}"
        
        # Expand tilde
        target_path="${target_path/#\~/$HOME}"
        
        # Skip platform-specific files
        if [[ "$platform" == "linux" ]] && [[ "$source_file" == *"yabai"* || "$source_file" == *"skhd"* || "$source_file" == *"karabiner"* ]]; then
            log_info "Skipping macOS-specific file: $source_file"
            continue
        fi
        
        case "$mode" in
            copy)
                safe_copy "$source_path" "$target_path" "copy"
                ;;
            symlink)
                safe_copy "$source_path" "$target_path" "symlink"
                ;;
            merge)
                safe_copy "$source_path" "$target_path" "merge"
                ;;
        esac
    done
    
    log_success "Dotfiles restoration completed!"
    if [[ -d "$BACKUP_DIR" ]] && [[ "$(ls -A "$BACKUP_DIR" 2>/dev/null)" ]]; then
        log_info "Backup of original files created at: $BACKUP_DIR"
    fi
}

# Special handling for sensitive files
handle_sensitive_files() {
    local sensitive_files=(
        ".ssh"
        ".secrets"
        "gitconfig"
    )
    
    for file in "${sensitive_files[@]}"; do
        if ask_user "Restore sensitive file: $file?"; then
            log_warning "Restoring sensitive file: $file"
            # Add specific handling here
        fi
    done
}

# Main execution
main() {
    log_info "Starting dotfiles restoration"
    
    # Check if dotfiles directory exists
    if [[ ! -d "$DOTFILES_DIR" ]]; then
        log_error "Dotfiles directory not found: $DOTFILES_DIR"
        exit 1
    fi
    
    # Choose restoration mode
    if [[ "$INTERACTIVE" == true ]]; then
        echo "Choose restoration mode:"
        echo "1. Copy files (default)"
        echo "2. Create symlinks"
        echo "3. Merge configurations"
        read -p "Enter choice [1-3]: " -n 1 -r
        echo
        
        case "$REPLY" in
            2) restore_dotfiles "symlink" ;;
            3) restore_dotfiles "merge" ;;
            *) restore_dotfiles "copy" ;;
        esac
    else
        restore_dotfiles "copy"
    fi
    
    # Handle sensitive files separately
    handle_sensitive_files
}

# Run main function
main "$@"
