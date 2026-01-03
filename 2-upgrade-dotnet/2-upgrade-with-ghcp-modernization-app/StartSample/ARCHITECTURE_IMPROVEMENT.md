# Architecture Improvement: Separate Product and Store Services

## Problem Statement
Originally, the application had a single `StoreService` that handled both products and stores, which violated the Single Responsibility Principle and created confusion.

## Solution
Split into two dedicated services:

## Architecture Diagram

```
┌──────────────────────────────────────────────────────────────┐
│                      Blazor UI Layer                         │
│                     (Interactive Server)                     │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌─────────────────┐         ┌──────────────────┐          │
│  │ Products.razor  │         │  Stores.razor    │          │
│  │  @page          │         │   @page          │          │
│  │  "/products"    │         │   "/stores"      │          │
│  └────────┬────────┘         └────────┬─────────┘          │
│           │ @inject                   │ @inject             │
│           │ IProductService           │ IStoreService       │
└───────────┼───────────────────────────┼─────────────────────┘
            │                           │
            ▼                           ▼
┌──────────────────────────────────────────────────────────────┐
│                      Service Layer                           │
│                    (Dependency Injection - Scoped)           │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌──────────────────────┐    ┌──────────────────────┐      │
│  │   ProductService     │    │    StoreService      │      │
│  │                      │    │                      │      │
│  │ + GetProductsAsync() │    │ + GetStoresAsync()   │      │
│  │ + GetProductById()   │    │ + GetStoreById()     │      │
│  └──────────┬───────────┘    └──────────┬───────────┘      │
│             │                            │                  │
│             └────────────┬───────────────┘                  │
└──────────────────────────┼──────────────────────────────────┘
                           │
                           ▼
┌──────────────────────────────────────────────────────────────┐
│                      Data Access Layer                       │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│                  IStoreDbContext / StoreDbContext            │
│                  (Entity Framework Core)                     │
│                                                              │
│  ┌────────────────────────────────────────────────┐         │
│  │  DbSet<Product> Products                       │         │
│  │  DbSet<StoreInfo> Stores                       │         │
│  └────────────────────────────────────────────────┘         │
│                           │                                  │
└───────────────────────────┼──────────────────────────────────┘
                            │
                            ▼
                   ┌─────────────────┐
                   │  SQLite Database│
                   │  eShopLite.db   │
                   └─────────────────┘
```

## Service Responsibilities

### ProductService
**Namespace**: `eShopLite.StoreFx.Services`

**Purpose**: Handles all product-related business logic

**Methods**:
- `Task<IEnumerable<Product>> GetProductsAsync()` - Retrieves all products from database
- `Task<Product?> GetProductByIdAsync(int id)` - Retrieves a single product by ID

**Dependencies**:
- `IStoreDbContext` - For database access
- `ILogger<ProductService>` - For logging

**Registration**: `builder.Services.AddScoped<IProductService, ProductService>()`

---

### StoreService
**Namespace**: `eShopLite.StoreFx.Services`

**Purpose**: Handles all store-related business logic

**Methods**:
- `Task<IEnumerable<StoreInfo>> GetStoresAsync()` - Retrieves all stores from database
- `Task<StoreInfo?> GetStoreByIdAsync(int id)` - Retrieves a single store by ID

**Dependencies**:
- `IStoreDbContext` - For database access
- `ILogger<StoreService>` - For logging

**Registration**: `builder.Services.AddScoped<IStoreService, StoreService>()`

---

## Component Usage

### Products.razor
```razor
@page "/products"
@inject IProductService ProductService
@rendermode InteractiveServer

@code {
    private IEnumerable<Product>? products;

    protected override async Task OnInitializedAsync()
    {
        products = await ProductService.GetProductsAsync();
    }
}
```

### Stores.razor
```razor
@page "/stores"
@inject IStoreService StoreService
@rendermode InteractiveServer

@code {
    private IEnumerable<StoreInfo>? stores;

    protected override async Task OnInitializedAsync()
    {
        stores = await StoreService.GetStoresAsync();
    }
}
```

## Benefits

### 1. Single Responsibility Principle (SRP) ✅
Each service has one clear responsibility:
- `ProductService` → Product operations only
- `StoreService` → Store operations only

### 2. Clear Naming Convention ✅
The service name matches its purpose:
- "ProductService" handles products (not confusing!)
- "StoreService" handles stores (not confusing!)

### 3. Easier Testing ✅
```csharp
// Can mock each service independently
public class ProductsPageTests
{
    [Fact]
    public async Task LoadsProducts_WhenServiceReturnsData()
    {
        var mockProductService = new Mock<IProductService>();
        // Test only product-related logic
    }
}
```

### 4. Better Maintainability ✅
- Changes to product logic don't affect store logic
- Each service file is smaller and focused
- Easier to find and fix bugs

### 5. Improved Scalability ✅
Easy to extend each service independently:
```csharp
// Add to ProductService without touching StoreService
public interface IProductService
{
    Task<IEnumerable<Product>> GetProductsAsync();
    Task<Product?> GetProductByIdAsync(int id);
    Task<IEnumerable<Product>> SearchProductsAsync(string query); // NEW
    Task<IEnumerable<Product>> GetProductsByCategoryAsync(string category); // NEW
}
```

### 6. Clear Dependency Graph ✅
Components explicitly declare their dependencies:
- Products page needs `IProductService` only
- Stores page needs `IStoreService` only
- No unnecessary dependencies

## Comparison: Before vs After

### ❌ BEFORE (Anti-Pattern)
```csharp
// One service doing too much
public interface IStoreService
{
    Task<IEnumerable<Product>> GetProductsAsync();    // Products
    Task<Product?> GetProductByIdAsync(int id);       // Products
    Task<IEnumerable<StoreInfo>> GetStoresAsync();    // Stores
    Task<StoreInfo?> GetStoreByIdAsync(int id);       // Stores
}

// Products.razor - Confusing!
@inject IStoreService StoreService  // Why is Products using StoreService??
```

**Problems**:
- Confusing naming (StoreService handles products?)
- Mixed responsibilities
- Hard to test
- Tight coupling

### ✅ AFTER (Clean Architecture)
```csharp
// Separate, focused services
public interface IProductService
{
    Task<IEnumerable<Product>> GetProductsAsync();
    Task<Product?> GetProductByIdAsync(int id);
}

public interface IStoreService
{
    Task<IEnumerable<StoreInfo>> GetStoresAsync();
    Task<StoreInfo?> GetStoreByIdAsync(int id);
}

// Products.razor - Clear!
@inject IProductService ProductService  // Makes sense!

// Stores.razor - Clear!
@inject IStoreService StoreService      // Makes sense!
```

**Benefits**:
- Clear, intuitive naming
- Single responsibility
- Easy to test
- Loose coupling
- Follows SOLID principles

## Future Extensibility

With this architecture, it's easy to:

1. **Add new services** (e.g., `IOrderService`, `ICustomerService`)
2. **Add caching** at the service layer
3. **Implement repository pattern** under services
4. **Add validation** before database operations
5. **Create service decorators** for logging, retry logic, etc.
6. **Switch to microservices** architecture if needed

## Conclusion

This refactoring improves code quality by:
- ✅ Following SOLID principles
- ✅ Creating clear separation of concerns
- ✅ Making the codebase more maintainable
- ✅ Improving testability
- ✅ Setting up for future scalability

The architecture now properly reflects the business domains (Products vs Stores) and makes the system easier to understand, maintain, and extend.
