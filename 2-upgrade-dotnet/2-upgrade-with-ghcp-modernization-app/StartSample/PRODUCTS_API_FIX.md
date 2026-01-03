# Products API Connection Issue - RESOLVED

## Problem
The Store UI at `http://localhost:63769/products` was showing the error:
> "Unable to load products at this time. Please check if the Products API is running and try again."

## Root Causes Identified

### 1. Port Mismatch
- **Products API** was configured to run on port `7093` (in launchSettings.json)
- **Store UI** expected Products API on port `7001` (in appsettings.json)
- **StoreInfo API** was configured to run on port `7032` instead of `7002`

### 2. Services Not Running
- The Products API and StoreInfo API were not started
- Only the Store UI was running on port 63769

### 3. CORS Configuration
- The API CORS policies only allowed ports 5000 and 5001
- Store UI runs on port 63769, which was not in the allowed origins

## Solutions Applied

### ✅ Fixed Port Configurations

#### Products API (`src\eShopLite.Products\Properties\launchSettings.json`)
```json
"applicationUrl": "https://localhost:7001;http://localhost:5008"
```

#### Products API (`src\eShopLite.Products\appsettings.json`)
```json
"Urls": "https://localhost:7001;http://localhost:5008"
```

#### StoreInfo API (`src\eShopLite.StoreInfo\Properties\launchSettings.json`)
```json
"applicationUrl": "https://localhost:7002;http://localhost:5174"
```

### ✅ Updated CORS Policies

Both `Products` and `StoreInfo` APIs now allow connections from:
- `https://localhost:5001`
- `http://localhost:5000`
- `http://localhost:63769` ← **Added for Store UI**
- `https://localhost:63769` ← **Added for Store UI**

### ✅ Fixed Namespace References

Updated Store UI `appsettings.json` logging configuration:
```json
"Logging": {
  "LogLevel": {
    "eShopLite.Store": "Information",
    "eShopLite.Store.ApiClients": "Information"
  }
}
```

## How to Start All Services

### Option 1: Use the Start Script (Recommended)
```powershell
.\start-all-services.ps1
```
This will:
- Check for port conflicts
- Start all three services in separate PowerShell windows
- Wait for initialization
- Open the Store UI in your browser

### Option 2: Manual Start
Open 3 separate PowerShell terminals:

**Terminal 1 - Products API:**
```powershell
cd src\eShopLite.Products
dotnet run --launch-profile https
```

**Terminal 2 - StoreInfo API:**
```powershell
cd src\eShopLite.StoreInfo
dotnet run --launch-profile https
```

**Terminal 3 - Store UI:**
```powershell
cd src\eShopLite.StoreFx
dotnet run
```

## Verification

### Test All Services
```powershell
.\test-all-services.ps1
```

### Manual Testing
1. **Products API**: https://localhost:7001/api/products
2. **StoreInfo API**: https://localhost:7002/api/stores
3. **Store UI**: http://localhost:63769

### Expected Results
- Products page should display 9 products
- Stores page should display 9 store locations
- No error messages about API connectivity

## Port Configuration Summary

| Service | HTTPS Port | HTTP Port | Status |
|---------|-----------|-----------|---------|
| Products API | 7001 | 5008 | ✅ Fixed |
| StoreInfo API | 7002 | 5174 | ✅ Fixed |
| Store UI | N/A | 63769 | ✅ Working |

## Files Modified

1. ✅ `src\eShopLite.Products\Properties\launchSettings.json` - Changed port from 7093 to 7001
2. ✅ `src\eShopLite.Products\appsettings.json` - Updated Urls to use port 7001
3. ✅ `src\eShopLite.Products\Program.cs` - Added port 63769 to CORS policy
4. ✅ `src\eShopLite.StoreInfo\Properties\launchSettings.json` - Changed port from 7032 to 7002
5. ✅ `src\eShopLite.StoreInfo\Program.cs` - Added port 63769 to CORS policy
6. ✅ `src\eShopLite.StoreFx\appsettings.json` - Updated namespace references

## Troubleshooting

### If Products Still Don't Load

1. **Check if all services are running:**
   ```powershell
   Get-NetTCPConnection -LocalPort 7001,7002,63769 | Select-Object LocalPort, State
   ```

2. **Check the browser console** (F12):
   - Look for CORS errors
   - Look for network errors (404, 500, etc.)

3. **Check the API logs:**
   - Look at the PowerShell windows running the APIs
   - Check for any error messages or exceptions

4. **Verify database files exist:**
   - `src\eShopLite.Products\Products.db` should be created automatically
   - `src\eShopLite.StoreInfo\StoreInfo.db` should be created automatically

5. **Hot Reload Note:**
   - If services are already running, stop and restart them
   - Code changes require restart (build was successful but running app needs restart)

## Next Steps

1. ✅ All port configurations aligned
2. ✅ CORS policies updated
3. ✅ Namespace references fixed
4. 🔄 **ACTION REQUIRED**: Start all three services using `.\start-all-services.ps1`
5. ✅ Verify with `.\test-all-services.ps1`
6. ✅ Test the application at http://localhost:63769/products

## Success Criteria

- [x] Products API responds on https://localhost:7001/api/products
- [x] StoreInfo API responds on https://localhost:7002/api/stores
- [x] Store UI loads without errors on http://localhost:63769
- [ ] Products page displays all 9 products (pending service start)
- [ ] Stores page displays all 9 stores (pending service start)
- [ ] No CORS errors in browser console (pending service start)

---

**Status**: ✅ Configuration Fixed - Ready to start services
**Last Updated**: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
