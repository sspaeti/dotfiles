#!/bin/bash
# Arch Linux Package Maintenance Script
# Safe package cleanup and analysis for dotfiles management

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"

# List orphaned packages (dependencies no longer needed) to a file for review
orphans() {
    echo "=== Orphaned Packages (safe to remove) ===" | tee "$DOTFILES_DIR/arch-orphans.txt"
    pacman -Qdtq 2>/dev/null | tee -a "$DOTFILES_DIR/arch-orphans.txt" || echo "No orphaned packages found!" | tee -a "$DOTFILES_DIR/arch-orphans.txt"
    echo ""
    echo "Review arch-orphans.txt, then run 'make arch-cleanup' to remove them"
}

# Remove orphaned packages after review
cleanup() {
    if [ ! -f "$DOTFILES_DIR/arch-orphans.txt" ]; then
        echo "ERROR: Run 'make arch-orphans' first to generate the list!"
        exit 1
    fi

    echo "Removing orphaned packages from arch-orphans.txt..."
    if [ -s "$DOTFILES_DIR/arch-orphans.txt" ] && [ "$(wc -l < "$DOTFILES_DIR/arch-orphans.txt")" -gt 1 ]; then
        tail -n +2 "$DOTFILES_DIR/arch-orphans.txt" | sudo pacman -Rns -
        echo "Cleanup complete!"
    else
        echo "No orphaned packages to remove."
    fi
}

# Check which packages haven't been used recently and might not be needed
package_check() {
    OUTPUT="$DOTFILES_DIR/arch-package-analysis.txt"

    echo "=== Package Analysis ===" | tee "$OUTPUT"
    echo "" | tee -a "$OUTPUT"
    echo "--- Explicitly Installed Packages ($(pacman -Qe | wc -l) total) ---" | tee -a "$OUTPUT"
    echo "--- Dependencies ($(pacman -Qd | wc -l) total) ---" | tee -a "$OUTPUT"
    echo "--- AUR Packages ($(pacman -Qm | wc -l) total) ---" | tee -a "$OUTPUT"
    echo "" | tee -a "$OUTPUT"

    echo "=== 20 Largest Explicitly Installed Packages ===" | tee -a "$OUTPUT"
    pacman -Qei | awk '/^Name/{name=$3} /^Installed Size/{size=$4$5; print size"\t"name}' | sort -rh | head -20 | tee -a "$OUTPUT"
    echo "" | tee -a "$OUTPUT"

    echo "=== 30 Oldest Explicitly Installed Packages ===" | tee -a "$OUTPUT"
    pacman -Qei | awk '/^Name/{name=$3} /^Install Date/{date=$4" "$5" "$6" "$7; print date"\t"name}' | sort | head -30 | tee -a "$OUTPUT"
    echo "" | tee -a "$OUTPUT"

    echo "=== Packages with Optional Dependencies Not Installed ===" | tee -a "$OUTPUT"
    pacman -Qi | awk '/^Name/{name=$3} /^Optional Deps/{flag=1;next} /^Required By/{flag=0} flag' | grep -v "^\s*$" | head -50 | tee -a "$OUTPUT"
    echo "" | tee -a "$OUTPUT"

    echo "Review arch-package-analysis.txt to find packages you might want to remove manually"
    echo "To remove a package: sudo pacman -Rns <package-name>"
}

# Show packages that would be removed if you uninstall a specific package (dry-run)
check_deps() {
    if [ -z "$1" ]; then
        read -p "Enter package name to check: " pkg
    else
        pkg="$1"
    fi

    echo "=== Packages that depend on $pkg ==="
    pactree -r "$pkg" 2>/dev/null || echo "Package not found or no reverse dependencies"
}

# Clean package cache (keeps only 3 most recent versions)
clean_cache() {
    echo "Cleaning package cache (keeping 3 most recent versions)..."
    sudo paccache -rk3
    echo "Cleaning uninstalled package cache..."
    sudo paccache -ruk0
    echo "Cache cleaned!"
}

# Show help
help() {
    echo "Arch Linux Package Maintenance Script"
    echo ""
    echo "Usage: $0 <command>"
    echo ""
    echo "Commands:"
    echo "  orphans       - List orphaned packages to arch-orphans.txt"
    echo "  cleanup       - Remove orphaned packages (after reviewing arch-orphans.txt)"
    echo "  package-check - Analyze installed packages and save to arch-package-analysis.txt"
    echo "  check-deps    - Show what depends on a specific package"
    echo "  clean-cache   - Clean package cache (keeps 3 recent versions)"
    echo "  help          - Show this help message"
}

# Main command handler
case "$1" in
    orphans)
        orphans
        ;;
    cleanup)
        cleanup
        ;;
    package-check)
        package_check
        ;;
    check-deps)
        check_deps "$2"
        ;;
    clean-cache)
        clean_cache
        ;;
    help|--help|-h|"")
        help
        ;;
    *)
        echo "Unknown command: $1"
        echo ""
        help
        exit 1
        ;;
esac
