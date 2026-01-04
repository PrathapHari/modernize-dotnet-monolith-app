# Skill: Configure Aspire Service

Configures a new microservice in the .NET Aspire AppHost with proper dependencies and service discovery.

## Usage
"Add a new [ServiceName] service to Aspire"
"Configure [ServiceName] microservice with [Database] database"

## AppHost Service Registration

### Service with PostgreSQL Database
```csharp
var [service]db = builder.AddPostgres("pg-[service]")
                        .WithPgAdmin()
                        .AddDatabase("[service]db");

var [service] = builder.AddProject<Projects.[ServiceName]>("[service-name]")
                       .WithReference([service]db)
                       .WaitFor([service]db);
```

### Service with Redis
```csharp
var redis = builder.AddRedis("redis");

var [service] = builder.AddProject<Projects.[ServiceName]>("[service-name]")
                       .WithReference(redis)
                       .WaitFor(redis);
```

### Service with Multiple Dependencies
```csharp
var db = builder.AddPostgres("pg-[service]")
                .WithPgAdmin()
                .AddDatabase("[service]db");

var redis = builder.AddRedis("redis");

var [service] = builder.AddProject<Projects.[ServiceName]>("[service-name]")
                       .WithReference(db)
                       .WithReference(redis)
                       .WaitFor(db)
                       .WaitFor(redis);
```

### Frontend Service with Backend Dependencies
```csharp
var products = builder.AddProject<Projects.Products>("products")
                      .WithReference(productsDb)
                      .WaitFor(productsDb);

var storeInfo = builder.AddProject<Projects.StoreInfo>("storeinfo")
                       .WithReference(storeInfoDb)
                       .WaitFor(storeInfoDb);

builder.AddProject<Projects.Store>("store")
       .WithExternalHttpEndpoints()
       .WithReference(products)
       .WithReference(storeInfo)
       .WaitFor(products)
       .WaitFor(storeInfo);
```

## Service Project Program.cs Configuration

### Basic Service Setup
```csharp
using Microsoft.EntityFrameworkCore;
using [ServiceName].Data;
using [ServiceName].Models;

var builder = WebApplication.CreateBuilder(args);

// Add Aspire service defaults
builder.AddServiceDefaults();

// Add services to the container
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddOpenApi();

// Configure database
builder.Services.AddDbContext<[Service]DbContext>(options =>
    options.UseNpgsql(builder.Configuration.GetConnectionString("[service]db") 
        ?? throw new InvalidOperationException("Connection string '[service]db' not found.")));

// Add CORS for Blazor UI app
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

// Map default Aspire endpoints (health checks)
app.MapDefaultEndpoints();

// Configure the HTTP request pipeline
if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
}

app.UseHttpsRedirection();
app.UseCors("AllowBlazorApp");

// Map API endpoints here

// Initialize database on startup
using (var scope = app.Services.CreateScope())
{
    var db = scope.ServiceProvider.GetRequiredService<[Service]DbContext>();
    var startupLogger = scope.ServiceProvider.GetRequiredService<ILogger<Program>>();
    
    try
    {
        startupLogger.LogInformation("========================================");
        startupLogger.LogInformation("Initializing {Service} database...", "[ServiceName]");
        await db.Database.EnsureCreatedAsync();
        
        var count = await db.[Entities].CountAsync();
        startupLogger.LogInformation("{Service} database initialized successfully", "[ServiceName]");
        startupLogger.LogInformation("Database contains {Count} entities", count);
        startupLogger.LogInformation("========================================");
    }
    catch (Exception ex)
    {
        startupLogger.LogError(ex, "Error initializing {Service} database", "[ServiceName]");
        throw;
    }
}

app.Run();
```

### Service with HTTP Client
```csharp
var builder = WebApplication.CreateBuilder(args);

builder.AddServiceDefaults();

// Add HTTP client for another service
builder.Services.AddHttpClient<OtherServiceClient>(client =>
{
    client.BaseAddress = new Uri("https+http://other-service");
})
.AddServiceDiscovery()
.AddStandardResilienceHandler();

// Rest of configuration...
```

## DbContext Configuration

### PostgreSQL DbContext
```csharp
using Microsoft.EntityFrameworkCore;
using [ServiceName].Models;

namespace [ServiceName].Data;

public class [Service]DbContext : DbContext
{
    public [Service]DbContext(DbContextOptions<[Service]DbContext> options)
        : base(options)
    {
    }

    public DbSet<[Entity]> [Entities] => Set<[Entity]>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);
        
        // Configure entity
        modelBuilder.Entity<[Entity]>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Name).IsRequired().HasMaxLength(200);
        });
        
        // Seed data
        modelBuilder.Entity<[Entity]>().HasData(
            new [Entity] { Id = 1, Name = "Sample" }
        );
    }
}
```

## Critical Rules

### ❌ DO NOT
- **NEVER** add "Urls" configuration to appsettings.json
- **NEVER** hardcode connection strings
- **NEVER** hardcode service URLs or ports
- **NEVER** use static port assignments

### ✅ ALWAYS
- Use `builder.AddServiceDefaults()` in service Program.cs
- Use `app.MapDefaultEndpoints()` for health checks
- Use connection string name matching AppHost database name
- Use `.WaitFor()` for proper startup ordering
- Use service discovery for inter-service communication
- Let Aspire manage all URL and port assignments

## Connection String Naming

The connection string name in the service **MUST** match the database name in AppHost:

**AppHost:**
```csharp
var db = builder.AddPostgres("pg-products")
                .AddDatabase("productsdb");  // <- This name

var service = builder.AddProject<Projects.Products>("products")
                     .WithReference(db);
```

**Service Program.cs:**
```csharp
builder.Services.AddDbContext<ProductDbContext>(options =>
    options.UseNpgsql(
        builder.Configuration.GetConnectionString("productsdb")  // <- Must match
    ));
```

## appsettings.json Configuration

### ✅ Correct (No URLs)
```json
{
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  },
  "ConnectionStrings": {
    "[service]db": ""
  },
  "AllowedHosts": "*"
}
```

### ❌ Incorrect (Hardcoded URLs)
```json
{
  "Urls": "https://localhost:7001",  // NEVER DO THIS
  "ConnectionStrings": {
    "DefaultConnection": "Data Source=app.db"  // Wrong for Aspire
  }
}
```

## Service Discovery Setup

### API Client with Service Discovery
```csharp
// In Store/Program.cs
builder.Services.AddHttpClient<ProductApiClient>(client =>
{
    // Use service name from AppHost, not hardcoded URL
    client.BaseAddress = new Uri("https+http://products");
})
.AddServiceDiscovery()
.AddStandardResilienceHandler();
```

## Examples

### Input
"Add a new Reviews microservice to Aspire with PostgreSQL database"

### Output
**AppHost:**
```csharp
var reviewsdb = builder.AddPostgres("pg-reviews")
                       .WithPgAdmin()
                       .AddDatabase("reviewsdb");

var reviews = builder.AddProject<Projects.eShopLite_Reviews>("eshoplite-reviews")
                     .WithReference(reviewsdb)
                     .WaitFor(reviewsdb);
```

**Reviews/Program.cs:**
```csharp
var builder = WebApplication.CreateBuilder(args);

builder.AddServiceDefaults();

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddOpenApi();

builder.Services.AddDbContext<ReviewDbContext>(options =>
    options.UseNpgsql(builder.Configuration.GetConnectionString("reviewsdb") 
        ?? throw new InvalidOperationException("Connection string 'reviewsdb' not found.")));

var app = builder.Build();

app.MapDefaultEndpoints();

// Configure middleware and endpoints

app.Run();
```
