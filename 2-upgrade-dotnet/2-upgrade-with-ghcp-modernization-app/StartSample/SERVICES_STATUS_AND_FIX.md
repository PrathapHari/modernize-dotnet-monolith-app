# Services Status and Resolution

## ❌ Problem Identified

**The Products API and StoreInfo API are NOT running!**

### Current Service Status:

| Service | Port | Status |
|---------|------|--------|
| Store UI (Blazor) | 63769 | ✅ **RUNNING** |
| Products API | 7001 | ❌ **NOT RUNNING** |
| StoreInfo API | 7002 | ❌ **NOT RUNNING** |

## Why the Error Occurs

When you click "Products" on the Store UI:

1. ✅ Browser navigates to `http://localhost:63769/products` (Store UI page loads)
2. ✅ `Products.razor` component initializes
3. ❌ `ProductApiClient` tries to call `https://localhost:7001/api/products`
4. ❌ **Connection fails** because Products API is not running
5. ❌ Error message displayed: "Unable to load products at this time"

## ✅ Solution: Start the Missing API Services

### Option 1: Use the Check and Start Script (Recommended)

I've created a script that checks which services are running and starts the missing ones:

```powershell
.\check-and-start-services.ps1
```

This will:
- ✅ Check which services are running
- ✅ Prompt to start missing services
- ✅ Verify they started successfully

### Option 2: Use the Full Start Script

Start all services at once:

```powershell
.\start-all-services.ps1
```

### Option 3: Manual Start

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

**Terminal 3 - Store UI (if not already running):**
```powershell
cd src\eShopLite.StoreFx
dotnet run
```

## How the Architecture Should Work

```
┌─────────────────────────────────────┐
│  Browser                            │
│  User clicks "Products"             │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│  Store UI (Blazor)                  │
│  http://localhost:63769/products    │
│  - Displays Products.razor page     │
│  - Shows loading spinner            │
└──────────────┬──────────────────────┘
               │
               │ ProductApiClient.GetProductsAsync()
               │ Internal server-side HTTP call
               ▼
┌─────────────────────────────────────┐
│  Products API                       │
│  https://localhost:7001/api/products│ ← Must be running!
│  - Returns JSON with product list   │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│  Store UI                           │
│  - Receives product data            │
│  - Renders products in nice UI      │
│  - Shows product cards/list         │
└─────────────────────────────────────┘
```

## Verification Steps

After starting the services:

### 1. Check Services Are Running

```powershell
# Check ports
Get-NetTCPConnection -LocalPort 7001,7002,63769 | Select-Object LocalPort, State
```

Expected output:
```
LocalPort  State
---------  -----
     7001  Listen
     7002  Listen
    63769  Listen
```

### 2. Test APIs Directly

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

### 3. Test Store UI

Navigate to:
```
http://localhost:63769
```

Click **"Products"** → Should display the products page with product cards

Click **"Stores"** → Should display the stores page with store information

### 4. Run Automated Tests

```powershell
.\test-all-services.ps1
```

## Changes Made to Fix Navigation

✅ **Reverted** navigation links back to internal routing:

| Link | URL | Behavior |
|------|-----|----------|
| Products (Nav) | `/products` | Navigates to Store UI Products page |
| Stores (Nav) | `/stores` | Navigates to Store UI Stores page |
| Shop Products (Home) | `/products` | Navigates to Store UI Products page |
| Find Stores (Home) | `/stores` | Navigates to Store UI Stores page |

❌ **Removed** direct API links (no more `target="_blank"` or external URLs)

## What You Should See

### When All Services Are Running:

1. **Navigate to** `http://localhost:63769`
2. **Click "Products"**
3. **See:**
   - URL changes to `http://localhost:63769/products`
   - Loading spinner appears briefly
   - 9 product cards displayed in a grid
   - Each card shows: image, name, description, price

### When APIs Are NOT Running:

1. **Navigate to** `http://localhost:63769`
2. **Click "Products"**
3. **See:**
   - URL changes to `http://localhost:63769/products`
   - Loading spinner appears
   - Error message: "Unable to load products at this time. Please check if the Products API is running and try again."

## Expected Database Data

### Products (9 items):
1. Solar Powered Flashlight - $19.99
2. Hiking Poles - $24.99
3. Outdoor Rain Jacket - $49.99
4. Survival Kit - $99.99
5. Outdoor Backpack - $39.99
6. Camping Cookware - $29.99
7. Camping Stove - $49.99
8. Camping Lantern - $19.99
9. Camping Tent - $99.99

### Stores (9 items):
1. Outdoor Store - Seattle, WA
2. Camping Supplies - Portland, OR
3. Hiking Gear - San Francisco, CA
4. Fishing Equipment - Los Angeles, CA
5. Climbing Gear - Denver, CO
6. Cycling Supplies - Austin, TX
7. Winter Sports Gear - Salt Lake City, UT
8. Water Sports Equipment - Miami, FL
9. Outdoor Clothing - New York, NY

## Quick Reference Commands

| Task | Command |
|------|---------|
| Check service status | `.\check-and-start-services.ps1` |
| Start all services | `.\start-all-services.ps1` |
| Test all services | `.\test-all-services.ps1` |
| Check ports manually | `Get-NetTCPConnection -LocalPort 7001,7002,63769` |
| Start Products API only | `cd src\eShopLite.Products; dotnet run --launch-profile https` |
| Start StoreInfo API only | `cd src\eShopLite.StoreInfo; dotnet run --launch-profile https` |

## Next Steps

1. ✅ Run `.\check-and-start-services.ps1` to start missing services
2. ✅ Wait 15 seconds for services to initialize
3. ✅ Navigate to `http://localhost:63769`
4. ✅ Click "Products" - should display products in UI (not raw JSON)
5. ✅ Click "Stores" - should display stores in UI (not raw JSON)

---

**Status**: ✅ Navigation reverted to internal routing  
**Issue**: ❌ Products API and StoreInfo API are not running  
**Action Required**: Start the API services using one of the methods above
