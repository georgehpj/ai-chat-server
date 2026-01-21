#!/bin/bash

# Script to start server with nvm for VS Code debugger
# This script ensures Node.js version 20 is used and properly forwards all arguments

# Load nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Use Node.js 20 (suppress output for cleaner logs)
nvm use 20 >/dev/null 2>&1 || {
    echo "⚠️  Node.js 20 not found, attempting to install..." >&2
    nvm install 20 >/dev/null 2>&1 || {
        echo "❌ Failed to install Node.js 20. Please install it manually: nvm install 20" >&2
        exit 1
    }
    nvm use 20 >/dev/null 2>&1
}

# Get the node path
NODE_PATH=$(which node)
if [ -z "$NODE_PATH" ]; then
    echo "❌ Could not find Node.js executable" >&2
    exit 1
fi

# If first argument is "node", use the nvm's node and pass all remaining arguments
if [ "$1" = "node" ]; then
    shift
    exec "$NODE_PATH" "$@"
# If first argument is "nodemon", ensure it uses the correct node
elif [ "$1" = "nodemon" ]; then
    export PATH="$(dirname "$NODE_PATH"):$PATH"
    shift
    exec nodemon "$@"
else
    # Execute with the correct node in PATH
    export PATH="$(dirname "$NODE_PATH"):$PATH"
    exec "$@"
fi