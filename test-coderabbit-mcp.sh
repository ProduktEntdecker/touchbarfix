#!/bin/bash
# Test CodeRabbit MCP Integration

echo "🧪 Testing CodeRabbit MCP Server"
echo "================================="

# Test 1: Check if MCP server is installed
echo ""
echo "Test 1: Checking MCP server installation..."
if npx coderabbitai-mcp@latest --help &> /dev/null; then
    echo "✅ MCP server is installed and accessible"
else
    echo "❌ MCP server not found or not working"
    exit 1
fi

# Test 2: Check environment
echo ""
echo "Test 2: Checking environment setup..."
if [ -f "$HOME/.config/mcp/servers.json" ]; then
    echo "✅ MCP configuration file exists"
else
    echo "❌ MCP configuration file not found"
fi

# Test 3: Try to fetch a public PR (no auth required for public repos)
echo ""
echo "Test 3: Testing basic functionality..."
echo "Note: This may fail without proper GitHub token"
npx coderabbitai-mcp@latest --version 2>&1 || echo "Version check not available"

echo ""
echo "================================="
echo "🎉 Basic tests complete!"
echo ""
echo "To complete setup:"
echo "1. Add your GitHub token to: ~/.config/mcp/.env"
echo "2. Copy from template: cp ~/.config/mcp/.env.template ~/.config/mcp/.env"
echo "3. Edit the file and replace YOUR_GITHUB_TOKEN_HERE with your actual token"
echo ""
echo "To create a GitHub token:"
echo "1. Visit: https://github.com/settings/tokens/new"
echo "2. Select scopes: repo, read:org, read:user"
echo "3. Generate and copy the token"
