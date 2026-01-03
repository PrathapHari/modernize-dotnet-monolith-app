# 🎉 Visual Studio Multi-Project Startup - COMPLETE!

## ✅ What I've Configured

I've set up your Visual Studio solution to automatically start **all 3 microservices** when you press F5:

1. **Products API** (port 7001)
2. **StoreInfo API** (port 7002)  
3. **Store UI** (port 63769)

---

## 📁 Files Created

| File | Purpose |
|------|---------|
| `eShopLiteFx.slnLaunch` | Solution-level multi-project configuration |
| `.vs/eShopLiteFx/launchSettings.json` | Launch profiles for each service |
| `VISUAL_STUDIO_MULTI_PROJECT_SETUP.md` | Comprehensive setup documentation |
| `QUICK_START_VISUAL_STUDIO.md` | Quick reference guide with visuals |

---

## 🚀 How to Use (3 Simple Steps)

### Step 1: Close & Reopen Visual Studio

Close Visual Studio completely and reopen the solution:
```
eShopLiteFx.sln
```

### Step 2: Configure Multiple Startup Projects

1. Right-click **Solution 'eShopLiteFx'** in Solution Explorer
2. Select **"Configure Startup Projects..."**
3. Choose **"Multiple startup projects"**
4. Set all 3 projects to **"Start"**:
   - ✅ eShopLite.Products → **Start**
   - ✅ eShopLite.StoreInfo → **Start**
   - ✅ eShopLite.Store → **Start**
5. Click **OK**

### Step 3: Press F5

Press **F5** or click the green ▶ **Start** button.

Visual Studio will:
- ✅ Build all projects
- ✅ Start all 3 services
- ✅ Open browser to Store UI
- ✅ Attach debugger to all processes

---

## 🎯 What You'll See

### 3 Console Windows:
```
┌─────────────────────────┐
│ Products API            │
│ Port: 7001              │
└─────────────────────────┘

┌─────────────────────────┐
│ StoreInfo API           │
│ Port: 7002              │
└─────────────────────────┘

┌─────────────────────────┐
│ Store UI (Blazor)       │
│ Port: 63769             │
└─────────────────────────┘
```

### 1 Browser Window:
```
Opens to: http://localhost:63769

You'll see the Store UI with:
- ✅ Home page
- ✅ Products navigation (click to see 9 products)
- ✅ Stores navigation (click to see 9 stores)
```

---

## ✅ Testing Checklist

After pressing F5, verify:

- [ ] **3 console windows open** (one for each service)
- [ ] **Browser opens** automatically to `http://localhost:63769`
- [ ] **Home page loads** without errors
- [ ] **Click "Products"** → See 9 product cards displayed
- [ ] **Click "Stores"** → See 9 store listings displayed
- [ ] **No error messages** in the browser or console windows

---

## 🐛 Debugging Features

With all services running, you can:

### Set Breakpoints Anywhere:
- **Store UI** - Blazor components and API clients
- **Products API** - Endpoints and data access
- **StoreInfo API** - Endpoints and data access

### Step Through Code:
- Start in Store UI → Step into API call → Debug API endpoint
- Full stack debugging across all 3 projects!

### Stop All Services:
Press **Shift + F5** to stop all services at once.

---

## 📊 Architecture Overview

```
┌──────────────────────────────────────────────┐
│         Visual Studio Debugger               │
│  (Attached to all 3 processes)               │
└───┬─────────────┬──────────────┬─────────────┘
    │             │              │
    ▼             ▼              ▼
┌─────────┐  ┌──────────┐  ┌──────────┐
│Products │  │StoreInfo │  │Store UI  │
│  API    │  │   API    │  │ (Blazor) │
│  7001   │  │   7002   │  │  63769   │
└─────────┘  └──────────┘  └──────────┘
     ▲            ▲              │
     │            │              │
     └────────────┴──────────────┘
        API calls from Store UI
```

---

## 🎓 Learning Resources

| Document | Description |
|----------|-------------|
| `QUICK_START_VISUAL_STUDIO.md` | Visual quick start guide |
| `VISUAL_STUDIO_MULTI_PROJECT_SETUP.md` | Complete setup documentation |
| `SERVICES_STATUS_AND_FIX.md` | Troubleshooting services |
| `PRODUCTS_API_FIX.md` | Port configuration details |

---

## 🔧 Alternative Methods

### Don't want to use Visual Studio multi-project?

Use PowerShell scripts instead:

```powershell
# Start all services in separate windows
.\start-all-services.ps1

# Check which services are running
.\check-and-start-services.ps1

# Test all services are responding
.\test-all-services.ps1
```

---

## 💡 Pro Tips

### Tip 1: Viewing Logs
- **View → Output** in Visual Studio
- Select **Debug** from dropdown
- See logs from all running services

### Tip 2: Restarting a Single Service
- Right-click the project
- **Debug → Start New Instance**
- Other services keep running

### Tip 3: Custom Launch Profiles
- Each project has its own `launchSettings.json`
- Located in `Properties/launchSettings.json`
- Customize ports, environment variables, etc.

### Tip 4: Default Browser
- Visual Studio → **Tools → Options**
- **Projects and Solutions → Web Projects**
- Choose default browser for debugging

---

## 🎯 Next Steps

1. ✅ **Close Visual Studio**
2. ✅ **Reopen** `eShopLiteFx.sln`
3. ✅ **Right-click Solution** → Configure Startup Projects
4. ✅ **Set all to Start**
5. ✅ **Press F5**
6. ✅ **Wait 10-15 seconds**
7. ✅ **Start developing!**

---

## 📞 Troubleshooting

### Problem: Nothing happens when I press F5

**Solution:**
- Check Solution Properties → Multiple startup projects
- Verify all 3 projects are set to "Start"

### Problem: Only one service starts

**Solution:**
- Right-click Solution → Configure Startup Projects
- Change from "Single startup project" to "Multiple startup projects"

### Problem: Port conflicts

**Solution:**
```powershell
# Kill processes using the ports
Get-NetTCPConnection -LocalPort 7001,7002,63769 | 
  ForEach-Object { Stop-Process -Id $_.OwningProcess -Force }
```

---

## ✨ Success!

You're now ready to:
- 🚀 Start all services with one click (F5)
- 🐛 Debug across all 3 microservices
- 🎯 Develop with a smooth workflow
- ⚡ No manual service management needed!

---

**Status**: ✅ Configuration Complete  
**Ready to Use**: Press F5 to start all services!  
**Documentation**: See `QUICK_START_VISUAL_STUDIO.md` for detailed guide

🎉 **Happy Coding!**
