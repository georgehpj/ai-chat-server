#!/bin/bash

# Script to get Node.js 20 path for VS Code debugger
# This script ensures Node.js version 20 is used and returns its path

# Load nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Use Node.js 20
nvm use 20 >/dev/null 2>&1 || {
    echo "⚠️  Node.js 20 not found, attempting to install..." >&2
    nvm install 20 >/dev/null 2>&1 || {
        echo "❌ Failed to install Node.js 20. Please install it manually: nvm install 20" >&2
        exit 1
    }
    nvm use 20 >/dev/null 2>&1
}

# Output the node path (to stdout, errors to stderr)
which node