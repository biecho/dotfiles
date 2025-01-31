#!/usr/bin/env python3

"""
Installs the 'serve_files' function into ~/.zshrc if it's not already present.
"""

from installer_utils import logger, ensure_line_in_file, ZSHRC_PATH

# The function we want to add:
SERVE_FILES_FUNCTION = r"""
serve_files() {
    local port=${1:-8000}       # Use the first argument as the port, default to 8000
    local directory=${2:-$(pwd)} # Use the second argument as the directory, default to current directory

    # Check if the port is already in use
    if lsof -i :"$port" > /dev/null 2>&1; then
        echo "Error: Port $port is already in use."
        return 1
    fi

    echo "Serving files from $directory on http://localhost:$port"
    python3 -m http.server "$port" --directory "$directory"
}
""".strip()


def main():
    comment_header = "# serve_files function: Quickly serve HTML files"
    snippet_to_add = f"\n{comment_header}\n{SERVE_FILES_FUNCTION}"
    ensure_line_in_file(
        file_path=ZSHRC_PATH,
        search_regex=r"serve_files\(\)",
        line_to_add=snippet_to_add
    )


if __name__ == "__main__":
    main()
