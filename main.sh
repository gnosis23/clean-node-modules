#!/bin/bash

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Function 1: List all node_modules sizes in target directory, sorted from largest to smallest, top 10
list_node_modules() {
    local target_dir="${1:-.}"
    echo ""
    echo -e "${BLUE}Listing top 10 largest node_modules directories in ${GREEN}$target_dir${NC}:${BLUE}"
    echo -e "${CYAN}==================================${NC}"
    echo ""

    # Find node_modules folders in first-level subdirectories
    find "$target_dir" -maxdepth 2 -name "node_modules" -type d 2>/dev/null | while read dir; do
        # Calculate size of each node_modules directory (in MB)
        size=$(du -sm "$dir" 2>/dev/null | cut -f1)
        if [ -n "$size" ] && [ "$size" -gt 0 ]; then
            echo "$size $dir"
        fi
    done | sort -nr | head -10 | while read size dir; do
        printf "  ${YELLOW}%8s MB${NC} - ${GREEN}%s${NC}\n" "$size" "$dir"
    done
    echo ""
}

# Function 2: Delete top 10 largest node_modules directories
delete_top10_node_modules() {
    local target_dir="${1:-.}"
    echo ""
    echo -e "  ${RED}Deleting top 10 largest node_modules directories in ${GREEN}$target_dir${NC}:${RED}"
    echo -e "  ${CYAN}==================================${NC}"
    echo ""

    # Get top 10 largest node_modules directories
    top10_dirs=$(find "$target_dir" -maxdepth 2 -name "node_modules" -type d 2>/dev/null | while read dir; do
        size=$(du -sm "$dir" 2>/dev/null | cut -f1)
        if [ -n "$size" ] && [ "$size" -gt 0 ]; then
            echo "$size $dir"
        fi
    done | sort -nr | head -10)

    if [ -z "$top10_dirs" ]; then
        echo -e "  ${YELLOW}No node_modules directories found${NC}"
        return
    fi

    # Show what will be deleted
    echo -e "  ${YELLOW}The following directories will be deleted:${NC}"
    echo "$top10_dirs" | while read size dir; do
        printf "    ${YELLOW}%8s MB${NC} - ${RED}%s${NC}\n" "$size" "$dir"
    done
    echo ""

    # Confirm deletion
    read -p "Are you sure you want to delete these top 10 directories? (y/N): " confirm
    if [[ $confirm =~ ^[Yy]$ ]]; then
        echo "$top10_dirs" | while read size dir; do
            if [ -n "$dir" ] && [ -d "$dir" ]; then
                echo -e "  ${RED}Deleting:${NC} $dir"
                rm -rf "$dir"
            fi
        done
        echo ""
        echo -e "${GREEN}✓ Deletion complete!${NC}"
        echo ""
    else
        echo ""
        echo -e "${YELLOW}Deletion cancelled${NC}"
        echo ""
    fi
}

# Main menu
show_menu() {
    echo ""
    echo -e "${CYAN}==================================${NC}"
    echo -e "${PURPLE}Node Modules Cleanup Tool${NC}"
    echo -e "${CYAN}==================================${NC}"
    echo -e "${GREEN}1.${NC} List top 10 node_modules directories"
    echo -e "${RED}2.${NC} Delete top 10 largest node_modules directories"
    echo -e "${YELLOW}3.${NC} Exit"
    echo -e "${CYAN}==================================${NC}"
    echo ""
}

# Help function
show_help() {
    echo "Usage: $0 [OPTIONS] [DIRECTORY]"
    echo ""
    echo "Node Modules Cleanup Tool - Clean up node_modules directories to save disk space"
    echo ""
    echo "Arguments:"
    echo "  DIRECTORY    Target directory to scan (default: current directory)"
    echo ""
    echo "Options:"
    echo "  -l, --list   List top 10 largest node_modules directories and exit"
    echo "  -d, --delete Delete top 10 largest node_modules directories and exit"
    echo "  -h, --help   Show this help message and exit"
    echo ""
    echo "Examples:"
    echo "  $0                    # Interactive mode in current directory"
    echo "  $0 /path/to/projects  # Interactive mode in specified directory"
    echo "  $0 -l                 # List mode in current directory"
    echo "  $0 -d /home/user      # Delete mode in specified directory"
}

# Main program
main() {
    local target_dir="."
    local mode="interactive"
    local display_dir=""

    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -l|--list)
                mode="list"
                shift
                ;;
            -d|--delete)
                mode="delete"
                shift
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            -*)
                echo "Unknown option: $1"
                show_help
                exit 1
                ;;
            *)
                # Assume it's a directory path
                if [[ -d "$1" ]]; then
                    target_dir="$1"
                    shift
                else
                    echo "Error: Directory '$1' does not exist"
                    exit 1
                fi
                ;;
        esac
    done

    # Set display directory to absolute path for better clarity
    if [[ "$target_dir" == "." ]]; then
        display_dir="$(pwd)"
    else
        display_dir="$(cd "$target_dir" 2>/dev/null && pwd)"
        if [[ -z "$display_dir" ]]; then
            display_dir="$target_dir"
        fi
    fi

    # Execute based on mode
    case $mode in
        list)
            list_node_modules "$target_dir"
            ;;
        delete)
            delete_top10_node_modules "$target_dir"
            ;;
        interactive)
            # Interactive mode with menu
            while true; do
                echo ""
                echo -e "${CYAN}Working directory: ${GREEN}$display_dir${NC}"
                show_menu
                read -p "Please select operation (1-3): " choice

                case $choice in
                    1)
                        list_node_modules "$target_dir"
                        ;;
                    2)
                        delete_top10_node_modules "$target_dir"
                        ;;
                    3)
                        echo ""
                        echo -e "${GREEN}Exiting program${NC}"
                        exit 0
                        ;;
                    *)
                        echo ""
                        echo -e "${RED}Invalid choice, please enter 1-3${NC}"
                        echo ""
                        ;;
                esac

                echo ""
            done
            ;;
    esac
}

# If script is run directly, execute main program
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
