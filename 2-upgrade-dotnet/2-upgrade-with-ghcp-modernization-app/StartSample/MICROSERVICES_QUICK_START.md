# 🚀 eShopLite Microservices Migration - Quick Start

## 📋 Overview

Transform eShopLite from a monolithic Blazor application into a microservices architecture with 3 separate applications.

---

## 🎯 Target Architecture

```
┌────────────────────────────────────────────────────────┐
│         eShopLite.Store (Blazor UI)                    │
│         Port: 5001                                     │
│                                                        │
│  Uses: ProductApiClient + StoreInfoApiClient          │
└────────────┬──────────────────────┬───────────────────┘
             │ HTTP REST            │ HTTP REST
             │                      │
   ┌─────────▼──────────┐    ┌─────▼──────────────┐
   │ eShopLite.Products │    │ eShopLite.StoreInfo│
   │ Port: 7001         │    │ Port: 7002         │
   │                    │    │                    │
   │ Minimal API        │    │ Minimal API        │
   │ SQLite: Products.db│    │ SQLite: StoreInfo.db│
   └────────────────────┘    └────────────────────┘
```

---

## ⚡ Quick Start

### Option 1: Automated (Recommended for Project Setup)

```powershell
# Run the migration script
.\Migrate-To-Microservices.ps1

# This creates:
# - eShopLite.Products project
# - eShopLite.StoreInfo project
# - run-all.ps1 script
# - test-apis.ps1 script
```

### Option 2: Manual (For Full Control)

Follow the comprehensive guide in **`MICROSERVICES_MIGRATION_PLAN.md`**

---

## 📦 What Gets Created

### 1. eShopLite.Products (Minimal API)
- **Port**: 7001
- **Database**: Products.db (SQLite)
- **Endpoints**:
  - `GET /api/products` - List all products
  - `GET /api/products/{id}` - Get product by ID
- **Swagger**: https://localhost:7001/swagger

### 2. eShopLite.StoreInfo (Minimal API)
- **Port**: 7002
- **Database**: StoreInfo.db (SQLite)
- **Endpoints**:
  - `GET /api/stores` - List all stores
  - `GET /api/stores/{id}` - Get store by ID
- **Swagger**: https://localhost:7002/swagger

### 3. eShopLite.Store (Blazor UI)
- **Port**: 5001
- **Components**: Products.razor, Stores.razor
- **API Clients**: ProductApiClient, StoreInfoApiClient
- **No Database**: Communicates with APIs only

---

## 🏗️ Implementation Steps

### Step 1: Create Projects (Automated)
```powershell
.\Migrate-To-Microservices.ps1
```

### Step 2: Implement Products API

**Files to create**:
1. `src/eShopLite.Products/Models/Product.cs`
2. `src/eShopLite.Products/Data/ProductDbContext.cs`
3. `src/eShopLite.Products/Program.cs` (Minimal API)

**Key Code** (see migration plan for full details):
```csharp
// Program.cs
app.MapGet("/api/products", async (ProductDbContext db) =>
{
    return await db.Products.ToListAsync();
});

app.MapGet("/api/products/{id:int}", async (int id, ProductDbContext db) =>
{
    var product = await db.Products.FindAsync(id);
    return product is not null ? Results.Ok(product) : Results.NotFound();
});
```

### Step 3: Implement StoreInfo API

**Files to create**:
1. `src/eShopLite.StoreInfo/Models/StoreInfo.cs`
2. `src/eShopLite.StoreInfo/Data/StoreInfoDbContext.cs`
3. `src/eShopLite.StoreInfo/Program.cs` (Minimal API)

**Key Code** (see migration plan for full details):
```csharp
// Program.cs
app.MapGet("/api/stores", async (StoreInfoDbContext db) =>
{
    return await db.Stores.ToListAsync();
});

app.MapGet("/api/stores/{id:int}", async (int id, StoreInfoDbContext db) =>
{
    var store = await db.Stores.FindAsync(id);
    return store is not null ? Results.Ok(store) : Results.NotFound();
});
```

### Step 4: Transform Store UI

**Files to create**:
1. `src/eShopLite.Store/ApiClients/ApiClient.cs` (base class)
2. `src/eShopLite.Store/ApiClients/ProductApiClient.cs`
3. `src/eShopLite.Store/ApiClients/StoreInfoApiClient.cs`

**Files to modify**:
1. `src/eShopLite.Store/Program.cs` (add HttpClient configuration)
2. `src/eShopLite.Store/Components/Pages/Products.razor` (use ProductApiClient)
3. `src/eShopLite.Store/Components/Pages/Stores.razor` (use StoreInfoApiClient)
4. `src/eShopLite.Store/appsettings.json` (add API URLs)

**Files to delete**:
1. `src/eShopLite.Store/Services/ProductService.cs`
2. `src/eShopLite.Store/Services/StoreService.cs`
3. `src/eShopLite.Store/Data/StoreDbContext.cs`

---

## 🧪 Testing

### Run All Services
```powershell
# Option 1: Use run-all script
.\run-all.ps1

# Option 2: Manual (3 terminals)
# Terminal 1:
cd src/eShopLite.Products
dotnet run

# Terminal 2:
cd src/eShopLite.StoreInfo
dotnet run

# Terminal 3:
cd src/eShopLite.Store
dotnet run
```

### Test APIs
```powershell
# Option 1: Use test script
.\test-apis.ps1

# Option 2: Manual cURL
curl https://localhost:7001/api/products
curl https://localhost:7002/api/stores

# Option 3: Open Swagger
# Navigate to: https://localhost:7001/swagger
# Navigate to: https://localhost:7002/swagger
```

### Test UI
```
1. Open: https://localhost:5001
2. Navigate to Products page
3. Verify all 9 products display
4. Navigate to Stores page
5. Verify all 9 stores display
6. Check browser console (F12) - no errors
```

---

## ✅ Verification Checklist

### Functional Tests
- [ ] Products API returns 9 products
- [ ] StoreInfo API returns 9 stores
- [ ] Store UI displays all products correctly
- [ ] Store UI displays all stores correctly
- [ ] Product images load
- [ ] Navigation works
- [ ] No features added or removed

### Technical Tests
- [ ] Products API running on port 7001
- [ ] StoreInfo API running on port 7002
- [ ] Store UI running on port 5001
- [ ] Products.db created and seeded
- [ ] StoreInfo.db created and seeded
- [ ] Swagger UI accessible for both APIs
- [ ] No errors in console (F12)
- [ ] All 3 apps build successfully

### Architecture Tests
- [ ] Products API uses Minimal API (no Controllers)
- [ ] StoreInfo API uses Minimal API (no Controllers)
- [ ] ProductApiClient inherits from ApiClient
- [ ] StoreInfoApiClient inherits from ApiClient
- [ ] Store UI has no direct database access
- [ ] Each API has its own SQLite database
- [ ] Naming conventions followed

---

## 🐛 Troubleshooting

### Issue: APIs not starting
**Check ports are available**:
```powershell
netstat -ano | findstr :7001
netstat -ano | findstr :7002
netstat -ano | findstr :5001
```

If occupied, kill the process or change ports in appsettings.json

### Issue: UI can't connect to APIs
**Check CORS configuration** in API Program.cs:
```csharp
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowBlazorApp", policy =>
    {
        policy.WithOrigins("https://localhost:5001", "http://localhost:5000")
              .AllowAnyHeader()
              .AllowAnyMethod();
    });
});

app.UseCors("AllowBlazorApp");
```

**Check API URLs** in Store UI appsettings.json:
```json
{
  "ApiSettings": {
    "ProductsApiUrl": "https://localhost:7001",
    "StoreInfoApiUrl": "https://localhost:7002"
  }
}
```

### Issue: Database not seeding
**Check DbContext configuration**:
```csharp
// In API startup
using (var scope = app.Services.CreateScope())
{
    var db = scope.ServiceProvider.GetRequiredService<ProductDbContext>();
    await db.Database.EnsureCreatedAsync();
}
```

**Manual seed**:
```powershell
# Delete existing database
Remove-Item src/eShopLite.Products/Products.db

# Restart API to recreate with seed data
cd src/eShopLite.Products
dotnet run
```

### Issue: HttpClient errors
**Check retry policies** are configured:
```powershell
# Add Polly package
dotnet add package Microsoft.Extensions.Http.Polly
```

**Verify HttpClient registration** in Program.cs:
```csharp
builder.Services.AddHttpClient<ProductApiClient>(client =>
{
    client.BaseAddress = new Uri("https://localhost:7001");
});
```

---

## 📝 Key Files Reference

### Products API
```
src/eShopLite.Products/
├── Models/
│   └── Product.cs                  ← Product entity
├── Data/
│   └── ProductDbContext.cs         ← EF Core context
├── Program.cs                      ← Minimal API endpoints
├── appsettings.json               ← Port 7001, connection string
└── Products.db                     ← SQLite database (auto-created)
```

### StoreInfo API
```
src/eShopLite.StoreInfo/
├── Models/
│   └── StoreInfo.cs               ← StoreInfo entity
├── Data/
│   └── StoreInfoDbContext.cs      ← EF Core context
├── Program.cs                     ← Minimal API endpoints
├── appsettings.json              ← Port 7002, connection string
└── StoreInfo.db                   ← SQLite database (auto-created)
```

### Store UI
```
src/eShopLite.Store/
├── ApiClients/
│   ├── ApiClient.cs               ← Base API client
│   ├── ProductApiClient.cs        ← Products API client
│   └── StoreInfoApiClient.cs      ← StoreInfo API client
├── Models/
│   ├── Product.cs                 ← Product DTO (matches API)
│   └── StoreInfo.cs               ← StoreInfo DTO (matches API)
├── Components/
│   ├── Pages/
│   │   ├── Products.razor         ← Uses ProductApiClient
│   │   └── Stores.razor           ← Uses StoreInfoApiClient
│   └── Layout/
│       └── MainLayout.razor       ← Unchanged
├── Program.cs                     ← HttpClient configuration
└── appsettings.json              ← API URLs configuration
```

---

## 🎯 Success Criteria

**Migration is successful when**:

1. ✅ All 3 applications build without errors
2. ✅ All 3 applications run concurrently
3. ✅ Products page displays identically to original
4. ✅ Stores page displays identically to original
5. ✅ All 9 products appear correctly
6. ✅ All 9 stores appear correctly
7. ✅ No new features added
8. ✅ No existing features broken
9. ✅ APIs use Minimal API approach
10. ✅ API clients follow inheritance pattern
11. ✅ Each service has separate SQLite database
12. ✅ No console errors in browser (F12)

---

## 📚 Documentation Files

1. **MICROSERVICES_MIGRATION_PLAN.md** - Complete detailed plan (30+ pages)
2. **Migrate-To-Microservices.ps1** - Automated migration script
3. **MICROSERVICES_QUICK_START.md** - This file (quick reference)

---

## 🔗 Useful URLs

**After all services are running**:

- **Store UI**: https://localhost:5001
- **Products API**: https://localhost:7001/api/products
- **Products Swagger**: https://localhost:7001/swagger
- **StoreInfo API**: https://localhost:7002/api/stores
- **StoreInfo Swagger**: https://localhost:7002/swagger
- **Health Checks**: https://localhost:5001/health

---

## 💡 Tips

### Development Workflow
1. **Start APIs first**, then UI (APIs must be running for UI to work)
2. **Use Swagger** for API testing before UI integration
3. **Check logs** in each terminal window for debugging
4. **Test APIs independently** before testing through UI

### Code Organization
1. **Keep Models synchronized** between APIs and UI
2. **Follow naming conventions** (ProductApiClient, StoreInfoApiClient)
3. **Inherit from ApiClient base** for all API clients
4. **Use async/await** consistently

### Testing Strategy
1. **Test APIs with Swagger** (fast feedback)
2. **Test APIs with curl/Postman** (automation)
3. **Test UI manually** (user experience)
4. **Compare with original** (regression testing)

---

## 🚀 Next Steps After Migration

### Immediate
1. Add comprehensive logging
2. Implement error handling UI feedback
3. Add loading states
4. Create automated tests

### Short-term
1. Add API authentication/authorization
2. Implement API versioning
3. Add rate limiting
4. Set up monitoring

### Long-term
1. Consider API Gateway (YARP/Ocelot)
2. Implement event-driven architecture
3. Add message queue (RabbitMQ/Service Bus)
4. Containerize with Docker
5. Deploy to Kubernetes

---

## 📞 Need Help?

### Detailed Instructions
See: **MICROSERVICES_MIGRATION_PLAN.md**

### Code Examples
All code examples are in the migration plan with full context

### Architecture Questions
Review the "Sequential Thinking Analysis" section in migration plan

### Troubleshooting
See "Troubleshooting" section above and in migration plan

---

**Good luck with your migration!** 🎉

**Remember**: No new features, no removed features - just architecture transformation!
