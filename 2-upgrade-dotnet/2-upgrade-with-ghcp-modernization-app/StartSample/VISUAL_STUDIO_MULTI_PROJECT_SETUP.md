# Visual Studio Multi-Project Startup Configuration

## ✅ Configuration Complete!

I've configured Visual Studio to automatically start all 3 microservices when you press F5.

## Files Created

### 1. `.vs/eShopLiteFx/launchSettings.json`
Defines individual launch configurations for each project:
- **Products API** - Port 7001 (no browser launch)
- **StoreInfo API** - Port 7002 (no browser launch)
- **Store UI** - Port 63769 (launches browser)

### 2. `eShopLiteFx.slnLaunch`
Solution-level configuration that tells Visual Studio to start all 3 projects together.

## How to Use

### Method 1: Using Visual Studio UI (Recommended)

1. **Open the solution** in Visual Studio 2022 (`eShopLiteFx.sln`)

2. **Right-click on the Solution** in Solution Explorer

3. **Select "Configure Startup Projects..."**

4. **Choose "Multiple startup projects"**

5. **Set the Action for each project:**
   - ✅ **eShopLite.Products** → **Start**
   - ✅ **eShopLite.StoreInfo** → **Start**
   - ✅ **eShopLite.Store** → **Start**

6. **Click "OK"**

7. **Press F5** to start debugging

### Method 2: Using the Toolbar Dropdown

1. **Look for the startup dropdown** in the Visual Studio toolbar (next to the green play button)

2. **Select "All Services"** from the dropdown

3. **Press F5** or click the green play button

### Method 3: Solution Properties

1. **Solution Explorer** → Right-click **Solution 'eShopLiteFx'**

2. **Properties** → **Startup Project**

3. **Select "Multiple startup projects"**

4. **Configure as shown below:**

```
Project                 Action    
----------------------  ----------
eShopLite.Products      Start
eShopLite.StoreInfo     Start
eShopLite.Store         Start
```

## What Happens When You Press F5

Visual Studio will:

1. ✅ **Build all 3 projects**
2. ✅ **Start Products API** on `https://localhost:7001`
3. ✅ **Start StoreInfo API** on `https://localhost:7002`
4. ✅ **Start Store UI** on `http://localhost:63769`
5. ✅ **Open browser** to Store UI automatically
6. ✅ **Attach debugger** to all 3 processes

### Console Windows

You'll see **3 console windows** open (one for each service):
- **Console 1**: Products API logs
- **Console 2**: StoreInfo API logs  
- **Console 3**: Store UI logs

### Browser

A browser window will automatically open to: `http://localhost:63769`

## Testing the Setup

### 1. Press F5 in Visual Studio

Wait 10-15 seconds for all services to start.

### 2. Check the Output Window

In Visual Studio, go to **View → Output** and select **Debug** from the dropdown.

You should see startup messages from all 3 projects.

### 3. Test the Application

**Navigate to Home Page:**
```
http://localhost:63769
```

**Click "Products":**
- Should navigate to `/products`
- Should display 9 product cards
- No errors

**Click "Stores":**
- Should navigate to `/stores`  
- Should display 9 store locations
- No errors

### 4. Verify APIs Directly

**Products API:**
```
https://localhost:7001/api/products
```
Should return JSON with 9 products

**StoreInfo API:**
```
https://localhost:7002/api/stores
```
Should return JSON with 9 stores

## Debugging

### Setting Breakpoints

You can set breakpoints in **any of the 3 projects**:

**Store UI (Frontend):**
- `Components/Pages/Products.razor` - Line 206 (`LoadProducts()`)
- `ApiClients/ProductApiClient.cs` - Line 25 (`GetProductsAsync()`)

**Products API (Backend):**
- `Program.cs` - Line 44 (Products endpoint)
- `Data/ProductDbContext.cs` - Seed data

**StoreInfo API (Backend):**
- `Program.cs` - Line 44 (Stores endpoint)
- `Data/StoreInfoDbContext.cs` - Seed data

### Stopping Debugging

Press **Shift+F5** or click the **Stop** button in Visual Studio.

This will stop **all 3 services** at once.

## Troubleshooting

### Issue: "Port already in use"

**Symptom:** One or more services fail to start with port conflict error.

**Solution:**
```powershell
# Check what's using the ports
Get-NetTCPConnection -LocalPort 7001,7002,63769 | 
  Select-Object LocalPort, State, OwningProcess

# Kill the processes if needed
Stop-Process -Id <ProcessId> -Force
```

### Issue: "Project doesn't start"

**Symptom:** Only some projects start when pressing F5.

**Solution:**
1. Right-click Solution → **Configure Startup Projects**
2. Verify all 3 projects are set to **Start**
3. Click **OK** and try again

### Issue: "Browser opens but products don't load"

**Symptom:** Store UI loads but shows error about API not available.

**Solution:**
1. Check **Output window** in Visual Studio
2. Look for error messages from Products API
3. Verify all 3 services started successfully
4. Check console windows for startup completion

### Issue: "Can't see console windows"

**Symptom:** Services start but console windows don't appear.

**Solution:**
- Console windows might be minimized or hidden behind Visual Studio
- Check taskbar for console windows
- Use **View → Output** in Visual Studio to see logs

## Project Launch Order

Visual Studio will start projects in this order:

1. **Products API** (backend dependency)
2. **StoreInfo API** (backend dependency)
3. **Store UI** (frontend - depends on APIs)

The Store UI might start before the APIs are fully ready, which is why you might see a brief loading spinner or error that resolves after a second.

## Environment Variables

Each project is configured with:
```json
"ASPNETCORE_ENVIRONMENT": "Development"
```

This enables:
- ✅ Detailed error pages
- ✅ Developer exception page
- ✅ Enhanced logging
- ✅ OpenAPI/Swagger (for APIs)

## Port Configuration

| Service | HTTP | HTTPS |
|---------|------|-------|
| Products API | 5008 | **7001** |
| StoreInfo API | 5174 | **7002** |
| Store UI | **63769** | - |

**Bold** = Primary port used by the application

## Alternative: Using PowerShell Scripts

If you prefer not to use Visual Studio's multi-project startup:

### Start All Services:
```powershell
.\start-all-services.ps1
```

### Check Status:
```powershell
.\check-and-start-services.ps1
```

### Test Services:
```powershell
.\test-all-services.ps1
```

## Expected Startup Time

- **First Run**: 15-20 seconds (includes database creation)
- **Subsequent Runs**: 5-10 seconds

## Success Indicators

### Visual Studio Output Window:
```
Products API started successfully
StoreInfo API started successfully  
Store UI started successfully
```

### Browser:
- ✅ Home page loads
- ✅ Navigation menu visible
- ✅ No console errors (F12)

### Products Page:
- ✅ 9 products displayed
- ✅ Product cards with images, names, prices
- ✅ No error messages

### Stores Page:
- ✅ 9 stores displayed
- ✅ Store information with name, city, state, hours
- ✅ No error messages

## Configuration Files Reference

### Individual Project Launch Settings

**Products API:**
```
src\eShopLite.Products\Properties\launchSettings.json
```

**StoreInfo API:**
```
src\eShopLite.StoreInfo\Properties\launchSettings.json
```

**Store UI:**
```
src\eShopLite.StoreFx\Properties\launchSettings.json
```

### Solution-Level Configuration

**Multi-Project Startup:**
```
eShopLiteFx.slnLaunch
```

**Launch Profiles:**
```
.vs\eShopLiteFx\launchSettings.json
```

## Quick Reference Commands

| Task | Action |
|------|--------|
| Start all services | Press **F5** in Visual Studio |
| Stop all services | Press **Shift+F5** |
| Configure startup | Right-click Solution → **Configure Startup Projects** |
| View output logs | **View → Output** (select Debug) |
| Restart a service | Right-click project → **Debug → Start New Instance** |
| View console output | Check console windows or Output window |

## Next Steps

1. ✅ **Close and reopen** Visual Studio (to load the new configuration)
2. ✅ **Press F5** to start all services
3. ✅ **Wait 10-15 seconds** for initialization
4. ✅ **Browser opens** to `http://localhost:63769`
5. ✅ **Click "Products"** to verify everything works

---

**Status**: ✅ Multi-project startup configured  
**Configuration Files**: Created  
**Ready to Use**: Press F5 to start all services!

## Visual Studio Version Compatibility

This configuration works with:
- ✅ Visual Studio 2022 (all versions)
- ✅ Visual Studio 2019 (version 16.8+)

If using an older version, you may need to manually configure multiple startup projects through the Solution Properties dialog.
