#!/bin/bash

# Setup Node.js environment for VS Code debugging

# Load nvm
if [ -s "$HOME/.nvm/nvm.sh" ]; then
    source "$HOME/.nvm/nvm.sh"
    # Try to use Node.js 20
    nvm use 20 2>/dev/null || echo "⚠️  Node.js 20 not found, using current version"
    
    echo "✅ Node.js version:"
    node --version || echo "⚠️  Node.js not available"
    
    echo "✅ Node.js path:"
    which node || echo "⚠️  Node.js path not found"
else
    echo "⚠️  NVM not found at $HOME/.nvm/nvm.sh"
    echo "⚠️  Please install nvm or use system Node.js"
fi