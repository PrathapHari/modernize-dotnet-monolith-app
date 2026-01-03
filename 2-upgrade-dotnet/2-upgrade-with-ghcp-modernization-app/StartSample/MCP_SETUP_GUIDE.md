# MCP Server Setup Guide for eShopLite Project

## Overview
This guide helps you set up Model Context Protocol (MCP) servers for your eShopLite modernization project.

## Prerequisites

1. **Azure CLI** - Already installed ✅
2. **GitHub Personal Access Token**
3. **Visual Studio 2022** with GitHub Copilot

## Setup Instructions

### 1. Azure MCP Server

**Purpose:** Deploy and manage Azure resources for your eShopLite app

**Steps:**

1. **Login to Azure:**
   ```powershell
   az login
   ```

2. **Get your subscription ID:**
   ```powershell
   az account list --output table
   ```
   
   Copy the `SubscriptionId` from the output.

3. **Set environment variable:**
   ```powershell
   # PowerShell
   $env:AZURE_SUBSCRIPTION_ID = "your-subscription-id"
   
   # Make it permanent
   [System.Environment]::SetEnvironmentVariable('AZURE_SUBSCRIPTION_ID', 'your-subscription-id', 'User')
   ```

4. **Test access:**
   ```powershell
   az account show
   ```

### 2. GitHub MCP Server

**Purpose:** Access your repository, issues, and documentation

**Steps:**

1. **Create GitHub Personal Access Token:**
   - Go to: https://github.com/settings/tokens
   - Click "Generate new token (classic)"
   - Select scopes:
     - ✅ `repo` (Full control of private repositories)
     - ✅ `read:org` (Read org and team membership)
     - ✅ `read:user` (Read user profile data)
   - Click "Generate token"
   - **Copy the token immediately** (you won't see it again!)

2. **Set environment variable:**
   ```powershell
   # PowerShell
   $env:GITHUB_TOKEN = "ghp_your_token_here"
   
   # Make it permanent
   [System.Environment]::SetEnvironmentVariable('GITHUB_TOKEN', 'ghp_your_token_here', 'User')
   ```

3. **Test access:**
   ```powershell
   # Install GitHub CLI if needed
   winget install --id GitHub.cli
   
   # Test
   gh auth status
   ```

### 3. SQLite MCP Server

**Purpose:** Query your eShopLite database for context

**Steps:**

1. **Verify database exists:**
   ```powershell
   Test-Path "src\eShopLite.StoreFx\eShopLite.db"
   ```

2. **No additional setup needed** - SQLite is file-based

3. **Optional: Install DB Browser for SQLite**
   ```powershell
   winget install sqlitebrowser.sqlitebrowser
   ```

### 4. Microsoft Documentation MCP

**Purpose:** Access latest .NET 10 and Blazor documentation

**Steps:**

1. **No setup required** - Uses public APIs
2. **Automatically provides:**
   - .NET 10 documentation
   - Blazor guides
   - Entity Framework Core docs
   - ASP.NET Core references

### 5. NuGet MCP Server

**Purpose:** Query NuGet packages and suggest updates

**Steps:**

1. **No setup required** - Uses public NuGet API
2. **Features:**
   - Find packages
   - Check for updates
   - View dependencies
   - Security advisories

## Configuration File Location

### Option 1: User-level (Recommended)
**Location:** `%APPDATA%\GitHub Copilot\mcp-settings.json`

**Path:** `C:\Users\prath\AppData\Roaming\GitHub Copilot\mcp-settings.json`

### Option 2: Workspace-level
**Location:** `.vscode\mcp-settings.json` (in your project root)

## Complete Configuration

Use the `eShopLite-mcp-config.json` file in your workspace as a template:

```json
{
  "mcpServers": {
    "azure": {
      "type": "azure",
      "enabled": true,
      "configuration": {
        "subscriptionId": "${AZURE_SUBSCRIPTION_ID}",
        "authentication": "azure-cli"
      }
    },
    "github": {
      "type": "github",
      "enabled": true,
      "configuration": {
        "token": "${GITHUB_TOKEN}",
        "repositories": ["PrathapHari/modernize-dotnet-monolith-app"]
      }
    },
    "sqlite": {
      "type": "sqlite",
      "enabled": true,
      "configuration": {
        "databasePath": "./src/eShopLite.StoreFx/eShopLite.db",
        "readOnly": true
      }
    }
  }
}
```

## Applying Configuration

### In Visual Studio:

1. **Open Copilot Settings:**
   - Tools → Options → GitHub Copilot
   - Or: Ctrl+Q, type "Copilot"

2. **Import Configuration:**
   - Click "Import MCP Configuration"
   - Select `eShopLite-mcp-config.json`
   - Click "Apply"

3. **Restart Visual Studio** to apply changes

### In VS Code:

1. **Copy configuration:**
   ```powershell
   Copy-Item eShopLite-mcp-config.json "$env:APPDATA\GitHub Copilot\mcp-settings.json"
   ```

2. **Reload VS Code:**
   - Ctrl+Shift+P
   - Type "Reload Window"
   - Press Enter

## Verification

### Test Azure MCP:

In Copilot Chat, try:
```
What Azure resources are available in my subscription?
```

### Test GitHub MCP:

```
Show me recent commits in my repository
```

### Test SQLite MCP:

```
What tables are in my eShopLite database?
```

### Test Microsoft Docs MCP:

```
Show me the latest .NET 10 features
```

## Troubleshooting

### Issue: "Azure authentication failed"

**Solution:**
```powershell
az logout
az login
az account set --subscription "your-subscription-id"
```

### Issue: "GitHub token invalid"

**Solution:**
1. Check token hasn't expired
2. Verify token has correct scopes
3. Regenerate token if needed
4. Update environment variable

### Issue: "Cannot access SQLite database"

**Solution:**
```powershell
# Check file permissions
Get-Acl "src\eShopLite.StoreFx\eShopLite.db"

# Ensure path is relative to workspace root
# Use forward slashes: ./src/eShopLite.StoreFx/eShopLite.db
```

### Issue: "MCP servers not showing in Copilot"

**Solution:**
1. Restart Visual Studio completely
2. Check configuration file syntax (must be valid JSON)
3. Verify environment variables are set
4. Check Copilot is enabled and authenticated

## Security Considerations

### ✅ DO:
- Use environment variables for secrets
- Enable `readOnly` for databases when possible
- Restrict repository access to necessary repos
- Use least-privilege Azure roles
- Rotate tokens regularly

### ❌ DON'T:
- Commit tokens to Git
- Share configuration files with secrets
- Use admin tokens when read-only will work
- Enable write access unless absolutely needed

## Advanced Configuration

### Custom MCP Server

If you need a custom API:

```json
{
  "custom-api": {
    "type": "http",
    "enabled": true,
    "url": "https://your-internal-api.company.com",
    "authentication": {
      "type": "bearer",
      "token": "${CUSTOM_API_TOKEN}"
    },
    "headers": {
      "X-API-Version": "2.0"
    }
  }
}
```

### Conditional Configuration

Enable/disable based on environment:

```json
{
  "development": {
    "sqlite": {
      "enabled": true,
      "databasePath": "./src/eShopLite.StoreFx/eShopLite.db"
    }
  },
  "production": {
    "sqlite": {
      "enabled": false
    },
    "sql-server": {
      "enabled": true,
      "connectionString": "${PROD_CONNECTION_STRING}"
    }
  }
}
```

## Benefits for Your Project

### 1. Azure Integration
- Deploy to Azure App Service with one command
- Query Application Insights
- Manage Azure SQL databases
- Monitor costs and resources

### 2. GitHub Integration
- Reference issues in code
- Link to PRs and commits
- Search across repository history
- Understand project context

### 3. Database Context
- Query schema for Entity Framework models
- Generate SQL queries
- Optimize database performance
- Understand data relationships

### 4. Documentation Access
- Latest .NET 10 features
- Blazor best practices
- Bootstrap 5 examples
- Security recommendations

### 5. Package Management
- Find compatible NuGet packages
- Check for vulnerabilities
- Suggest version updates
- Resolve dependency conflicts

## Next Steps

1. ✅ Set up environment variables (AZURE_SUBSCRIPTION_ID, GITHUB_TOKEN)
2. ✅ Copy eShopLite-mcp-config.json to Copilot settings folder
3. ✅ Restart Visual Studio
4. ✅ Test each MCP server with a simple query
5. ✅ Start using enhanced Copilot capabilities!

## Resources

- **MCP Specification:** https://modelcontextprotocol.io
- **GitHub Copilot Docs:** https://docs.github.com/copilot
- **Azure CLI Docs:** https://docs.microsoft.com/cli/azure
- **GitHub CLI:** https://cli.github.com

## Support

If you encounter issues:
1. Check GitHub Copilot logs in Visual Studio
2. Verify all prerequisites are installed
3. Test each service individually
4. Consult the troubleshooting section above

---

**Your eShopLite project is now ready for enhanced AI assistance!** 🚀
