# Navigation Links Updated - Direct API Access

## Changes Made

Updated all navigation links to point **directly to the API endpoints** instead of the Store UI pages.

## Files Modified

### 1. `src\eShopLite.StoreFx\Components\Layout\MainLayout.razor`

**Before:**
```razor
<a class="nav-link text-dark" href="/products">Products</a>
<a class="nav-link text-dark" href="/stores">Stores</a>
```

**After:**
```razor
<a class="nav-link text-dark" href="https://localhost:7001/api/products" target="_blank">Products</a>
<a class="nav-link text-dark" href="https://localhost:7002/api/stores" target="_blank">Stores</a>
```

### 2. `src\eShopLite.StoreFx\Components\Pages\Home.razor`

**Before:**
```razor
<a href="/products" class="btn btn-light btn-lg">Shop Products</a>
<a href="/stores" class="btn btn-outline-light btn-lg">Find Stores</a>
<a href="/products" class="btn btn-outline-primary">Browse Collection</a>
<a href="/stores" class="btn btn-outline-success">Find Stores</a>
```

**After:**
```razor
<a href="https://localhost:7001/api/products" class="btn btn-light btn-lg" target="_blank">Shop Products</a>
<a href="https://localhost:7002/api/stores" class="btn btn-outline-light btn-lg" target="_blank">Find Stores</a>
<a href="https://localhost:7001/api/products" class="btn btn-outline-primary" target="_blank">Browse Collection</a>
<a href="https://localhost:7002/api/stores" class="btn btn-outline-success" target="_blank">Find Stores</a>
```

## Behavior Changes

### Before:
- Clicking "Products" → Navigated to `http://localhost:63769/products` (Store UI page)
- Store UI would then call the API internally using `ProductApiClient`

### After:
- Clicking "Products" → Opens `https://localhost:7001/api/products` in a **new tab** (Direct API)
- Returns **raw JSON data** from the Products API
- No Store UI involvement

### Example API Response:

**Products API** (`https://localhost:7001/api/products`):
```json
[
  {
    "id": 1,
    "name": "Solar Powered Flashlight",
    "description": "A fantastic product for outdoor enthusiasts",
    "price": 19.99,
    "imageUrl": "product1.png"
  },
  {
    "id": 2,
    "name": "Hiking Poles",
    "description": "Ideal for camping and hiking trips",
    "price": 24.99,
    "imageUrl": "product2.png"
  }
  // ... more products
]
```

**Stores API** (`https://localhost:7002/api/stores`):
```json
[
  {
    "id": 1,
    "name": "Outdoor Store",
    "city": "Seattle",
    "state": "WA",
    "hours": "9am - 5pm"
  }
  // ... more stores
]
```

## How to Test

### 1. **Start the API Services**

You only need the API services running, not the full Store UI:

```powershell
# Terminal 1: Start Products API
cd src\eShopLite.Products
dotnet run --launch-profile https

# Terminal 2: Start StoreInfo API
cd src\eShopLite.StoreInfo
dotnet run --launch-profile https
```

### 2. **Open Store UI** (Optional - just for navigation)

```powershell
cd src\eShopLite.StoreFx
dotnet run
```

### 3. **Navigate to Home Page**

Open browser to: `http://localhost:63769`

### 4. **Click "Products" or "Shop Products"**

- Opens: `https://localhost:7001/api/products` in new tab
- Shows: Raw JSON data

### 5. **Click "Stores" or "Find Stores"**

- Opens: `https://localhost:7002/api/stores` in new tab
- Shows: Raw JSON data

## URL Mapping

| Button/Link | Old URL | New URL |
|-------------|---------|---------|
| Products (Nav) | `/products` → `http://localhost:63769/products` | `https://localhost:7001/api/products` |
| Stores (Nav) | `/stores` → `http://localhost:63769/stores` | `https://localhost:7002/api/stores` |
| Shop Products (Hero) | `/products` → `http://localhost:63769/products` | `https://localhost:7001/api/products` |
| Find Stores (Hero) | `/stores` → `http://localhost:63769/stores` | `https://localhost:7002/api/stores` |
| Browse Collection (Card) | `/products` → `http://localhost:63769/products` | `https://localhost:7001/api/products` |
| Find Stores (Card) | `/stores` → `http://localhost:63769/stores` | `https://localhost:7002/api/stores` |

## Notes

1. **`target="_blank"`** - All API links open in a **new browser tab**
2. **Raw JSON** - APIs return JSON data, not HTML pages
3. **Store UI Pages** - The `/products` and `/stores` Blazor pages still exist but are no longer linked
4. **API Must Be Running** - Make sure the API services are started before clicking the links

## Architecture

```
┌─────────────────────────────────────┐
│  Browser                            │
│  http://localhost:63769             │
└──────────────┬──────────────────────┘
               │
               │ (User clicks "Products")
               │
               ▼
┌─────────────────────────────────────┐
│  New Tab Opens                      │
│  https://localhost:7001/api/products│ ← Direct API call
│                                     │
│  Response: JSON Data                │
└─────────────────────────────────────┘
```

## Reverting Changes

If you want to revert to the original behavior (UI pages), change the links back to:

```razor
<!-- Navigation -->
<a class="nav-link text-dark" href="/products">Products</a>

<!-- Home Page -->
<a href="/products" class="btn btn-light btn-lg">Shop Products</a>
```

And remove `target="_blank"` attribute.

---

**Status**: ✅ Complete - Navigation now points to API endpoints
**Build Status**: ✅ Successful
**Testing**: Requires Products API and StoreInfo API to be running
