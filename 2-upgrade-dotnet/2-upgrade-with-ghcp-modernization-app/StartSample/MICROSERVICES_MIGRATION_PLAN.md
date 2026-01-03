# 🎯 Microservices Migration Plan
## eShopLite: Monolith to Microservices

---

## 📋 Executive Summary

**Migration Goal**: Transform eShopLite monolithic Blazor application into a microservices architecture

**Current State**: Single Blazor Server application (`eShopLite.StoreFx`)
- Combined Product and Store Info logic
- Single SQLite database (`StoreDbContext`)
- Direct database access from Blazor UI

**Target State**: Microservices architecture with 3 applications
1. **eShopLite.Products** - Product API (Minimal API + SQLite)
2. **eShopLite.StoreInfo** - Store Info API (Minimal API + SQLite)
3. **eShopLite.Store** - Blazor UI (consumes both APIs via HttpClient)

**Key Constraints**:
- ✅ No new features
- ✅ No alterations to existing features
- ✅ Preserve all existing functionality
- ✅ Maintain UI/UX unchanged
- ✅ Use SQLite for both APIs
- ✅ Implement Minimal APIs (no Controllers)
- ✅ Follow existing naming conventions

---

## 🧠 Sequential Thinking Analysis

### Step 1: Understand Current Architecture

**Current Components**:
```
eShopLite.StoreFx/
├── Models/
│   ├── Product.cs          ← Move to Products API
│   └── StoreInfo.cs        ← Move to StoreInfo API
├── Data/
│   └── StoreDbContext.cs   ← Split into 2 contexts
├── Services/
│   ├── ProductService.cs   ← Replace with ProductApiClient
│   └── StoreService.cs     ← Replace with StoreInfoApiClient
├── Components/
│   ├── Pages/
│   │   ├── Products.razor  ← Update to use API client
│   │   └── Stores.razor    ← Update to use API client
│   └── Layout/
│       └── MainLayout.razor ← Keep unchanged
└── wwwroot/                ← Keep unchanged
```

**Current Database**:
- Single `StoreDbContext` with:
  - `Products` DbSet (9 products)
  - `Stores` DbSet (9 stores)

### Step 2: Define Microservices Boundaries

**Domain Separation**:
1. **Product Domain** (Bounded Context)
   - Entity: Product
   - Operations: GetProducts, GetProductById
   - Database: Products.db

2. **Store Info Domain** (Bounded Context)
   - Entity: StoreInfo
   - Operations: GetStores, GetStoreById
   - Database: StoreInfo.db

3. **UI/BFF Domain** (Backend for Frontend)
   - Blazor Server UI
   - API clients for aggregation
   - No direct database access

### Step 3: Design API Contracts

**Product API** (`eShopLite.Products`)
```
Base URL: https://localhost:7001/api/products

GET /api/products          → List<Product>
GET /api/products/{id}     → Product
```

**Store Info API** (`eShopLite.StoreInfo`)
```
Base URL: https://localhost:7002/api/stores

GET /api/stores           → List<StoreInfo>
GET /api/stores/{id}      → StoreInfo
```

### Step 4: Plan Data Migration

**Database Split Strategy**:
- Extract Products table → Products.db
- Extract Stores table → StoreInfo.db
- Each API owns its data (Database per Service pattern)

**Seed Data**:
- Products API: Initialize 9 products
- StoreInfo API: Initialize 9 stores

### Step 5: Design API Client Architecture

**Base API Client Pattern**:
```csharp
// Base class for HTTP communication
public abstract class ApiClient
{
    protected readonly HttpClient _httpClient;
    protected readonly ILogger _logger;
    
    protected ApiClient(HttpClient httpClient, ILogger logger)
    {
        _httpClient = httpClient;
        _logger = logger;
    }
}

// Product-specific client
public class ProductApiClient : ApiClient
{
    public Task<IEnumerable<Product>> GetProductsAsync();
    public Task<Product?> GetProductByIdAsync(int id);
}

// Store-specific client
public class StoreInfoApiClient : ApiClient
{
    public Task<IEnumerable<StoreInfo>> GetStoresAsync();
    public Task<StoreInfo?> GetStoreByIdAsync(int id);
}
```

### Step 6: Identify Migration Risks

**Technical Risks**:
1. ⚠️ **Network Latency**: HTTP calls slower than in-process calls
2. ⚠️ **Error Handling**: API failures need graceful degradation
3. ⚠️ **Configuration**: Multiple app settings (ports, URLs)
4. ⚠️ **Debugging**: Distributed debugging more complex
5. ⚠️ **Data Consistency**: Eventual consistency between services

**Mitigation Strategies**:
1. ✅ Implement retry policies (Polly)
2. ✅ Add circuit breakers for resilience
3. ✅ Centralized configuration management
4. ✅ Comprehensive logging
5. ✅ Keep services stateless

### Step 7: Plan Testing Strategy

**Unit Tests**:
- ✅ Test Minimal API endpoints
- ✅ Test API clients
- ✅ Test database contexts

**Integration Tests**:
- ✅ Test API → Database
- ✅ Test UI → API clients

**E2E Tests**:
- ✅ Test full user workflows
- ✅ Verify UI remains unchanged

---

## 📐 Architecture Design

### Before: Monolithic Architecture

```
┌─────────────────────────────────────────┐
│      eShopLite.StoreFx (Blazor)        │
│                                         │
│  ┌──────────────┐  ┌──────────────┐   │
│  │ Product      │  │ Store        │   │
│  │ Service      │  │ Service      │   │
│  └──────┬───────┘  └──────┬───────┘   │
│         │                  │           │
│         └─────────┬────────┘           │
│                   │                    │
│         ┌─────────▼────────┐           │
│         │  StoreDbContext  │           │
│         └─────────┬────────┘           │
│                   │                    │
│         ┌─────────▼────────┐           │
│         │  SQLite Database │           │
│         │  - Products      │           │
│         │  - Stores        │           │
│         └──────────────────┘           │
└─────────────────────────────────────────┘
```

### After: Microservices Architecture

```
┌──────────────────────────────────────────────────────────┐
│         eShopLite.Store (Blazor UI)                      │
│                                                          │
│  ┌─────────────────────┐  ┌─────────────────────┐      │
│  │ ProductApiClient    │  │ StoreInfoApiClient  │      │
│  │ (HttpClient)        │  │ (HttpClient)        │      │
│  └──────────┬──────────┘  └──────────┬──────────┘      │
└─────────────┼──────────────────────────┼────────────────┘
              │ HTTP                     │ HTTP
              │                          │
    ┌─────────▼──────────┐    ┌─────────▼──────────┐
    │ eShopLite.Products │    │ eShopLite.StoreInfo│
    │  (Minimal API)     │    │  (Minimal API)     │
    │                    │    │                    │
    │ ┌────────────────┐ │    │ ┌────────────────┐ │
    │ │ ProductDbContext│ │    │ │StoreInfoDbContext│ │
    │ └────────┬───────┘ │    │ └────────┬───────┘ │
    │          │         │    │          │         │
    │ ┌────────▼───────┐ │    │ ┌────────▼───────┐ │
    │ │ Products.db    │ │    │ │ StoreInfo.db   │ │
    │ │ (SQLite)       │ │    │ │ (SQLite)       │ │
    │ └────────────────┘ │    │ └────────────────┘ │
    └────────────────────┘    └────────────────────┘
```

### Communication Flow

**User Views Products Page**:
```
1. User → Browser → eShopLite.Store
2. Products.razor → ProductApiClient.GetProductsAsync()
3. ProductApiClient → HTTP GET → eShopLite.Products/api/products
4. eShopLite.Products → ProductDbContext → Products.db
5. Products.db → Data → eShopLite.Products
6. eShopLite.Products → JSON → ProductApiClient
7. ProductApiClient → List<Product> → Products.razor
8. Products.razor → Rendered HTML → Browser
```

---

## 🏗️ Implementation Plan

### Phase 1: Create Products API (`eShopLite.Products`)

**Duration**: 2-3 hours

#### Step 1.1: Create Project Structure
```powershell
# Create new Minimal API project
dotnet new webapi -n eShopLite.Products -o src/eShopLite.Products --no-controllers

# Add to solution
dotnet sln add src/eShopLite.Products/eShopLite.Products.csproj
```

#### Step 1.2: Copy and Adapt Models
**File**: `src/eShopLite.Products/Models/Product.cs`

```csharp
namespace eShopLite.Products.Models;

public class Product
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public decimal Price { get; set; }
    public string ImageUrl { get; set; } = string.Empty;
}
```

#### Step 1.3: Create ProductDbContext
**File**: `src/eShopLite.Products/Data/ProductDbContext.cs`

```csharp
using Microsoft.EntityFrameworkCore;
using eShopLite.Products.Models;

namespace eShopLite.Products.Data;

public class ProductDbContext : DbContext
{
    public ProductDbContext(DbContextOptions<ProductDbContext> options)
        : base(options)
    {
    }

    public DbSet<Product> Products => Set<Product>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        // Seed data
        modelBuilder.Entity<Product>().HasData(
            new Product { Id = 1, Name = "Solar Powered Flashlight", Description = "A fantastic product for outdoor enthusiasts", Price = 19.99m, ImageUrl = "product1.png" },
            new Product { Id = 2, Name = "Hiking Poles", Description = "Ideal for camping and hiking trips", Price = 24.99m, ImageUrl = "product2.png" },
            new Product { Id = 3, Name = "Outdoor Rain Jacket", Description = "This product will keep you warm and dry in all weathers", Price = 49.99m, ImageUrl = "product3.png" },
            new Product { Id = 4, Name = "Survival Kit", Description = "A must-have for any outdoor adventurer", Price = 99.99m, ImageUrl = "product4.png" },
            new Product { Id = 5, Name = "Outdoor Backpack", Description = "This backpack is perfect for carrying all your outdoor essentials", Price = 39.99m, ImageUrl = "product5.png" },
            new Product { Id = 6, Name = "Camping Cookware", Description = "This cookware set is ideal for cooking outdoors", Price = 29.99m, ImageUrl = "product6.png" },
            new Product { Id = 7, Name = "Camping Stove", Description = "This stove is perfect for cooking outdoors", Price = 49.99m, ImageUrl = "product7.png" },
            new Product { Id = 8, Name = "Camping Lantern", Description = "This lantern is perfect for lighting up your campsite", Price = 19.99m, ImageUrl = "product8.png" },
            new Product { Id = 9, Name = "Camping Tent", Description = "This tent is perfect for camping trips", Price = 99.99m, ImageUrl = "product9.png" }
        );
    }
}
```

#### Step 1.4: Implement Minimal API Endpoints
**File**: `src/eShopLite.Products/Program.cs`

```csharp
using Microsoft.EntityFrameworkCore;
using eShopLite.Products.Data;
using eShopLite.Products.Models;

var builder = WebApplication.CreateBuilder(args);

// Add services
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// Configure SQLite
builder.Services.AddDbContext<ProductDbContext>(options =>
    options.UseSqlite(builder.Configuration.GetConnectionString("DefaultConnection") 
        ?? "Data Source=Products.db"));

// Add CORS for UI app
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowBlazorApp", policy =>
    {
        policy.WithOrigins("https://localhost:5001", "http://localhost:5000")
              .AllowAnyHeader()
              .AllowAnyMethod();
    });
});

var app = builder.Build();

// Configure pipeline
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();
app.UseCors("AllowBlazorApp");

// Minimal API endpoints

// GET /api/products
app.MapGet("/api/products", async (ProductDbContext db, ILogger<Program> logger) =>
{
    logger.LogInformation("Retrieving all products");
    return await db.Products.ToListAsync();
})
.WithName("GetProducts")
.WithOpenApi();

// GET /api/products/{id}
app.MapGet("/api/products/{id:int}", async (int id, ProductDbContext db, ILogger<Program> logger) =>
{
    logger.LogInformation("Retrieving product with ID: {ProductId}", id);
    var product = await db.Products.FindAsync(id);
    
    return product is not null 
        ? Results.Ok(product) 
        : Results.NotFound(new { Message = $"Product with ID {id} not found" });
})
.WithName("GetProductById")
.WithOpenApi();

// Initialize database
using (var scope = app.Services.CreateScope())
{
    var db = scope.ServiceProvider.GetRequiredService<ProductDbContext>();
    var logger = scope.ServiceProvider.GetRequiredService<ILogger<Program>>();
    
    try
    {
        logger.LogInformation("Initializing Products database...");
        await db.Database.EnsureCreatedAsync();
        logger.LogInformation("Products database initialized successfully");
    }
    catch (Exception ex)
    {
        logger.LogError(ex, "Error initializing Products database");
        throw;
    }
}

app.Run();
```

#### Step 1.5: Configure appsettings.json
**File**: `src/eShopLite.Products/appsettings.json`

```json
{
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  },
  "ConnectionStrings": {
    "DefaultConnection": "Data Source=Products.db"
  },
  "AllowedHosts": "*",
  "Urls": "https://localhost:7001;http://localhost:5001"
}
```

---

### Phase 2: Create Store Info API (`eShopLite.StoreInfo`)

**Duration**: 2-3 hours

#### Step 2.1: Create Project Structure
```powershell
# Create new Minimal API project
dotnet new webapi -n eShopLite.StoreInfo -o src/eShopLite.StoreInfo --no-controllers

# Add to solution
dotnet sln add src/eShopLite.StoreInfo/eShopLite.StoreInfo.csproj
```

#### Step 2.2: Copy and Adapt Models
**File**: `src/eShopLite.StoreInfo/Models/StoreInfo.cs`

```csharp
namespace eShopLite.StoreInfo.Models;

public class StoreInfo
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string City { get; set; } = string.Empty;
    public string State { get; set; } = string.Empty;
    public string Hours { get; set; } = string.Empty;
}
```

#### Step 2.3: Create StoreInfoDbContext
**File**: `src/eShopLite.StoreInfo/Data/StoreInfoDbContext.cs`

```csharp
using Microsoft.EntityFrameworkCore;
using eShopLite.StoreInfo.Models;

namespace eShopLite.StoreInfo.Data;

public class StoreInfoDbContext : DbContext
{
    public StoreInfoDbContext(DbContextOptions<StoreInfoDbContext> options)
        : base(options)
    {
    }

    public DbSet<StoreInfo> Stores => Set<StoreInfo>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        // Seed data
        modelBuilder.Entity<StoreInfo>().HasData(
            new StoreInfo { Id = 1, Name = "Outdoor Store", City = "Seattle", State = "WA", Hours = "9am - 5pm" },
            new StoreInfo { Id = 2, Name = "Camping Supplies", City = "Portland", State = "OR", Hours = "10am - 6pm" },
            new StoreInfo { Id = 3, Name = "Hiking Gear", City = "San Francisco", State = "CA", Hours = "11am - 7pm" },
            new StoreInfo { Id = 4, Name = "Fishing Equipment", City = "Los Angeles", State = "CA", Hours = "8am - 4pm" },
            new StoreInfo { Id = 5, Name = "Climbing Gear", City = "Denver", State = "CO", Hours = "9am - 5pm" },
            new StoreInfo { Id = 6, Name = "Cycling Supplies", City = "Austin", State = "TX", Hours = "10am - 6pm" },
            new StoreInfo { Id = 7, Name = "Winter Sports Gear", City = "Salt Lake City", State = "UT", Hours = "11am - 7pm" },
            new StoreInfo { Id = 8, Name = "Water Sports Equipment", City = "Miami", State = "FL", Hours = "8am - 4pm" },
            new StoreInfo { Id = 9, Name = "Outdoor Clothing", City = "New York", State = "NY", Hours = "9am - 5pm" }
        );
    }
}
```

#### Step 2.4: Implement Minimal API Endpoints
**File**: `src/eShopLite.StoreInfo/Program.cs`

```csharp
using Microsoft.EntityFrameworkCore;
using eShopLite.StoreInfo.Data;
using eShopLite.StoreInfo.Models;

var builder = WebApplication.CreateBuilder(args);

// Add services
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// Configure SQLite
builder.Services.AddDbContext<StoreInfoDbContext>(options =>
    options.UseSqlite(builder.Configuration.GetConnectionString("DefaultConnection") 
        ?? "Data Source=StoreInfo.db"));

// Add CORS for UI app
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowBlazorApp", policy =>
    {
        policy.WithOrigins("https://localhost:5001", "http://localhost:5000")
              .AllowAnyHeader()
              .AllowAnyMethod();
    });
});

var app = builder.Build();

// Configure pipeline
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();
app.UseCors("AllowBlazorApp");

// Minimal API endpoints

// GET /api/stores
app.MapGet("/api/stores", async (StoreInfoDbContext db, ILogger<Program> logger) =>
{
    logger.LogInformation("Retrieving all stores");
    return await db.Stores.ToListAsync();
})
.WithName("GetStores")
.WithOpenApi();

// GET /api/stores/{id}
app.MapGet("/api/stores/{id:int}", async (int id, StoreInfoDbContext db, ILogger<Program> logger) =>
{
    logger.LogInformation("Retrieving store with ID: {StoreId}", id);
    var store = await db.Stores.FindAsync(id);
    
    return store is not null 
        ? Results.Ok(store) 
        : Results.NotFound(new { Message = $"Store with ID {id} not found" });
})
.WithName("GetStoreById")
.WithOpenApi();

// Initialize database
using (var scope = app.Services.CreateScope())
{
    var db = scope.ServiceProvider.GetRequiredService<StoreInfoDbContext>();
    var logger = scope.ServiceProvider.GetRequiredService<ILogger<Program>>();
    
    try
    {
        logger.LogInformation("Initializing StoreInfo database...");
        await db.Database.EnsureCreatedAsync();
        logger.LogInformation("StoreInfo database initialized successfully");
    }
    catch (Exception ex)
    {
        logger.LogError(ex, "Error initializing StoreInfo database");
        throw;
    }
}

app.Run();
```

#### Step 2.5: Configure appsettings.json
**File**: `src/eShopLite.StoreInfo/appsettings.json`

```json
{
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  },
  "ConnectionStrings": {
    "DefaultConnection": "Data Source=StoreInfo.db"
  },
  "AllowedHosts": "*",
  "Urls": "https://localhost:7002;http://localhost:5002"
}
```

---

### Phase 3: Transform eShopLite.Store (Blazor UI)

**Duration**: 3-4 hours

#### Step 3.1: Create Base API Client
**File**: `src/eShopLite.Store/ApiClients/ApiClient.cs`

```csharp
using System.Net.Http.Json;
using System.Text.Json;

namespace eShopLite.Store.ApiClients;

/// <summary>
/// Base class for all API clients providing common HTTP functionality
/// </summary>
public abstract class ApiClient
{
    protected readonly HttpClient _httpClient;
    protected readonly ILogger _logger;
    protected readonly JsonSerializerOptions _jsonOptions;

    protected ApiClient(HttpClient httpClient, ILogger logger)
    {
        _httpClient = httpClient ?? throw new ArgumentNullException(nameof(httpClient));
        _logger = logger ?? throw new ArgumentNullException(nameof(logger));
        
        _jsonOptions = new JsonSerializerOptions
        {
            PropertyNameCaseInsensitive = true
        };
    }

    /// <summary>
    /// Execute GET request and deserialize response
    /// </summary>
    protected async Task<T?> GetAsync<T>(string requestUri, CancellationToken cancellationToken = default)
    {
        try
        {
            _logger.LogInformation("GET request to: {RequestUri}", requestUri);
            
            var response = await _httpClient.GetAsync(requestUri, cancellationToken);
            response.EnsureSuccessStatusCode();
            
            var result = await response.Content.ReadFromJsonAsync<T>(_jsonOptions, cancellationToken);
            _logger.LogInformation("Successfully retrieved data from: {RequestUri}", requestUri);
            
            return result;
        }
        catch (HttpRequestException ex)
        {
            _logger.LogError(ex, "HTTP request failed for: {RequestUri}", requestUri);
            throw;
        }
        catch (JsonException ex)
        {
            _logger.LogError(ex, "JSON deserialization failed for: {RequestUri}", requestUri);
            throw;
        }
    }

    /// <summary>
    /// Execute GET request for collection
    /// </summary>
    protected async Task<IEnumerable<T>> GetCollectionAsync<T>(string requestUri, CancellationToken cancellationToken = default)
    {
        var result = await GetAsync<List<T>>(requestUri, cancellationToken);
        return result ?? Enumerable.Empty<T>();
    }
}
```

#### Step 3.2: Create ProductApiClient
**File**: `src/eShopLite.Store/ApiClients/ProductApiClient.cs`

```csharp
using eShopLite.Store.Models;

namespace eShopLite.Store.ApiClients;

/// <summary>
/// API client for Product service operations
/// </summary>
public class ProductApiClient : ApiClient
{
    private const string ProductsEndpoint = "api/products";

    public ProductApiClient(HttpClient httpClient, ILogger<ProductApiClient> logger)
        : base(httpClient, logger)
    {
    }

    /// <summary>
    /// Retrieve all products from the Products API
    /// </summary>
    public async Task<IEnumerable<Product>> GetProductsAsync(CancellationToken cancellationToken = default)
    {
        try
        {
            _logger.LogInformation("Retrieving all products from Products API");
            return await GetCollectionAsync<Product>(ProductsEndpoint, cancellationToken);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving products from Products API");
            throw;
        }
    }

    /// <summary>
    /// Retrieve a specific product by ID from the Products API
    /// </summary>
    public async Task<Product?> GetProductByIdAsync(int id, CancellationToken cancellationToken = default)
    {
        try
        {
            _logger.LogInformation("Retrieving product with ID: {ProductId} from Products API", id);
            return await GetAsync<Product>($"{ProductsEndpoint}/{id}", cancellationToken);
        }
        catch (HttpRequestException ex) when (ex.StatusCode == System.Net.HttpStatusCode.NotFound)
        {
            _logger.LogWarning("Product with ID: {ProductId} not found", id);
            return null;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving product with ID: {ProductId} from Products API", id);
            throw;
        }
    }
}
```

#### Step 3.3: Create StoreInfoApiClient
**File**: `src/eShopLite.Store/ApiClients/StoreInfoApiClient.cs`

```csharp
using eShopLite.Store.Models;

namespace eShopLite.Store.ApiClients;

/// <summary>
/// API client for Store Info service operations
/// </summary>
public class StoreInfoApiClient : ApiClient
{
    private const string StoresEndpoint = "api/stores";

    public StoreInfoApiClient(HttpClient httpClient, ILogger<StoreInfoApiClient> logger)
        : base(httpClient, logger)
    {
    }

    /// <summary>
    /// Retrieve all stores from the StoreInfo API
    /// </summary>
    public async Task<IEnumerable<StoreInfo>> GetStoresAsync(CancellationToken cancellationToken = default)
    {
        try
        {
            _logger.LogInformation("Retrieving all stores from StoreInfo API");
            return await GetCollectionAsync<StoreInfo>(StoresEndpoint, cancellationToken);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving stores from StoreInfo API");
            throw;
        }
    }

    /// <summary>
    /// Retrieve a specific store by ID from the StoreInfo API
    /// </summary>
    public async Task<StoreInfo?> GetStoreByIdAsync(int id, CancellationToken cancellationToken = default)
    {
        try
        {
            _logger.LogInformation("Retrieving store with ID: {StoreId} from StoreInfo API", id);
            return await GetAsync<StoreInfo>($"{StoresEndpoint}/{id}", cancellationToken);
        }
        catch (HttpRequestException ex) when (ex.StatusCode == System.Net.HttpStatusCode.NotFound)
        {
            _logger.LogWarning("Store with ID: {StoreId} not found", id);
            return null;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving store with ID: {StoreId} from StoreInfo API", id);
            throw;
        }
    }
}
```

#### Step 3.4: Update Program.cs
**File**: `src/eShopLite.Store/Program.cs`

```csharp
using eShopLite.Store.ApiClients;

var builder = WebApplication.CreateBuilder(args);

// Configure comprehensive logging
builder.Logging.ClearProviders();
builder.Logging.AddConsole();
builder.Logging.AddDebug();
builder.Logging.SetMinimumLevel(LogLevel.Information);

// Add Blazor services
builder.Services.AddRazorComponents()
    .AddInteractiveServerComponents();

// Configure HTTP clients for microservices

// Products API Client
builder.Services.AddHttpClient<ProductApiClient>(client =>
{
    var productsApiUrl = builder.Configuration["ApiSettings:ProductsApiUrl"] 
        ?? "https://localhost:7001";
    client.BaseAddress = new Uri(productsApiUrl);
    client.Timeout = TimeSpan.FromSeconds(30);
})
.AddPolicyHandler(GetRetryPolicy())
.AddPolicyHandler(GetCircuitBreakerPolicy());

// StoreInfo API Client
builder.Services.AddHttpClient<StoreInfoApiClient>(client =>
{
    var storeInfoApiUrl = builder.Configuration["ApiSettings:StoreInfoApiUrl"] 
        ?? "https://localhost:7002";
    client.BaseAddress = new Uri(storeInfoApiUrl);
    client.Timeout = TimeSpan.FromSeconds(30);
})
.AddPolicyHandler(GetRetryPolicy())
.AddPolicyHandler(GetCircuitBreakerPolicy());

// Add health checks
builder.Services.AddHealthChecks()
    .AddUrlGroup(new Uri("https://localhost:7001/api/products"), name: "products-api")
    .AddUrlGroup(new Uri("https://localhost:7002/api/stores"), name: "storeinfo-api");

// Add response compression
builder.Services.AddResponseCompression(options =>
{
    options.EnableForHttps = true;
});

// Add memory cache
builder.Services.AddMemoryCache();

var app = builder.Build();

// Log application startup
var logger = app.Services.GetRequiredService<ILogger<Program>>();
logger.LogInformation("========================================");
logger.LogInformation("eShopLite.Store Application Starting (Microservices)");
logger.LogInformation("========================================");
logger.LogInformation("Environment: {Environment}", app.Environment.EnvironmentName);
logger.LogInformation("Products API: {ProductsApi}", builder.Configuration["ApiSettings:ProductsApiUrl"] ?? "https://localhost:7001");
logger.LogInformation("StoreInfo API: {StoreInfoApi}", builder.Configuration["ApiSettings:StoreInfoApiUrl"] ?? "https://localhost:7002");

// Configure the HTTP request pipeline
if (app.Environment.IsDevelopment())
{
    app.UseDeveloperExceptionPage();
}
else
{
    app.UseExceptionHandler("/Error");
    app.UseHsts();
}

app.UseHttpsRedirection();
app.UseStaticFiles();
app.UseResponseCompression();
app.UseAntiforgery();

// Map health check endpoint
app.MapHealthChecks("/health");

// Map Blazor components
app.MapRazorComponents<eShopLite.Store.Components.App>()
    .AddInteractiveServerRenderMode();

logger.LogInformation("========================================");
logger.LogInformation("eShopLite.Store Started Successfully");
logger.LogInformation("========================================");

app.Run();

// Resilience policies
static IAsyncPolicy<HttpResponseMessage> GetRetryPolicy()
{
    return HttpPolicyExtensions
        .HandleTransientHttpError()
        .WaitAndRetryAsync(3, retryAttempt => TimeSpan.FromSeconds(Math.Pow(2, retryAttempt)));
}

static IAsyncPolicy<HttpResponseMessage> GetCircuitBreakerPolicy()
{
    return HttpPolicyExtensions
        .HandleTransientHttpError()
        .CircuitBreakerAsync(5, TimeSpan.FromSeconds(30));
}
```

#### Step 3.5: Update appsettings.json
**File**: `src/eShopLite.Store/appsettings.json`

```json
{
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  },
  "ApiSettings": {
    "ProductsApiUrl": "https://localhost:7001",
    "StoreInfoApiUrl": "https://localhost:7002"
  },
  "AllowedHosts": "*"
}
```

#### Step 3.6: Update Products.razor
**File**: `src/eShopLite.Store/Components/Pages/Products.razor`

```razor
@page "/products"
@inject ProductApiClient ProductApiClient
@inject ILogger<Products> Logger
@inject IJSRuntime JSRuntime
@attribute [Microsoft.AspNetCore.OutputCaching.OutputCache(Duration = 10)]
@rendermode InteractiveServer

<PageTitle>Products - eShopLite</PageTitle>

<div class="container py-4">
    <div class="mb-4">
        <h1 class="mb-2">
            <i class="bi bi-box-seam text-primary me-2"></i>
            Our Products
        </h1>
        <p class="text-muted">Browse our collection of premium outdoor gear</p>
    </div>

    @if (!string.IsNullOrEmpty(errorMessage))
    {
        <div class="alert alert-danger alert-dismissible fade show" role="alert">
            <i class="bi bi-exclamation-triangle-fill me-2"></i>
            @errorMessage
            <button type="button" class="btn-close" @onclick="ClearError" aria-label="Close"></button>
        </div>
    }

    @if (isLoading)
    {
        <div class="text-center py-5">
            <div class="spinner-border text-primary" role="status" style="width: 3rem; height: 3rem;">
                <span class="visually-hidden">Loading products...</span>
            </div>
            <p class="mt-3 text-muted">Loading premium outdoor gear...</p>
        </div>
    }
    else if (products == null || !products.Any())
    {
        <div class="text-center py-5">
            <i class="bi bi-box display-1 text-muted"></i>
            <h3 class="mt-3">No Products Available</h3>
            <p class="text-muted mb-4">We're currently updating our inventory. Please check back soon!</p>
            <button class="btn btn-primary btn-lg" @onclick="RefreshProducts">
                <i class="bi bi-arrow-clockwise me-2"></i>Try Again
            </button>
        </div>
    }
    else
    {
        <div class="mb-3">
            <small class="text-muted">
                <i class="bi bi-info-circle me-1"></i>
                Showing @products.Count() products | Last updated: @DateTime.Now.ToString("HH:mm:ss")
            </small>
        </div>

        <div class="row row-cols-1 row-cols-md-2 row-cols-lg-3 row-cols-xl-4 g-4">
            @foreach (var product in products)
            {
                <div class="col">
                    <div class="card h-100">
                        <div class="position-relative" style="height: 250px; overflow: hidden;">
                            <img src="/images/@product.ImageUrl" 
                                 alt="@product.Name" 
                                 class="card-img-top w-100 h-100"
                                 style="object-fit: cover;"
                                 loading="lazy">
                            <div class="position-absolute top-0 end-0 m-2">
                                <span class="badge bg-primary">#@product.Id</span>
                            </div>
                        </div>
                        <div class="card-body d-flex flex-column">
                            <h5 class="card-title">@product.Name</h5>
                            <p class="card-text text-muted small flex-grow-1">
                                @product.Description
                            </p>
                            <div class="mt-auto">
                                <div class="d-flex justify-content-between align-items-center">
                                    <span class="h4 text-success mb-0 fw-bold">
                                        $@product.Price.ToString("F2")
                                    </span>
                                    <button class="btn btn-sm btn-outline-primary">
                                        <i class="bi bi-cart-plus me-1"></i>Add
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            }
        </div>
    }
</div>

@code {
    private IEnumerable<Product>? products;
    private bool isLoading = true;
    private string? errorMessage;

    protected override async Task OnInitializedAsync()
    {
        await LoadProducts();
    }

    private async Task LoadProducts()
    {
        try
        {
            isLoading = true;
            errorMessage = null;
            
            Logger.LogInformation("Loading products from API");
            products = await ProductApiClient.GetProductsAsync();
            Logger.LogInformation("Loaded {Count} products", products?.Count() ?? 0);
        }
        catch (Exception ex)
        {
            Logger.LogError(ex, "Error loading products");
            errorMessage = "Unable to load products. Please try again later.";
        }
        finally
        {
            isLoading = false;
        }
    }

    private async Task RefreshProducts()
    {
        await LoadProducts();
    }

    private void ClearError()
    {
        errorMessage = null;
    }
}
```

#### Step 3.7: Update Stores.razor
**File**: `src/eShopLite.Store/Components/Pages/Stores.razor`

```razor
@page "/stores"
@inject StoreInfoApiClient StoreInfoApiClient
@inject ILogger<Stores> Logger
@rendermode InteractiveServer

<PageTitle>Stores - eShopLite</PageTitle>

<div class="container py-4">
    <div class="mb-4">
        <h1 class="mb-2">
            <i class="bi bi-shop text-success me-2"></i>
            Our Stores
        </h1>
        <p class="text-muted">Find a store near you</p>
    </div>

    @if (!string.IsNullOrEmpty(errorMessage))
    {
        <div class="alert alert-danger alert-dismissible fade show" role="alert">
            <i class="bi bi-exclamation-triangle-fill me-2"></i>
            @errorMessage
            <button type="button" class="btn-close" @onclick="ClearError" aria-label="Close"></button>
        </div>
    }

    @if (isLoading)
    {
        <div class="text-center py-5">
            <div class="spinner-border text-success" role="status" style="width: 3rem; height: 3rem;">
                <span class="visually-hidden">Loading store information...</span>
            </div>
            <p class="mt-3 text-muted">Loading store locations...</p>
        </div>
    }
    else if (stores == null || !stores.Any())
    {
        <div class="alert alert-info">
            <i class="bi bi-info-circle me-2"></i>
            No stores available at this time.
        </div>
    }
    else
    {
        <div class="row row-cols-1 row-cols-md-2 row-cols-lg-3 g-4">
            @foreach (var store in stores)
            {
                <div class="col">
                    <div class="card h-100">
                        <div class="card-body">
                            <div class="d-flex align-items-center mb-3">
                                <div class="bg-success bg-opacity-10 rounded-circle p-3 me-3">
                                    <i class="bi bi-shop fs-3 text-success"></i>
                                </div>
                                <div>
                                    <h5 class="card-title mb-0">@store.Name</h5>
                                </div>
                            </div>
                            
                            <div class="mb-3">
                                <div class="d-flex align-items-start mb-2">
                                    <i class="bi bi-geo-alt-fill text-danger me-2 mt-1"></i>
                                    <div>
                                        <strong>Location:</strong><br>
                                        <span class="text-muted">@store.City, @store.State</span>
                                    </div>
                                </div>
                                
                                <div class="d-flex align-items-start">
                                    <i class="bi bi-clock-fill text-primary me-2 mt-1"></i>
                                    <div>
                                        <strong>Hours:</strong><br>
                                        <span class="text-muted">@store.Hours</span>
                                    </div>
                                </div>
                            </div>
                            
                            <div class="mt-auto">
                                <button class="btn btn-outline-success btn-sm w-100">
                                    <i class="bi bi-map me-1"></i>Get Directions
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
            }
        </div>
    }
</div>

@code {
    private IEnumerable<StoreInfo>? stores;
    private bool isLoading = true;
    private string? errorMessage;

    protected override async Task OnInitializedAsync()
    {
        await LoadStores();
    }

    private async Task LoadStores()
    {
        try
        {
            isLoading = true;
            errorMessage = null;
            
            Logger.LogInformation("Loading stores from API");
            stores = await StoreInfoApiClient.GetStoresAsync();
            Logger.LogInformation("Loaded {Count} stores", stores?.Count() ?? 0);
        }
        catch (Exception ex)
        {
            Logger.LogError(ex, "Error loading stores");
            errorMessage = "Unable to load stores. Please try again later.";
        }
        finally
        {
            isLoading = false;
        }
    }

    private void ClearError()
    {
        errorMessage = null;
    }
}
```

#### Step 3.8: Remove Old Services
- **Delete**: `src/eShopLite.Store/Services/ProductService.cs`
- **Delete**: `src/eShopLite.Store/Services/StoreService.cs`
- **Delete**: `src/eShopLite.Store/Data/StoreDbContext.cs`

#### Step 3.9: Add NuGet Packages
```powershell
cd src/eShopLite.Store

# Add Polly for resilience
dotnet add package Microsoft.Extensions.Http.Polly

# Add health checks
dotnet add package AspNetCore.HealthChecks.Uris
```

---

### Phase 4: Testing & Validation

**Duration**: 2-3 hours

#### Step 4.1: Build All Projects
```powershell
# Build Products API
dotnet build src/eShopLite.Products/eShopLite.Products.csproj

# Build StoreInfo API
dotnet build src/eShopLite.StoreInfo/eShopLite.StoreInfo.csproj

# Build Store UI
dotnet build src/eShopLite.Store/eShopLite.Store.csproj
```

#### Step 4.2: Run All Services

**Terminal 1 - Products API**:
```powershell
dotnet run --project src/eShopLite.Products/eShopLite.Products.csproj
# Should start on https://localhost:7001
```

**Terminal 2 - StoreInfo API**:
```powershell
dotnet run --project src/eShopLite.StoreInfo/eShopLite.StoreInfo.csproj
# Should start on https://localhost:7002
```

**Terminal 3 - Store UI**:
```powershell
dotnet run --project src/eShopLite.Store/eShopLite.Store.csproj
# Should start on https://localhost:5001
```

#### Step 4.3: Test API Endpoints

**Products API**:
```bash
# Get all products
curl https://localhost:7001/api/products

# Get product by ID
curl https://localhost:7001/api/products/1

# Open Swagger
# Navigate to: https://localhost:7001/swagger
```

**StoreInfo API**:
```bash
# Get all stores
curl https://localhost:7002/api/stores

# Get store by ID
curl https://localhost:7002/api/stores/1

# Open Swagger
# Navigate to: https://localhost:7002/swagger
```

#### Step 4.4: Test UI

**Functional Tests**:
- [ ] Navigate to https://localhost:5001
- [ ] Home page loads
- [ ] Products page displays all 9 products
- [ ] Product cards show images, names, descriptions, prices
- [ ] Stores page displays all 9 stores
- [ ] Store cards show names, locations, hours
- [ ] Navigation works
- [ ] No console errors (F12)

**Visual Tests**:
- [ ] Layout unchanged
- [ ] CSS styles applied correctly
- [ ] Bootstrap components work
- [ ] Responsive design works
- [ ] Images load correctly

**Performance Tests**:
- [ ] Products page loads in < 2 seconds
- [ ] Stores page loads in < 2 seconds
- [ ] No significant latency increase

#### Step 4.5: Test Error Handling

**Stop Products API**:
- [ ] Products page shows error message
- [ ] Error message is user-friendly
- [ ] No application crash
- [ ] Can retry loading

**Stop StoreInfo API**:
- [ ] Stores page shows error message
- [ ] Error message is user-friendly
- [ ] No application crash

---

## 📊 Verification Checklist

### Functionality Verification
- [ ] All 9 products display on Products page
- [ ] All 9 stores display on Stores page
- [ ] Product images load correctly
- [ ] Product prices display correctly
- [ ] Store locations display correctly
- [ ] Store hours display correctly
- [ ] Navigation between pages works
- [ ] Home page loads
- [ ] No features added
- [ ] No features removed
- [ ] No features altered

### Technical Verification
- [ ] Products API running on port 7001
- [ ] StoreInfo API running on port 7002
- [ ] Store UI running on port 5001
- [ ] Products.db created and seeded
- [ ] StoreInfo.db created and seeded
- [ ] Swagger UI accessible for both APIs
- [ ] Health checks working
- [ ] Logs showing API calls
- [ ] No errors in console

### Architecture Verification
- [ ] ProductDbContext separate from StoreInfoDbContext
- [ ] Products API uses Minimal API approach
- [ ] StoreInfo API uses Minimal API approach
- [ ] No Controllers in API projects
- [ ] ProductApiClient inherits from ApiClient
- [ ] StoreInfoApiClient inherits from ApiClient
- [ ] UI communicates via HttpClient only
- [ ] No direct database access from UI

### Quality Verification
- [ ] All projects build successfully
- [ ] No build warnings
- [ ] Naming conventions followed
- [ ] Code properly commented
- [ ] Logging implemented
- [ ] Error handling implemented
- [ ] Retry policies configured
- [ ] Circuit breakers configured

---

## 🚀 Deployment Configuration

### Docker Compose (Optional)
**File**: `docker-compose.yml`

```yaml
version: '3.8'

services:
  products-api:
    build:
      context: ./src/eShopLite.Products
      dockerfile: Dockerfile
    ports:
      - "7001:80"
    environment:
      - ASPNETCORE_ENVIRONMENT=Development
      - ASPNETCORE_URLS=http://+:80
    volumes:
      - products-data:/app/data

  storeinfo-api:
    build:
      context: ./src/eShopLite.StoreInfo
      dockerfile: Dockerfile
    ports:
      - "7002:80"
    environment:
      - ASPNETCORE_ENVIRONMENT=Development
      - ASPNETCORE_URLS=http://+:80
    volumes:
      - storeinfo-data:/app/data

  store-ui:
    build:
      context: ./src/eShopLite.Store
      dockerfile: Dockerfile
    ports:
      - "5001:80"
    environment:
      - ASPNETCORE_ENVIRONMENT=Development
      - ASPNETCORE_URLS=http://+:80
      - ApiSettings__ProductsApiUrl=http://products-api:80
      - ApiSettings__StoreInfoApiUrl=http://storeinfo-api:80
    depends_on:
      - products-api
      - storeinfo-api

volumes:
  products-data:
  storeinfo-data:
```

---

## 📝 Migration Summary

### What Changed
✅ **Architecture**: Monolith → Microservices (3 applications)  
✅ **Database**: Single DB → 2 separate SQLite databases  
✅ **API Style**: N/A → Minimal APIs  
✅ **Communication**: Direct DB access → HTTP/REST APIs  
✅ **Resilience**: N/A → Retry policies + Circuit breakers  

### What Did NOT Change
❌ **Features**: No new features, no removed features  
❌ **UI/UX**: Layout, styling, JavaScript unchanged  
❌ **Data**: Same 9 products, same 9 stores  
❌ **Functionality**: All existing features work identically  

### Benefits Gained
✅ **Scalability**: Each service can scale independently  
✅ **Maintainability**: Clear separation of concerns  
✅ **Deployability**: Deploy services independently  
✅ **Resilience**: Failure isolation between services  
✅ **Technology Freedom**: Each service can use different tech stack  

### Trade-offs
⚠️ **Complexity**: More moving parts to manage  
⚠️ **Latency**: Network calls add overhead  
⚠️ **Debugging**: Distributed tracing needed  
⚠️ **Data Consistency**: Eventual consistency model  
⚠️ **Infrastructure**: More services to deploy and monitor  

---

## 🎯 Success Criteria

Migration is successful when:
1. ✅ All 3 applications build without errors
2. ✅ All 3 applications run concurrently
3. ✅ Products page displays all 9 products correctly
4. ✅ Stores page displays all 9 stores correctly
5. ✅ UI looks identical to original
6. ✅ No new features added
7. ✅ No existing features broken
8. ✅ APIs follow Minimal API approach
9. ✅ API clients inherit from base ApiClient
10. ✅ Each service has its own SQLite database

---

## 📚 Next Steps (Post-Migration)

### Immediate
1. Create automated tests (unit, integration, E2E)
2. Set up CI/CD pipelines for each service
3. Configure logging aggregation (e.g., Seq, Application Insights)
4. Implement distributed tracing (e.g., OpenTelemetry)

### Short-term
1. Add API versioning
2. Implement API authentication/authorization
3. Add rate limiting
4. Set up monitoring and alerting
5. Create API documentation

### Long-term
1. Consider API Gateway (e.g., YARP, Ocelot)
2. Implement event-driven communication
3. Add message queue (e.g., RabbitMQ, Azure Service Bus)
4. Consider containerization (Docker)
5. Plan for Kubernetes deployment

---

**Document Version**: 1.0  
**Created**: 2026-01-03  
**Using**: Microsoft Learn MCP + Sequential Thinking MCP  
