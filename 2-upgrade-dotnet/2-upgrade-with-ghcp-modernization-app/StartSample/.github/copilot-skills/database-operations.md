# Skill: Database Operations with Entity Framework Core

Creates and manages database entities, DbContext, and migrations following eShopLite patterns.

## Usage
"Create a database entity for [Entity]"
"Add a migration to [modify/add/remove] [entity/column]"
"Set up DbContext for [Service] with [entities]"

## Entity Model Pattern

### Basic Entity
```csharp
namespace [ServiceName].Models;

public class [Entity]
{
    public int Id { get; set; }
    
    public required string Name { get; set; }
    
    public string? Description { get; set; }
    
    public decimal Price { get; set; }
    
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    
    public DateTime? UpdatedAt { get; set; }
}
```

### Entity with Relationships
```csharp
namespace [ServiceName].Models;

public class Order
{
    public int Id { get; set; }
    
    public required string CustomerName { get; set; }
    
    public DateTime OrderDate { get; set; } = DateTime.UtcNow;
    
    public decimal TotalAmount { get; set; }
    
    // Navigation property
    public ICollection<OrderItem> Items { get; set; } = new List<OrderItem>();
}

public class OrderItem
{
    public int Id { get; set; }
    
    public int OrderId { get; set; }
    
    public int ProductId { get; set; }
    
    public int Quantity { get; set; }
    
    public decimal UnitPrice { get; set; }
    
    // Navigation property
    public Order? Order { get; set; }
}
```

## DbContext Pattern

### Basic DbContext
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
            
            entity.Property(e => e.Name)
                .IsRequired()
                .HasMaxLength(200);
            
            entity.Property(e => e.Price)
                .HasPrecision(18, 2);
            
            entity.HasIndex(e => e.Name);
        });
        
        // Seed data
        modelBuilder.Entity<[Entity]>().HasData(
            new [Entity] 
            { 
                Id = 1, 
                Name = "Sample Item", 
                Description = "Sample description",
                Price = 99.99m,
                CreatedAt = DateTime.UtcNow
            }
        );
    }
}
```

### DbContext with Relationships
```csharp
protected override void OnModelCreating(ModelBuilder modelBuilder)
{
    base.OnModelCreating(modelBuilder);
    
    // Configure Order
    modelBuilder.Entity<Order>(entity =>
    {
        entity.HasKey(e => e.Id);
        
        entity.Property(e => e.CustomerName)
            .IsRequired()
            .HasMaxLength(100);
        
        entity.Property(e => e.TotalAmount)
            .HasPrecision(18, 2);
        
        // One-to-many relationship
        entity.HasMany(e => e.Items)
            .WithOne(i => i.Order)
            .HasForeignKey(i => i.OrderId)
            .OnDelete(DeleteBehavior.Cascade);
    });
    
    // Configure OrderItem
    modelBuilder.Entity<OrderItem>(entity =>
    {
        entity.HasKey(e => e.Id);
        
        entity.Property(e => e.UnitPrice)
            .HasPrecision(18, 2);
    });
}
```

## Database Initialization Pattern

### Startup Initialization
```csharp
// In Program.cs, before app.Run()
using (var scope = app.Services.CreateScope())
{
    var db = scope.ServiceProvider.GetRequiredService<[Service]DbContext>();
    var startupLogger = scope.ServiceProvider.GetRequiredService<ILogger<Program>>();
    
    try
    {
        startupLogger.LogInformation("========================================");
        startupLogger.LogInformation("Initializing {Service} database...", "[ServiceName]");
        await db.Database.EnsureCreatedAsync();
        
        var entityCount = await db.[Entities].CountAsync();
        startupLogger.LogInformation("{Service} database initialized successfully", "[ServiceName]");
        startupLogger.LogInformation("Database contains {Count} {EntityType}", entityCount, nameof([Entity]));
        startupLogger.LogInformation("========================================");
    }
    catch (Exception ex)
    {
        startupLogger.LogError(ex, "Error initializing {Service} database", "[ServiceName]");
        throw;
    }
}
```

## Query Patterns

### Basic Queries
```csharp
// Get all
var entities = await db.[Entities].ToListAsync();

// Get by ID
var entity = await db.[Entities].FindAsync(id);

// Get with filter
var filtered = await db.[Entities]
    .Where(e => e.Price > 50)
    .ToListAsync();

// Get with sorting
var sorted = await db.[Entities]
    .OrderBy(e => e.Name)
    .ToListAsync();

// Read-only query (better performance)
var readOnly = await db.[Entities]
    .AsNoTracking()
    .ToListAsync();
```

### Complex Queries
```csharp
// Include related data
var orders = await db.Orders
    .Include(o => o.Items)
    .ToListAsync();

// Filter and include
var recentOrders = await db.Orders
    .Include(o => o.Items)
    .Where(o => o.OrderDate > DateTime.UtcNow.AddDays(-30))
    .OrderByDescending(o => o.OrderDate)
    .ToListAsync();

// Projection
var orderSummary = await db.Orders
    .Select(o => new
    {
        o.Id,
        o.CustomerName,
        o.TotalAmount,
        ItemCount = o.Items.Count
    })
    .ToListAsync();

// Pagination
var page = 1;
var pageSize = 10;
var pagedResults = await db.[Entities]
    .Skip((page - 1) * pageSize)
    .Take(pageSize)
    .ToListAsync();
```

## Create/Update/Delete Patterns

### Create
```csharp
var entity = new [Entity]
{
    Name = "New Item",
    Description = "Description",
    Price = 99.99m
};

db.[Entities].Add(entity);
await db.SaveChangesAsync();

logger.LogInformation("Created {EntityType} with ID: {Id}", nameof([Entity]), entity.Id);
```

### Update
```csharp
var entity = await db.[Entities].FindAsync(id);
if (entity is not null)
{
    entity.Name = "Updated Name";
    entity.Price = 79.99m;
    entity.UpdatedAt = DateTime.UtcNow;
    
    await db.SaveChangesAsync();
    
    logger.LogInformation("Updated {EntityType} with ID: {Id}", nameof([Entity]), id);
}
```

### Delete
```csharp
var entity = await db.[Entities].FindAsync(id);
if (entity is not null)
{
    db.[Entities].Remove(entity);
    await db.SaveChangesAsync();
    
    logger.LogInformation("Deleted {EntityType} with ID: {Id}", nameof([Entity]), id);
}
```

## Migration Commands

### Create Migration
```bash
# From solution root
dotnet ef migrations add [MigrationName] --project src/[ServiceName]/[ServiceName].csproj

# Examples:
dotnet ef migrations add InitialCreate --project src/eShopLite.Products/eShopLite.Products.csproj
dotnet ef migrations add AddDescriptionToProduct --project src/eShopLite.Products/eShopLite.Products.csproj
```

### Apply Migration
```bash
dotnet ef database update --project src/[ServiceName]/[ServiceName].csproj
```

### Remove Last Migration
```bash
dotnet ef migrations remove --project src/[ServiceName]/[ServiceName].csproj
```

## Database Provider Configuration

### PostgreSQL (Production with Aspire)
```csharp
builder.Services.AddDbContext<[Service]DbContext>(options =>
    options.UseNpgsql(builder.Configuration.GetConnectionString("[service]db") 
        ?? throw new InvalidOperationException("Connection string '[service]db' not found.")));
```

### SQLite (Development/Testing)
```csharp
builder.Services.AddDbContext<[Service]DbContext>(options =>
    options.UseSqlite(builder.Configuration.GetConnectionString("DefaultConnection") 
        ?? "Data Source=[Service].db"));
```

### In-Memory (Unit Testing)
```csharp
builder.Services.AddDbContext<[Service]DbContext>(options =>
    options.UseInMemoryDatabase("[Service]TestDb"));
```

## Common Entity Configurations

### Timestamp Fields
```csharp
modelBuilder.Entity<[Entity]>(entity =>
{
    entity.Property(e => e.CreatedAt)
        .HasDefaultValueSql("CURRENT_TIMESTAMP");
    
    entity.Property(e => e.UpdatedAt)
        .HasDefaultValueSql("CURRENT_TIMESTAMP");
});
```

### Unique Constraints
```csharp
modelBuilder.Entity<[Entity]>(entity =>
{
    entity.HasIndex(e => e.Email)
        .IsUnique();
});
```

### Composite Keys
```csharp
modelBuilder.Entity<[Entity]>(entity =>
{
    entity.HasKey(e => new { e.UserId, e.ProductId });
});
```

### Enums
```csharp
public enum OrderStatus
{
    Pending,
    Processing,
    Shipped,
    Delivered,
    Cancelled
}

modelBuilder.Entity<Order>(entity =>
{
    entity.Property(e => e.Status)
        .HasConversion<string>();  // Store as string in database
});
```

## Examples

### Input
"Create a Review entity with rating, comment, and product reference"

### Output
```csharp
namespace eShopLite.Reviews.Models;

public class Review
{
    public int Id { get; set; }
    
    public int ProductId { get; set; }
    
    public required string CustomerName { get; set; }
    
    public int Rating { get; set; }  // 1-5
    
    public string? Comment { get; set; }
    
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}

// DbContext configuration
protected override void OnModelCreating(ModelBuilder modelBuilder)
{
    modelBuilder.Entity<Review>(entity =>
    {
        entity.HasKey(e => e.Id);
        
        entity.Property(e => e.CustomerName)
            .IsRequired()
            .HasMaxLength(100);
        
        entity.Property(e => e.Rating)
            .IsRequired();
        
        entity.Property(e => e.Comment)
            .HasMaxLength(1000);
        
        entity.HasIndex(e => e.ProductId);
        
        entity.HasCheckConstraint("CK_Review_Rating", "Rating >= 1 AND Rating <= 5");
    });
}
```
