# Quick Start Guide - Visual Studio Multi-Project Debugging

## ✅ Setup Complete! 

Your Visual Studio solution is now configured to start all 3 microservices automatically.

---

## 🚀 How to Start All Services

### Step 1: Open Visual Studio

Open the solution file:
```
eShopLiteFx.sln
```

### Step 2: Configure Multiple Startup Projects

1. **In Solution Explorer**, right-click on **Solution 'eShopLiteFx'**

2. Select **"Configure Startup Projects..."** (or **"Properties"**)

3. Select **"Multiple startup projects"** radio button

4. Set Action for each project:

```
┌────────────────────────┬─────────┐
│ Project                │ Action  │
├────────────────────────┼─────────┤
│ eShopLite.Products     │ Start   │
│ eShopLite.StoreInfo    │ Start   │
│ eShopLite.Store        │ Start   │
└────────────────────────┴─────────┘
```

5. Click **"OK"**

### Step 3: Press F5

Press **F5** or click the green **▶ Start** button.

---

## 📊 What Happens Next

### Visual Studio Will:

```
┌─────────────────────────────────────────┐
│  1. Build all 3 projects                │
│  2. Start Products API (port 7001)      │
│  3. Start StoreInfo API (port 7002)     │
│  4. Start Store UI (port 63769)         │
│  5. Open browser to Store UI            │
│  6. Attach debugger to all processes    │
└─────────────────────────────────────────┘
```

### You'll See:

**3 Console Windows** (one for each service):
```
┌────────────────────────────────────┐
│ Console 1: Products API            │
│ ════════════════════════════════   │
│ Initializing Products database...  │
│ Database contains 9 products       │
│ Listening on: https://localhost:7001│
└────────────────────────────────────┘

┌────────────────────────────────────┐
│ Console 2: StoreInfo API           │
│ ════════════════════════════════   │
│ Initializing StoreInfo database... │
│ Database contains 9 stores         │
│ Listening on: https://localhost:7002│
└────────────────────────────────────┘

┌────────────────────────────────────┐
│ Console 3: Store UI (Blazor)       │
│ ════════════════════════════════   │
│ Products API: https://localhost:7001│
│ StoreInfo API: https://localhost:7002│
│ Listening on: http://localhost:63769│
└────────────────────────────────────┘
```

**1 Browser Window** opens automatically:
```
┌────────────────────────────────────────────────┐
│ http://localhost:63769                         │
├────────────────────────────────────────────────┤
│                                                │
│         Welcome to eShopLite                   │
│                                                │
│    [Shop Products]  [Find Stores]              │
│                                                │
└────────────────────────────────────────────────┘
```

---

## ✅ Testing the Application

### 1. Home Page

The browser opens to: `http://localhost:63769`

You should see:
- ✅ "Welcome to eShopLite" header
- ✅ Navigation menu (Products, Stores)
- ✅ Feature cards
- ✅ No error messages

### 2. Products Page

Click **"Products"** in the navigation menu.

You should see:
```
┌─────────────────────────────────────────────┐
│ 🏔️  Our Products                            │
│ Discover our collection of premium outdoor │
│ gear                                        │
├─────────────────────────────────────────────┤
│                                             │
│ ┌─────────┐ ┌─────────┐ ┌─────────┐       │
│ │ Solar   │ │ Hiking  │ │ Rain    │       │
│ │ Flash-  │ │ Poles   │ │ Jacket  │       │
│ │ light   │ │         │ │         │       │
│ │ $19.99  │ │ $24.99  │ │ $49.99  │       │
│ └─────────┘ └─────────┘ └─────────┘       │
│                                             │
│       ... 9 products total ...              │
└─────────────────────────────────────────────┘
```

### 3. Stores Page

Click **"Stores"** in the navigation menu.

You should see:
```
┌─────────────────────────────────────────────┐
│ 📍 Store Locations                          │
│ Find a store near you                       │
├─────────────────────────────────────────────┤
│                                             │
│ Outdoor Store                               │
│ Seattle, WA | Open 8 AM - 6 PM             │
│                                             │
│ Camping Supplies                            │
│ Portland, OR | Open 9 AM - 8 PM            │
│                                             │
│       ... 9 stores total ...                │
└─────────────────────────────────────────────┘
```

---

## 🐛 Debugging

### Setting Breakpoints

You can set breakpoints in **any of the 3 projects**:

**Example 1: Debug API Call from Store UI**
```csharp
// File: src\eShopLite.StoreFx\ApiClients\ProductApiClient.cs
// Line 25

public async Task<IEnumerable<Product>> GetProductsAsync(...)
{
    // Set breakpoint here 👇
    _logger.LogInformation("Retrieving all products from Products API");
    return await GetCollectionAsync<Product>(ProductsEndpoint, ...);
}
```

**Example 2: Debug API Endpoint**
```csharp
// File: src\eShopLite.Products\Program.cs
// Line 44

app.MapGet("/api/products", async (ProductDbContext db, ...) =>
{
    // Set breakpoint here 👇
    logger.LogInformation("Retrieving all products");
    return await db.Products.ToListAsync();
})
```

**Example 3: Debug Blazor Component**
```razor
// File: src\eShopLite.StoreFx\Components\Pages\Products.razor
// Line 206

private async Task LoadProducts()
{
    try
    {
        // Set breakpoint here 👇
        Logger.LogInformation("Loading products from Products API");
        products = (await ProductApiClient.GetProductsAsync()).ToList();
```

### Stopping Debugging

To stop all services:
- Press **Shift + F5**
- Or click **Stop** button (red square) in toolbar

All 3 services will stop at once.

---

## 🔧 Troubleshooting

### Problem: Services don't start

**Check:**
1. Right-click Solution → **Configure Startup Projects**
2. Verify all 3 projects are set to **Start**
3. Click **OK** and try F5 again

### Problem: Port already in use

**Error:** "Failed to bind to address https://localhost:7001: address already in use"

**Solution:**
```powershell
# Stop conflicting processes
Get-NetTCPConnection -LocalPort 7001,7002,63769 | 
  ForEach-Object { Stop-Process -Id $_.OwningProcess -Force }

# Restart Visual Studio
```

### Problem: Products don't load

**Symptoms:**
- Products page shows error message
- "Unable to load products" alert

**Check:**
1. **Output Window** in Visual Studio (**View → Output**)
2. Select **Debug** from dropdown
3. Look for error messages from Products API
4. Verify Products API console shows "Listening on: https://localhost:7001"

### Problem: Can't see console windows

**Solution:**
- Console windows might be minimized
- Check taskbar for 3 console windows
- Use **View → Output** in Visual Studio to see logs

---

## 📋 Quick Reference

| Task | Keyboard Shortcut | Menu |
|------|------------------|------|
| Start debugging | **F5** | Debug → Start Debugging |
| Stop debugging | **Shift + F5** | Debug → Stop Debugging |
| Restart debugging | **Ctrl + Shift + F5** | Debug → Restart |
| Configure startup | - | Right-click Solution → Configure Startup Projects |
| View output | **Ctrl + Alt + O** | View → Output |

---

## 🎯 Success Checklist

After pressing F5, verify:

- [ ] 3 console windows open (Products API, StoreInfo API, Store UI)
- [ ] Browser opens to `http://localhost:63769`
- [ ] Home page loads without errors
- [ ] Click "Products" → 9 products displayed
- [ ] Click "Stores" → 9 stores displayed  
- [ ] No error messages or alerts
- [ ] Browser console (F12) shows no errors

---

## 📚 Related Documentation

- **Full Setup Guide**: `VISUAL_STUDIO_MULTI_PROJECT_SETUP.md`
- **Services Status**: `SERVICES_STATUS_AND_FIX.md`
- **Port Configuration**: `PRODUCTS_API_FIX.md`
- **PowerShell Scripts**: `start-all-services.ps1`, `test-all-services.ps1`

---

## 🎉 You're All Set!

**Now:**
1. ✅ Close and reopen Visual Studio (to load configuration)
2. ✅ Press **F5**
3. ✅ Wait 10-15 seconds
4. ✅ Start coding! All services will run automatically

**Happy Debugging! 🚀**
