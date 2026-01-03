# Microsoft Learn & Sequential Thinking MCP Servers Setup

## Overview

This guide covers the setup of two powerful MCP servers:
1. **Microsoft Learn MCP** - Semantic search across official Microsoft documentation
2. **Sequential Thinking MCP** - Enhanced problem-solving with persistent reasoning state

---

## 1. Microsoft Learn MCP Server

### What It Does

The Microsoft Learn MCP server provides:
- ✅ **Semantic search** across docs.microsoft.com and learn.microsoft.com
- ✅ **Real-time access** to latest documentation (not cached)
- ✅ **Context-aware results** specific to your queries
- ✅ **Code samples** from official Microsoft sources
- ✅ **API references** for .NET, Azure, and more

### Why Use It?

Better than the generic documentation MCP because:
- 🎯 Uses official Microsoft Learn search API
- 🔍 Semantic search understands context better
- 📚 Covers entire Microsoft Learn catalog
- ⚡ Returns most relevant results first
- 🆕 Always up-to-date (no caching)

### Prerequisites

**Node.js** is required (version 18+):

```powershell
# Check if Node.js is installed
node --version

# If not installed, install via winget
winget install OpenJS.NodeJS.LTS

# Or download from: https://nodejs.org
```

### Installation & Setup

The server is installed automatically via `npx` when GitHub Copilot starts. No manual installation needed!

### Configuration

Already configured in `eShopLite-mcp-config.json`:

```json
{
  "microsoft-learn": {
    "type": "stdio",
    "enabled": true,
    "description": "Official Microsoft Learn documentation search",
    "command": "npx",
    "args": ["-y", "@modelcontextprotocol/server-microsoft-learn"],
    "configuration": {
      "searchDomains": [
        "docs.microsoft.com",
        "learn.microsoft.com"
      ],
      "preferredTopics": [
        ".NET 10",
        "C# 14",
        "Blazor",
        "Entity Framework Core",
        "ASP.NET Core",
        "Azure",
        "Visual Studio"
      ]
    }
  }
}
```

### Usage Examples

Once configured, ask GitHub Copilot:

**For .NET 10 Features:**
```
What are the new features in .NET 10?
```

**For Blazor Best Practices:**
```
Show me Blazor Server best practices for production
```

**For Entity Framework:**
```
How do I use Entity Framework Core with SQLite in .NET 10?
```

**For Azure Deployment:**
```
How do I deploy a Blazor app to Azure App Service?
```

**For Performance:**
```
What are the performance improvements in ASP.NET Core for .NET 10?
```

### Benefits for Your eShopLite Project

- ✅ Get accurate .NET 10 guidance
- ✅ Learn Blazor best practices
- ✅ Understand Entity Framework Core patterns
- ✅ Find Azure deployment strategies
- ✅ Discover Bootstrap integration techniques
- ✅ Access security recommendations

---

## 2. Sequential Thinking MCP Server

### What It Does

The Sequential Thinking MCP enables:
- 🧠 **Multi-step reasoning** for complex problems
- 💾 **Persistent thinking state** across sessions
- 🔄 **Adaptive problem-solving** that improves with context
- 📝 **Thought tracking** so you can see the reasoning process
- 🎯 **Budget-controlled thinking** to manage complexity

### Why Use It?

Perfect for:
- 🏗️ **Architecture decisions** - "Should I use microservices or modular monolith?"
- 🐛 **Complex debugging** - "Why is my Blazor component not rendering?"
- ⚡ **Performance optimization** - "How can I make my app faster?"
- 🔐 **Security analysis** - "What security vulnerabilities should I address?"
- 📊 **Refactoring planning** - "How should I restructure this code?"

### Prerequisites

**Node.js** is required (version 18+):

```powershell
# Check if Node.js is installed
node --version

# If not installed
winget install OpenJS.NodeJS.LTS
```

### Installation & Setup

#### Step 1: Ensure Node.js is Installed

```powershell
node --version
# Should show: v18.x.x or higher
```

#### Step 2: Create Thoughts Directory

```powershell
# Create directory for persistent thoughts
New-Item -ItemType Directory -Force -Path ".mcp\thoughts"

# Verify it was created
Test-Path ".mcp\thoughts"
# Should return: True
```

#### Step 3: Configuration Already Done

The server is configured in `eShopLite-mcp-config.json`:

```json
{
  "sequential-thinking": {
    "type": "stdio",
    "enabled": true,
    "command": "npx",
    "args": ["-y", "@modelcontextprotocol/server-sequential-thinking"],
    "configuration": {
      "thinkingBudget": 20000,
      "enablePersistedThinking": true,
      "thoughtDirectory": "./.mcp/thoughts"
    }
  }
}
```

### Configuration Options Explained

**`thinkingBudget: 20000`**
- Controls how deep the reasoning can go
- Higher = more thorough but slower
- 20000 is good for complex problems
- Adjust based on your needs:
  - Simple questions: 5000-10000
  - Complex problems: 20000-30000
  - Very complex: 40000+

**`enablePersistedThinking: true`**
- Saves thinking state to disk
- Allows reasoning to continue across sessions
- Helps with long-running problems

**`thoughtDirectory: "./.mcp/thoughts"`**
- Where thoughts are saved
- Relative to your workspace root
- Can be .gitignored for privacy

### Usage Examples

#### Example 1: Architecture Decision

**Ask:**
```
I need to decide whether to refactor my eShopLite monolith into microservices or 
keep it as a modular monolith. Walk me through the decision process considering:
- Current complexity (2 stores, 9 products)
- Team size (1-2 developers)
- Deployment requirements
- Future scalability needs
```

**What happens:**
1. Server breaks down the problem
2. Considers each factor
3. Weighs trade-offs
4. Provides reasoned recommendation
5. Saves reasoning for future reference

#### Example 2: Performance Investigation

**Ask:**
```
My Blazor app loads slowly. Help me investigate step-by-step:
1. What are common Blazor performance issues?
2. How do I diagnose the bottleneck?
3. What tools should I use?
4. What fixes should I try first?
```

**What happens:**
- Sequential analysis of each step
- Builds on previous findings
- Provides actionable recommendations
- Tracks reasoning across the investigation

#### Example 3: Refactoring Strategy

**Ask:**
```
I need to refactor my Products component. Think through:
- Current implementation problems
- Desired improvements
- Step-by-step refactoring plan
- Testing strategy
- Rollback plan if issues occur
```

### Understanding the Thinking Process

The server maintains a **thought chain**:

```
Initial Problem
    ↓
Thought 1: Understand requirements
    ↓
Thought 2: Identify constraints
    ↓
Thought 3: Consider options
    ↓
Thought 4: Evaluate trade-offs
    ↓
Thought 5: Make recommendation
    ↓
Final Answer
```

### Persisted Thoughts Structure

Thoughts are saved in `.mcp/thoughts/`:

```
.mcp/
└── thoughts/
    ├── architecture-decision-20260103.json
    ├── performance-investigation-20260103.json
    └── refactoring-plan-20260103.json
```

Each file contains:
- Problem statement
- Thinking steps
- Conclusions
- Timestamp
- Context

### Best Practices

#### 1. Frame Problems Clearly

**❌ Vague:**
```
Make my app better
```

**✅ Specific:**
```
I need to improve my app's initial load time. Current: 3 seconds. 
Target: under 1 second. Walk through optimization strategies.
```

#### 2. Provide Context

**✅ Good Context:**
```
My eShopLite Blazor Server app uses:
- .NET 10
- SQLite database
- Bootstrap 5 UI
- 9 products, 2 stores
- Deployed to Azure App Service

Problem: Slow product page rendering
```

#### 3. Break Down Complex Problems

Instead of:
```
Fix everything wrong with my app
```

Use sequential questions:
```
1. First, help me identify performance bottlenecks
2. Then, prioritize which to fix first
3. Finally, create a step-by-step fix plan
```

#### 4. Review Saved Thoughts

```powershell
# List all saved thoughts
Get-ChildItem .mcp\thoughts -Recurse

# View a specific thought file
Get-Content .mcp\thoughts\architecture-decision-20260103.json | ConvertFrom-Json
```

### Benefits for Your eShopLite Project

**Architecture Decisions:**
- ✅ Monolith vs microservices evaluation
- ✅ Database choice (SQLite vs SQL Server vs Cosmos)
- ✅ Caching strategy
- ✅ Deployment approach

**Code Quality:**
- ✅ Refactoring planning
- ✅ Code review assistance
- ✅ Technical debt prioritization
- ✅ Testing strategy

**Performance:**
- ✅ Bottleneck identification
- ✅ Optimization sequencing
- ✅ Trade-off analysis
- ✅ Measurement approach

**Debugging:**
- ✅ Systematic problem isolation
- ✅ Root cause analysis
- ✅ Fix verification
- ✅ Prevention strategies

---

## Verification & Testing

### Step 1: Check Node.js

```powershell
node --version
npm --version
```

Both should return version numbers.

### Step 2: Test npx Access

```powershell
npx --version
```

Should work without errors.

### Step 3: Create Thoughts Directory

```powershell
New-Item -ItemType Directory -Force -Path ".mcp\thoughts"
Test-Path ".mcp\thoughts"
```

Should return `True`.

### Step 4: Copy Configuration

```powershell
# Create GitHub Copilot config directory
New-Item -ItemType Directory -Force -Path "$env:APPDATA\GitHub Copilot"

# Copy your config
Copy-Item eShopLite-mcp-config.json "$env:APPDATA\GitHub Copilot\mcp-settings.json"
```

### Step 5: Restart Visual Studio

Close and reopen Visual Studio completely.

### Step 6: Test Microsoft Learn MCP

In GitHub Copilot Chat, ask:
```
What are the new features in .NET 10?
```

You should get detailed, accurate results from Microsoft Learn.

### Step 7: Test Sequential Thinking MCP

Ask:
```
Help me think through whether I should deploy my eShopLite app 
to Azure App Service or Azure Container Apps. Consider cost, 
scalability, and ease of management.
```

You should see a step-by-step reasoning process.

---

## Troubleshooting

### Issue: "node is not recognized"

**Cause:** Node.js not installed or not in PATH

**Fix:**
```powershell
# Install Node.js
winget install OpenJS.NodeJS.LTS

# Restart terminal
# Verify
node --version
```

### Issue: "npx not found"

**Cause:** npm not installed with Node.js

**Fix:**
```powershell
# Reinstall Node.js
winget uninstall OpenJS.NodeJS.LTS
winget install OpenJS.NodeJS.LTS

# Or update npm
npm install -g npm@latest
```

### Issue: "Cannot find module '@modelcontextprotocol/server-microsoft-learn'"

**Cause:** First-time download taking longer than expected

**Fix:**
```powershell
# Pre-install the packages
npx -y @modelcontextprotocol/server-microsoft-learn --help
npx -y @modelcontextprotocol/server-sequential-thinking --help

# Restart Visual Studio
```

### Issue: "Thoughts directory not found"

**Cause:** Directory not created or wrong path

**Fix:**
```powershell
# Navigate to workspace root
cd "C:\Users\prath\OneDrive\Documents\GitHub Copilot\Source\2-upgrade-dotnet\2-upgrade-with-ghcp-modernization-app\StartSample"

# Create directory
New-Item -ItemType Directory -Force -Path ".mcp\thoughts"

# Verify
Test-Path ".mcp\thoughts"
```

### Issue: "MCP servers not loading"

**Cause:** Configuration file syntax error or location wrong

**Fix:**
```powershell
# Verify JSON syntax
Get-Content eShopLite-mcp-config.json | ConvertFrom-Json

# Check file location
$configPath = "$env:APPDATA\GitHub Copilot\mcp-settings.json"
Test-Path $configPath
Get-Content $configPath

# Copy again if needed
Copy-Item eShopLite-mcp-config.json $configPath -Force
```

### Issue: "Sequential thinking not persisting"

**Cause:** Thoughts directory permissions or path issue

**Fix:**
```powershell
# Check directory permissions
Get-Acl ".mcp\thoughts"

# Ensure writable
icacls ".mcp\thoughts" /grant "${env:USERNAME}:(OI)(CI)F"

# Test write
"test" | Out-File ".mcp\thoughts\test.txt"
```

---

## Advanced Configuration

### Adjust Thinking Budget

For faster responses (less thorough):
```json
{
  "thinkingBudget": 10000  // Reduce for speed
}
```

For more thorough analysis:
```json
{
  "thinkingBudget": 40000  // Increase for depth
}
```

### Disable Persistence (Privacy)

```json
{
  "enablePersistedThinking": false  // Don't save thoughts
}
```

### Change Thought Location

```json
{
  "thoughtDirectory": "C:/Users/prath/Documents/copilot-thoughts"
}
```

### Focus Microsoft Learn Search

```json
{
  "preferredTopics": [
    "Blazor Performance",
    "Entity Framework Optimization",
    "Azure Deployment"
  ]
}
```

---

## .gitignore Configuration

Add to your `.gitignore`:

```gitignore
# MCP Thoughts (may contain sensitive info)
.mcp/
*.thought.json

# MCP Configuration (contains tokens)
mcp-settings.json
```

---

## Usage Tips

### For Microsoft Learn MCP:

**Be Specific:**
```
❌ "Tell me about Blazor"
✅ "What are Blazor Server performance best practices in .NET 10?"
```

**Request Examples:**
```
✅ "Show me code examples for Blazor form validation"
```

**Ask for Latest Info:**
```
✅ "What's new in Entity Framework Core for .NET 10?"
```

### For Sequential Thinking MCP:

**Frame as Multi-Step:**
```
✅ "Help me think through: 1) Current architecture issues, 
   2) Proposed solutions, 3) Implementation plan, 4) Risk mitigation"
```

**Provide Constraints:**
```
✅ "Consider: Budget < $100/month, Team size = 2 developers, 
   Deployment = Azure, Timeline = 2 weeks"
```

**Ask for Reasoning:**
```
✅ "Explain your thinking process as you evaluate these options"
```

---

## Benefits Combined

Using **both** servers together:

**Microsoft Learn MCP** provides:
- Latest documentation
- Official examples
- Best practices
- API references

**Sequential Thinking MCP** provides:
- Structured analysis
- Multi-step reasoning
- Trade-off evaluation
- Persistent decisions

**Together they enable:**
1. **Research** (Microsoft Learn) → Latest information
2. **Analysis** (Sequential Thinking) → Evaluate options
3. **Decision** (Combined) → Make informed choice
4. **Implementation** (Microsoft Learn) → Apply best practices
5. **Review** (Sequential Thinking) → Verify approach

---

## Real-World Example

**Scenario:** You need to improve eShopLite performance

**Step 1: Research** (Microsoft Learn)
```
What are the best practices for Blazor Server performance in .NET 10?
```
→ Gets official Microsoft recommendations

**Step 2: Analyze** (Sequential Thinking)
```
Help me analyze my app's performance bottlenecks step-by-step:
- Current metrics: 3s load time
- Bottlenecks: Database queries, image loading, CSS/JS
- Constraints: SQLite database, Azure App Service Basic tier
```
→ Methodical analysis with reasoning

**Step 3: Plan** (Sequential Thinking)
```
Create a prioritized optimization plan considering:
- Impact vs effort
- Risk level
- Dependencies
- Testing approach
```
→ Structured implementation plan

**Step 4: Implement** (Microsoft Learn)
```
Show me code examples for:
- Lazy loading Blazor components
- Image optimization in ASP.NET Core
- SQLite query optimization
```
→ Official code samples

**Step 5: Verify** (Sequential Thinking)
```
Review my optimization results:
- Before: 3s load time
- After: 1.2s load time
- Changes made: [list]
Should I continue optimization or focus elsewhere?
```
→ Reasoned next steps

---

## Summary

### Microsoft Learn MCP
- ✅ Installed via: `npx @modelcontextprotocol/server-microsoft-learn`
- ✅ Configuration: Already in `eShopLite-mcp-config.json`
- ✅ Usage: Ask specific questions about Microsoft technologies
- ✅ Benefits: Latest docs, official examples, best practices

### Sequential Thinking MCP
- ✅ Installed via: `npx @modelcontextprotocol/server-sequential-thinking`
- ✅ Configuration: Already in `eShopLite-mcp-config.json`
- ✅ Requires: `.mcp/thoughts` directory
- ✅ Usage: Complex problem-solving, architecture decisions
- ✅ Benefits: Multi-step reasoning, persistent state, structured analysis

### Quick Start Checklist

- [ ] Verify Node.js installed: `node --version`
- [ ] Create thoughts directory: `New-Item -ItemType Directory -Force -Path ".mcp\thoughts"`
- [ ] Copy config: `Copy-Item eShopLite-mcp-config.json "$env:APPDATA\GitHub Copilot\mcp-settings.json"`
- [ ] Restart Visual Studio
- [ ] Test Microsoft Learn: Ask about .NET 10 features
- [ ] Test Sequential Thinking: Ask for architecture advice
- [ ] Review persisted thoughts: Check `.mcp/thoughts/`

**Your eShopLite project now has access to both official Microsoft documentation 
and advanced reasoning capabilities!** 🚀
