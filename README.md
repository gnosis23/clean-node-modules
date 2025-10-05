# Clean Node Modules

A bash script tool to help manage and clean up `node_modules` directories to save disk space. This tool scans for the largest `node_modules` directories in your projects and allows you to safely delete them.

## Features

- **List Mode**: Display the top 10 largest `node_modules` directories with their sizes
- **Delete Mode**: Safely delete the top 10 largest `node_modules` directories with confirmation
- **Interactive Mode**: User-friendly menu-driven interface
- **Color-coded Output**: Easy-to-read colored output for better visibility
- **Flexible Directory Targeting**: Scan current directory or specify a custom path
- **Safe Operations**: Confirmation prompts before deletion

## Usage

### Interactive Mode (Default)
```bash
./main.sh                    # Scan current directory
./main.sh /path/to/projects  # Scan specified directory
```

### List Mode
```bash
./main.sh -l                 # List top 10 largest node_modules in current directory
./main.sh -l /home/user      # List top 10 largest node_modules in specified directory
```

### Delete Mode
```bash
./main.sh -d                 # Delete top 10 largest node_modules in current directory
./main.sh -d /home/user      # Delete top 10 largest node_modules in specified directory
```

### Help
```bash
./main.sh -h                 # Show help message
```

## How It Works

1. **Scanning**: The script searches for `node_modules` directories in first-level subdirectories
2. **Sizing**: Calculates the size of each `node_modules` directory in megabytes
3. **Sorting**: Sorts directories by size (largest first)
4. **Display/Action**: Shows the top 10 largest directories or deletes them based on mode

## Safety Features

- **Confirmation Required**: Deletion mode requires explicit user confirmation
- **Directory Validation**: Checks if directories exist before operations
- **Error Handling**: Graceful handling of permission issues and missing directories
- **No Recursive Scanning**: Only scans first-level subdirectories to avoid system directories

## Requirements

- Bash shell
- Standard Unix utilities: `find`, `du`, `sort`, `head`

## Example Output

```
==================================
Node Modules Cleanup Tool
==================================
1. List top 10 node_modules directories
2. Delete top 10 largest node_modules directories
3. Exit
==================================

Working directory: /home/user/projects
```

## License

This project is open source and available under the MIT License.