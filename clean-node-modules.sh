#!/bin/bash

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Function 1: List all node_modules sizes in current directory, sorted from largest to smallest, top 10
list_node_modules() {
    echo ""
    echo -e "${BLUE}Listing top 10 largest node_modules directories:${NC}"
    echo -e "${CYAN}==================================${NC}"
    echo ""

    # Find node_modules folders in first-level subdirectories
    find . -maxdepth 2 -name "node_modules" -type d 2>/dev/null | while read dir; do
        # Calculate size of each node_modules directory (in MB)
        size=$(du -sm "$dir" 2>/dev/null | cut -f1)
        if [ -n "$size" ] && [ "$size" -gt 0 ]; then
            echo "$size $dir"
        fi
    done | sort -nr | head -10 | while read size dir; do
        printf "${YELLOW}%8s MB${NC} - ${GREEN}%s${NC}\n" "$size" "$dir"
    done
    echo ""
}

# Function 2: Delete top 10 largest node_modules directories
delete_top10_node_modules() {
    echo ""
    echo -e "${RED}Deleting top 10 largest node_modules directories...${NC}"
    echo -e "${CYAN}==================================${NC}"
    echo ""

    # Get top 10 largest node_modules directories
    top10_dirs=$(find . -maxdepth 2 -name "node_modules" -type d 2>/dev/null | while read dir; do
        size=$(du -sm "$dir" 2>/dev/null | cut -f1)
        if [ -n "$size" ] && [ "$size" -gt 0 ]; then
            echo "$size $dir"
        fi
    done | sort -nr | head -10)

    if [ -z "$top10_dirs" ]; then
        echo -e "${YELLOW}No node_modules directories found${NC}"
        return
    fi

    # Show what will be deleted
    echo -e "${YELLOW}The following directories will be deleted:${NC}"
    echo "$top10_dirs" | while read size dir; do
        printf "  ${YELLOW}%8s MB${NC} - ${RED}%s${NC}\n" "$size" "$dir"
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

# Main program
main() {
    while true; do
        show_menu
        read -p "Please select operation (1-3): " choice

        case $choice in
            1)
                list_node_modules
                ;;
            2)
                delete_top10_node_modules
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
}

# If script is run directly, execute main program
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi
