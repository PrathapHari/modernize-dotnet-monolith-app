# Skill: Create Minimal API Endpoint

Creates RESTful API endpoints following eShopLite Minimal API patterns.

## Usage
"Create an API endpoint to [action] [resource]"
"Add a GET endpoint for retrieving [resource] by ID"

## GET Endpoint (Single Item)
```csharp
app.MapGet("/api/[resources]/{id:int}", async (
    int id, 
    [Resource]DbContext db, 
    ILogger<Program> logger) =>
{
    logger.LogInformation("Retrieving {ResourceType} with ID: {Id}", nameof([Resource]), id);
    var resource = await db.[Resources].FindAsync(id);
    
    return resource is not null 
        ? Results.Ok(resource) 
        : Results.NotFound(new { Message = $"[Resource] with ID {id} not found" });
})
.WithName("Get[Resource]ById")
.WithDescription("Retrieves a specific [resource] by ID");
```

## GET Endpoint (Collection)
```csharp
app.MapGet("/api/[resources]", async (
    [Resource]DbContext db, 
    ILogger<Program> logger) =>
{
    logger.LogInformation("Retrieving all {ResourceType}", nameof([Resource]));
    var resources = await db.[Resources].ToListAsync();
    
    logger.LogInformation("Retrieved {Count} {ResourceType} items", resources.Count, nameof([Resource]));
    return Results.Ok(resources);
})
.WithName("Get[Resources]")
.WithDescription("Retrieves all [resources] from the database");
```

## POST Endpoint (Create)
```csharp
app.MapPost("/api/[resources]", async (
    [Resource] resource,
    [Resource]DbContext db,
    ILogger<Program> logger) =>
{
    logger.LogInformation("Creating new {ResourceType}", nameof([Resource]));
    
    db.[Resources].Add(resource);
    await db.SaveChangesAsync();
    
    logger.LogInformation("Created {ResourceType} with ID: {Id}", nameof([Resource]), resource.Id);
    return Results.Created($"/api/[resources]/{resource.Id}", resource);
})
.WithName("Create[Resource]")
.WithDescription("Creates a new [resource]");
```

## PUT Endpoint (Update)
```csharp
app.MapPut("/api/[resources]/{id:int}", async (
    int id,
    [Resource] updatedResource,
    [Resource]DbContext db,
    ILogger<Program> logger) =>
{
    logger.LogInformation("Updating {ResourceType} with ID: {Id}", nameof([Resource]), id);
    
    var resource = await db.[Resources].FindAsync(id);
    if (resource is null)
    {
        logger.LogWarning("{ResourceType} with ID {Id} not found", nameof([Resource]), id);
        return Results.NotFound(new { Message = $"[Resource] with ID {id} not found" });
    }
    
    // Update properties
    resource.Property = updatedResource.Property;
    
    await db.SaveChangesAsync();
    
    logger.LogInformation("Successfully updated {ResourceType} with ID: {Id}", nameof([Resource]), id);
    return Results.Ok(resource);
})
.WithName("Update[Resource]")
.WithDescription("Updates an existing [resource]");
```

## DELETE Endpoint
```csharp
app.MapDelete("/api/[resources]/{id:int}", async (
    int id,
    [Resource]DbContext db,
    ILogger<Program> logger) =>
{
    logger.LogInformation("Deleting {ResourceType} with ID: {Id}", nameof([Resource]), id);
    
    var resource = await db.[Resources].FindAsync(id);
    if (resource is null)
    {
        logger.LogWarning("{ResourceType} with ID {Id} not found", nameof([Resource]), id);
        return Results.NotFound(new { Message = $"[Resource] with ID {id} not found" });
    }
    
    db.[Resources].Remove(resource);
    await db.SaveChangesAsync();
    
    logger.LogInformation("Successfully deleted {ResourceType} with ID: {Id}", nameof([Resource]), id);
    return Results.NoContent();
})
.WithName("Delete[Resource]")
.WithDescription("Deletes a [resource] by ID");
```

## Query Parameters Example
```csharp
app.MapGet("/api/[resources]/search", async (
    string? query,
    int page = 1,
    int pageSize = 10,
    [Resource]DbContext db,
    ILogger<Program> logger) =>
{
    logger.LogInformation("Searching {ResourceType} with query: {Query}, page: {Page}", 
        nameof([Resource]), query, page);
    
    var queryable = db.[Resources].AsQueryable();
    
    if (!string.IsNullOrEmpty(query))
    {
        queryable = queryable.Where(r => r.Name.Contains(query));
    }
    
    var total = await queryable.CountAsync();
    var resources = await queryable
        .Skip((page - 1) * pageSize)
        .Take(pageSize)
        .ToListAsync();
    
    return Results.Ok(new
    {
        Data = resources,
        Page = page,
        PageSize = pageSize,
        Total = total
    });
})
.WithName("Search[Resources]")
.WithDescription("Searches [resources] with pagination");
```

## Required Elements
- ✅ Async/await for all database operations
- ✅ Structured logging with named parameters
- ✅ Proper HTTP status codes (Ok, NotFound, Created, NoContent, BadRequest)
- ✅ OpenAPI metadata (`.WithName()`, `.WithDescription()`)
- ✅ Route constraints (`:int`, `:guid`, etc.)
- ✅ Error messages in response body
- ✅ ILogger injection
- ✅ DbContext injection

## Validation Pattern
```csharp
app.MapPost("/api/[resources]", async (
    [Resource] resource,
    [Resource]DbContext db,
    ILogger<Program> logger) =>
{
    // Validate input
    if (string.IsNullOrWhiteSpace(resource.Name))
    {
        return Results.BadRequest(new { Message = "Name is required" });
    }
    
    if (resource.Price <= 0)
    {
        return Results.BadRequest(new { Message = "Price must be greater than 0" });
    }
    
    // Create resource
    logger.LogInformation("Creating new {ResourceType}", nameof([Resource]));
    db.[Resources].Add(resource);
    await db.SaveChangesAsync();
    
    return Results.Created($"/api/[resources]/{resource.Id}", resource);
})
.WithName("Create[Resource]")
.WithDescription("Creates a new [resource] with validation");
```

## Examples

### Input
"Create an API endpoint to get all products with optional category filter"

### Output
```csharp
app.MapGet("/api/products", async (
    string? category,
    ProductDbContext db,
    ILogger<Program> logger) =>
{
    logger.LogInformation("Retrieving products with category filter: {Category}", category);
    
    var query = db.Products.AsQueryable();
    
    if (!string.IsNullOrEmpty(category))
    {
        query = query.Where(p => p.Category == category);
    }
    
    var products = await query.ToListAsync();
    
    logger.LogInformation("Retrieved {Count} products", products.Count);
    return Results.Ok(products);
})
.WithName("GetProducts")
.WithDescription("Retrieves all products, optionally filtered by category");
```
