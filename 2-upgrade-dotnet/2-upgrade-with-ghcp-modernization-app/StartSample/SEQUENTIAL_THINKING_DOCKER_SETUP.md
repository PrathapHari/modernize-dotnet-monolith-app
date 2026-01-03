# Sequential Thinking MCP - Docker Setup Guide

## Overview

This guide covers running the Sequential Thinking MCP server using Docker instead of npx/Node.js.

## Why Use Docker?

**Benefits:**
- ✅ No Node.js installation required
- ✅ Isolated environment (no dependency conflicts)
- ✅ Consistent behavior across machines
- ✅ Easy to update (just pull new image)
- ✅ Better resource management

**Trade-offs:**
- ⚠️ Requires Docker Desktop installed
- ⚠️ Slightly slower startup (container initialization)
- ⚠️ Uses more disk space (Docker image)

---

## Prerequisites

### 1. Install Docker Desktop

**Check if Docker is installed:**
```powershell
docker --version
```

**If not installed:**

**Option A: Using winget (recommended)**
```powershell
winget install Docker.DockerDesktop
```

**Option B: Manual download**
1. Download from: https://www.docker.com/products/docker-desktop/
2. Run installer
3. Follow setup wizard
4. Restart computer if prompted

**After installation:**
1. Launch Docker Desktop
2. Wait for Docker Engine to start (whale icon in system tray)
3. Verify: `docker --version`

### 2. Verify Docker is Running

```powershell
# Check Docker service status
docker info

# Should show: Server Version, Storage Driver, etc.
```

---

## Docker Configuration Explained

### Current Configuration

```json
{
  "sequential-thinking": {
    "type": "stdio",
    "enabled": true,
    "command": "docker",
    "args": [
      "run",
      "-i",
      "--rm",
      "-v",
      "${workspaceFolder}/.mcp/thoughts:/thoughts",
      "mcp/sequentialthinking"
    ],
    "env": {
      "THINKING_BUDGET": "20000",
      "ENABLE_PERSISTED_THINKING": "true",
      "THOUGHT_DIRECTORY": "/thoughts"
    }
  }
}
```

### Arguments Breakdown

**`docker run`**
- Starts a new container

**`-i`** (interactive)
- Keeps STDIN open for communication
- Required for MCP stdio protocol

**`--rm`**
- Automatically removes container when it stops
- Prevents container accumulation
- Saves disk space

**`-v ${workspaceFolder}/.mcp/thoughts:/thoughts`**
- **Volume mount** for persistent storage
- Maps local `.mcp/thoughts` to container's `/thoughts`
- Allows thoughts to persist after container stops
- `${workspaceFolder}` automatically resolves to your workspace path

**`mcp/sequentialthinking`**
- Docker image name
- Official MCP Sequential Thinking image
- Will be pulled automatically on first run

### Environment Variables

**`THINKING_BUDGET: "20000"`**
- Controls reasoning depth
- Higher = more thorough analysis
- Default: 20000
- Range: 5000 (quick) to 50000 (very deep)

**`ENABLE_PERSISTED_THINKING: "true"`**
- Saves reasoning state to disk
- Allows multi-session problems
- Uses mounted volume path

**`THOUGHT_DIRECTORY: "/thoughts"`**
- Where thoughts are saved **inside container**
- Mapped to `.mcp/thoughts` on your machine via volume mount

---

## Setup Steps

### Step 1: Create Thoughts Directory

```powershell
# Navigate to workspace root
cd "C:\Users\prath\OneDrive\Documents\GitHub Copilot\Source\2-upgrade-dotnet\2-upgrade-with-ghcp-modernization-app\StartSample"

# Create directory
New-Item -ItemType Directory -Force -Path ".mcp\thoughts"

# Verify
Test-Path ".mcp\thoughts"
# Should return: True
```

### Step 2: Pull Docker Image (Optional but Recommended)

Pre-download the image to avoid delays on first use:

```powershell
docker pull mcp/sequentialthinking:latest
```

**Expected output:**
```
latest: Pulling from mcp/sequentialthinking
[various layers downloading...]
Status: Downloaded newer image for mcp/sequentialthinking:latest
```

### Step 3: Test Docker Image

```powershell
# Test the image runs
docker run --rm mcp/sequentialthinking --version

# Should show version info
```

### Step 4: Copy Configuration

```powershell
# Create GitHub Copilot config directory
New-Item -ItemType Directory -Force -Path "$env:APPDATA\GitHub Copilot"

# Copy your config
Copy-Item eShopLite-mcp-config.json "$env:APPDATA\GitHub Copilot\mcp-settings.json" -Force
```

### Step 5: Restart Visual Studio

Close Visual Studio completely and reopen it.

---

## Verification

### Test 1: Check Docker is Running

```powershell
docker ps
```

Should show Docker is operational (may show empty list if no containers running).

### Test 2: Test Container Manually

```powershell
# Run container interactively
docker run -i --rm -v "${PWD}/.mcp/thoughts:/thoughts" mcp/sequentialthinking
```

Press `Ctrl+C` to exit.

### Test 3: Test in GitHub Copilot

In GitHub Copilot Chat, ask:

```
Help me think through whether to deploy my eShopLite app to Azure App Service 
or Azure Container Apps. Consider:
- Current architecture: Blazor Server + SQLite
- Expected traffic: 100-500 users/day
- Budget: < $50/month
- Team: 2 developers
```

You should see step-by-step reasoning.

### Test 4: Verify Thoughts are Persisted

```powershell
# List saved thoughts
Get-ChildItem .mcp\thoughts -Recurse

# Should show .json files with timestamps
```

---

## Docker Image Management

### Check Current Images

```powershell
docker images | Select-String "mcp"
```

**Expected:**
```
mcp/sequentialthinking   latest   abc123...   2 weeks ago   150MB
```

### Update to Latest Version

```powershell
# Pull latest version
docker pull mcp/sequentialthinking:latest

# Remove old versions (optional)
docker image prune -a
```

### Remove Image (if needed)

```powershell
# Stop any running containers first
docker stop $(docker ps -q --filter ancestor=mcp/sequentialthinking)

# Remove image
docker rmi mcp/sequentialthinking:latest
```

---

## Troubleshooting

### Issue: "docker: command not found"

**Cause:** Docker Desktop not installed or not in PATH

**Fix:**
```powershell
# Install Docker Desktop
winget install Docker.DockerDesktop

# Restart terminal
# Launch Docker Desktop
# Wait for engine to start

# Verify
docker --version
```

### Issue: "error during connect: This error may indicate that the docker daemon is not running"

**Cause:** Docker Desktop not running

**Fix:**
1. Launch **Docker Desktop** from Start Menu
2. Wait for whale icon to appear in system tray
3. Icon should be solid (not animated)
4. Verify: `docker info`

### Issue: "Cannot bind mount volume: path does not exist"

**Cause:** `.mcp/thoughts` directory doesn't exist

**Fix:**
```powershell
# Create directory
New-Item -ItemType Directory -Force -Path ".mcp\thoughts"

# Verify
Test-Path ".mcp\thoughts"
```

### Issue: "permission denied while trying to connect to Docker daemon"

**Cause:** Docker requires admin privileges or user not in docker-users group

**Fix:**

**On Windows:**
1. Run Docker Desktop as Administrator (first time)
2. Or add your user to `docker-users` group:
   ```powershell
   # Run as Administrator
   net localgroup docker-users "$env:USERNAME" /add
   ```
3. Logout and login again

### Issue: "Error response from daemon: pull access denied"

**Cause:** Image name incorrect or doesn't exist

**Fix:**

Check official MCP repository for correct image name:
```powershell
# Try alternative image names
docker pull ghcr.io/modelcontextprotocol/server-sequential-thinking:latest

# Or use npx instead (see Alternative Setup below)
```

### Issue: Container starts but MCP doesn't respond

**Cause:** Volume mount path issue on Windows

**Fix:**

Use explicit path instead of `${workspaceFolder}`:

```json
{
  "args": [
    "run",
    "-i",
    "--rm",
    "-v",
    "C:/Users/prath/OneDrive/Documents/GitHub Copilot/Source/2-upgrade-dotnet/2-upgrade-with-ghcp-modernization-app/StartSample/.mcp/thoughts:/thoughts",
    "mcp/sequentialthinking"
  ]
}
```

**Note:** Use forward slashes `/` in path, even on Windows!

### Issue: "OCI runtime create failed"

**Cause:** Resource limits or WSL2 issue

**Fix:**
```powershell
# Restart Docker Desktop
# Increase Docker Desktop resources:
# Docker Desktop → Settings → Resources → Advanced
# - CPUs: 2+ cores
# - Memory: 4+ GB
# - Disk: 10+ GB
```

---

## Alternative: Using npx Instead of Docker

If Docker causes issues, you can switch back to npx:

```json
{
  "sequential-thinking": {
    "type": "stdio",
    "enabled": true,
    "command": "npx",
    "args": [
      "-y",
      "@modelcontextprotocol/server-sequential-thinking"
    ],
    "configuration": {
      "thinkingBudget": 20000,
      "enablePersistedThinking": true,
      "thoughtDirectory": "./.mcp/thoughts"
    }
  }
}
```

**Prerequisites for npx:**
- Node.js 18+ installed: `winget install OpenJS.NodeJS.LTS`
- Verify: `node --version` and `npx --version`

---

## Performance Comparison

| Aspect | Docker | npx |
|--------|--------|-----|
| **Startup Time** | ~2-3 seconds | ~1 second |
| **Isolation** | Full isolation | Shared with system |
| **Dependencies** | Self-contained | Requires Node.js |
| **Updates** | `docker pull` | `npx` auto-updates |
| **Resource Usage** | ~100-200MB RAM | ~50-100MB RAM |
| **Reliability** | Very reliable | Depends on npm/node |
| **Cross-platform** | Identical everywhere | May vary by OS |

---

## Advanced Configuration

### Custom Docker Image Build

If you need to customize the Sequential Thinking server:

**1. Create Dockerfile:**

```dockerfile
# Dockerfile
FROM node:18-alpine

WORKDIR /app

RUN npm install -g @modelcontextprotocol/server-sequential-thinking

EXPOSE 3000

ENV THINKING_BUDGET=20000
ENV ENABLE_PERSISTED_THINKING=true
ENV THOUGHT_DIRECTORY=/thoughts

VOLUME ["/thoughts"]

ENTRYPOINT ["sequential-thinking-server"]
```

**2. Build image:**

```powershell
docker build -t my-sequential-thinking:latest .
```

**3. Update configuration:**

```json
{
  "args": [
    "run",
    "-i",
    "--rm",
    "-v",
    "${workspaceFolder}/.mcp/thoughts:/thoughts",
    "my-sequential-thinking:latest"
  ]
}
```

### Docker Compose Alternative

For easier management, use Docker Compose:

**docker-compose.yml:**

```yaml
version: '3.8'

services:
  sequential-thinking:
    image: mcp/sequentialthinking:latest
    stdin_open: true
    tty: true
    volumes:
      - ./.mcp/thoughts:/thoughts
    environment:
      - THINKING_BUDGET=20000
      - ENABLE_PERSISTED_THINKING=true
      - THOUGHT_DIRECTORY=/thoughts
    restart: unless-stopped
```

**Run:**

```powershell
docker-compose up -d
```

---

## Security Considerations

### Volume Mount Security

**✅ Safe:**
- Mount only `.mcp/thoughts` directory (limited scope)
- Read-only mount if not persisting: `-v ${PWD}/.mcp/thoughts:/thoughts:ro`

**❌ Avoid:**
- Mounting entire workspace: `-v ${PWD}:/workspace` (too broad)
- Mounting system directories: `-v C:\:/host` (dangerous)

### Network Isolation

The current configuration uses:
- **No network exposure** (`--network none` not specified, but no ports published)
- **STDIO communication only** (secure pipe)
- **No external connections** (container can't access internet)

To explicitly disable network:

```json
{
  "args": [
    "run",
    "-i",
    "--rm",
    "--network",
    "none",
    "-v",
    "${workspaceFolder}/.mcp/thoughts:/thoughts",
    "mcp/sequentialthinking"
  ]
}
```

### Secrets Management

**Don't include sensitive data in thoughts:**
- API keys
- Passwords
- Personal information
- Internal URLs

Add to `.gitignore`:

```gitignore
.mcp/thoughts/**/*.json
.mcp/thoughts/
```

---

## Monitoring & Debugging

### View Docker Logs

```powershell
# List running containers
docker ps

# View logs for specific container
docker logs <container-id>

# Follow logs in real-time
docker logs -f <container-id>
```

### Inspect Container

```powershell
# View container details
docker inspect <container-id>

# View mounted volumes
docker inspect <container-id> | Select-String "Mounts" -Context 10
```

### Debug Volume Mount

```powershell
# Check what's in the mounted volume
docker run --rm -v "${PWD}/.mcp/thoughts:/thoughts" alpine ls -la /thoughts
```

### Resource Usage

```powershell
# View resource usage
docker stats

# View disk usage
docker system df
```

---

## Cleanup

### Stop Running Containers

```powershell
# Stop all sequential-thinking containers
docker stop $(docker ps -q --filter ancestor=mcp/sequentialthinking)

# Or stop all containers
docker stop $(docker ps -q)
```

### Remove Old Containers

```powershell
# Remove stopped containers
docker container prune

# Remove all stopped containers (confirm prompt)
docker rm $(docker ps -a -q)
```

### Clean Up Disk Space

```powershell
# Remove unused images
docker image prune -a

# Remove everything (images, containers, volumes)
docker system prune -a --volumes

# WARNING: This removes ALL Docker data!
```

---

## Quick Reference

### Essential Commands

```powershell
# Check Docker is running
docker info

# Pull latest image
docker pull mcp/sequentialthinking:latest

# Run container manually (testing)
docker run -i --rm -v "${PWD}/.mcp/thoughts:/thoughts" mcp/sequentialthinking

# List running containers
docker ps

# View logs
docker logs <container-id>

# Stop container
docker stop <container-id>

# Remove image
docker rmi mcp/sequentialthinking:latest

# Clean up
docker system prune
```

### File Locations

**Configuration:**
- `$env:APPDATA\GitHub Copilot\mcp-settings.json`

**Thoughts Directory:**
- Workspace: `.mcp/thoughts/`
- Inside Container: `/thoughts/`

**Docker Images:**
- Windows: `C:\ProgramData\DockerDesktop\`
- WSL2: `/var/lib/docker/`

---

## Summary

### Docker Setup Checklist

- [ ] Install Docker Desktop: `winget install Docker.DockerDesktop`
- [ ] Launch Docker Desktop and wait for engine to start
- [ ] Verify Docker: `docker --version` and `docker info`
- [ ] Create thoughts directory: `New-Item -ItemType Directory -Force -Path ".mcp\thoughts"`
- [ ] Pull image: `docker pull mcp/sequentialthinking:latest`
- [ ] Update `eShopLite-mcp-config.json` with Docker configuration
- [ ] Copy to Copilot config: `Copy-Item eShopLite-mcp-config.json "$env:APPDATA\GitHub Copilot\mcp-settings.json"`
- [ ] Restart Visual Studio
- [ ] Test with complex question in Copilot Chat
- [ ] Verify thoughts saved: `Get-ChildItem .mcp\thoughts`

### Comparison: Docker vs npx

**Use Docker if:**
- ✅ You want isolated environments
- ✅ You don't want to install Node.js
- ✅ You need reproducible behavior
- ✅ You're already using Docker

**Use npx if:**
- ✅ You want faster startup
- ✅ You already have Node.js installed
- ✅ You want automatic updates
- ✅ You prefer simplicity

---

## Next Steps

1. **If Docker is working:** Continue with current configuration
2. **If Docker has issues:** Switch to npx configuration
3. **Test the server:** Ask complex multi-step questions
4. **Review thoughts:** Check `.mcp/thoughts/` directory
5. **Optimize settings:** Adjust `THINKING_BUDGET` based on needs

**Your Sequential Thinking MCP is now ready with Docker!** 🐳🚀
