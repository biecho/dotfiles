#!/bin/bash

# Path to .zshrc
ZSHRC="$HOME/.zshrc"

# The function to be added
FUNCTION_CONTENT=$(cat <<'EOF'
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
EOF
)

# Check if the function is already in .zshrc
if grep -q "serve_files()" "$ZSHRC"; then
    echo "The 'serve_files' function already exists in your .zshrc."
else
    # Append the function to .zshrc
    echo "Adding the 'serve_files' function to your .zshrc..."
    echo -e "\n# serve_files function: Quickly serve HTML files" >> "$ZSHRC"
    echo "$FUNCTION_CONTENT" >> "$ZSHRC"
    echo "The 'serve_files' function has been added to your .zshrc."
    echo "Run 'source $ZSHRC' to apply the changes."
fi

