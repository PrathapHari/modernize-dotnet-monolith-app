# eShopLite Project Instructions

## Architecture Overview
This is a microservices-based e-commerce application built with .NET Aspire, consisting of:
- **eShopLite.Store** / **eShopLite.StoreFx** (Blazor Server) - Frontend UI
- **eShopLite.Products** (Minimal API) - Product catalog service
- **eShopLite.StoreInfo** (Minimal API) - Store information service
- **eShopLite.AppHost** - Aspire orchestration
- **eShopLite.ServiceDefaults** - Shared service defaults

## Coding Standards

### General Rules
- Target: .NET 10, C# 14.0
- Use file-scoped namespaces
- Use top-level statements for Program.cs
- Follow project .editorconfig rules strictly
- Use nullable reference types consistently
- Indent with 4 spaces, not tabs
- Sort using directives with system directives first

### Blazor Component Guidelines
- Use `@rendermode InteractiveServer` for interactive components
- Implement proper loading states with `isLoading` pattern
- Always handle exceptions with user-friendly error messages
- Use Bootstrap 5.3+ for styling with Bootstrap Icons
- Implement proper image error handling with fallbacks
- Add accessibility attributes (alt text, ARIA labels)
- Use semantic HTML elements
- Implement responsive design (grid/list views)
- Cache component state appropriately with `@attribute [OutputCache]`

### API Design
- Use Minimal APIs pattern (not controllers)
- Include OpenAPI/Swagger documentation with `.MapOpenApi()`
- Use proper HTTP status codes (Ok, NotFound, BadRequest)
- Add descriptive `.WithName()` and `.WithDescription()` for endpoints
- Log all API operations with structured logging
- Use async/await consistently
- Implement CORS for Blazor frontend access
- Return strongly-typed results with `Results.Ok()`, `Results.NotFound()`, etc.

### Database Patterns
- Use Entity Framework Core with async methods only
- Aspire manages connection strings - never hardcode URLs or ports
- For PostgreSQL: use `UseNpgsql()`
- For SQLite (dev only): use `UseSqlite()`
- Always use `EnsureCreatedAsync()` for database initialization
- Implement proper using/scope patterns for DbContext
- Seed data in `OnModelCreating()` method
- Use proper foreign key relationships
- Enable cascade delete where appropriate

### Aspire-Specific Rules (CRITICAL)
- **NEVER** hardcode URLs or ports in appsettings.json
- **NEVER** add "Urls" configuration to appsettings.json files
- Let AppHost manage all service URLs and port assignments dynamically
- Use `builder.AddServiceDefaults()` in all service Program.cs
- Use `app.MapDefaultEndpoints()` to add health checks
- Reference services via `.WithReference()` in AppHost
- Use `.WaitFor()` to establish proper startup dependencies
- Connection string names in services must match database names in AppHost
- Use service discovery for inter-service communication

### Service Communication
- Use strongly-typed HTTP clients (e.g., `ProductApiClient`, `StoreInfoApiClient`)
- Configure service discovery with `AddServiceDiscovery()`
- Implement resilience with Polly policies via `AddStandardResilienceHandler()`
- Use OpenTelemetry for distributed tracing
- Handle service unavailability gracefully with try-catch
- Display user-friendly error messages when services are down

### Error Handling
- Log all exceptions with appropriate log levels (Error, Warning, Information)
- Display user-friendly error messages in UI
- Never expose sensitive information in error messages
- Use try-catch-finally with proper cleanup
- Log structured data with named parameters: `logger.LogError(ex, "Error loading {ResourceType} with ID {Id}", resourceType, id)`
- Clear error state when retrying operations

### Logging Standards
- Use `ILogger<T>` injection in all components and services
- Log entry/exit of important operations at Information level
- Log exceptions at Error level with full exception object
- Log warnings for recoverable issues (missing images, timeouts)
- Use Debug level for detailed diagnostic information
- Include correlation IDs for distributed tracing

### Testing Considerations
- Design for testability with dependency injection
- Mock external service dependencies
- Test database operations with in-memory providers
- Test both success and failure scenarios
- Verify error handling and user feedback

## Common Patterns

### Blazor Loading Pattern
Always implement this pattern for async data loading:

```csharp
private List<Entity>? entities;
private bool isLoading = true;
private string? errorMessage;

protected override async Task OnInitializedAsync()
{
    await LoadData();
}

private async Task LoadData()
{
    try
    {
        isLoading = true;
        errorMessage = null;
        StateHasChanged();
        
        Logger.LogInformation("Loading {EntityType} data", nameof(Entity));
        entities = (await ApiClient.GetEntitiesAsync()).ToList();
        Logger.LogInformation("Successfully loaded {Count} {EntityType} items", entities.Count, nameof(Entity));
    }
    catch (Exception ex)
    {
        Logger.LogError(ex, "Error loading {EntityType} data", nameof(Entity));
        errorMessage = "Unable to load data at this time. Please check if the service is running and try again.";
        entities = new List<Entity>();
    }
    finally
    {
        isLoading = false;
        StateHasChanged();
    }
}
```

### Minimal API Endpoint Pattern
Follow this pattern for all API endpoints:

```csharp
app.MapGet("/api/resources/{id:int}", async (
    int id, 
    ResourceDbContext db, 
    ILogger<Program> logger) =>
{
    logger.LogInformation("Retrieving {ResourceType} with ID: {Id}", nameof(Resource), id);
    var resource = await db.Resources.FindAsync(id);
    
    return resource is not null 
        ? Results.Ok(resource) 
        : Results.NotFound(new { Message = $"Resource with ID {id} not found" });
})
.WithName("GetResourceById")
.WithDescription("Retrieves a specific resource by ID");
```

### Database Initialization Pattern
Initialize databases during startup with proper error handling:

```csharp
using (var scope = app.Services.CreateScope())
{
    var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
    var startupLogger = scope.ServiceProvider.GetRequiredService<ILogger<Program>>();
    
    try
    {
        startupLogger.LogInformation("========================================");
        startupLogger.LogInformation("Initializing {Service} database...", "ServiceName");
        await db.Database.EnsureCreatedAsync();
        
        var entityCount = await db.Entities.CountAsync();
        startupLogger.LogInformation("{Service} database initialized successfully", "ServiceName");
        startupLogger.LogInformation("Database contains {Count} entities", entityCount);
        startupLogger.LogInformation("========================================");
    }
    catch (Exception ex)
    {
        startupLogger.LogError(ex, "Error initializing {Service} database", "ServiceName");
        throw;
    }
}
```

### Aspire AppHost Service Registration
Register services in AppHost with proper dependencies:

```csharp
var db = builder.AddPostgres("pg-servicename")
                .WithPgAdmin()
                .AddDatabase("servicenamedb");

var service = builder.AddProject<Projects.ServiceName>("servicename")
                     .WithReference(db)
                     .WaitFor(db);
```

### Service Program.cs Configuration
Configure services with Aspire defaults:

```csharp
var builder = WebApplication.CreateBuilder(args);

builder.AddServiceDefaults();

// Service-specific configuration
builder.Services.AddDbContext<ServiceDbContext>(options =>
    options.UseNpgsql(builder.Configuration.GetConnectionString("servicenamedb") 
        ?? throw new InvalidOperationException("Connection string 'servicenamedb' not found.")));

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

app.MapDefaultEndpoints();

// Configure middleware
app.UseHttpsRedirection();
app.UseCors("AllowBlazorApp");

// Map endpoints

app.Run();
```

## Common Development Tasks

### Adding a New Microservice
1. Create new Web API project in `src/` folder
2. Add PackageReference to `eShopLite.ServiceDefaults`
3. Configure Program.cs with `AddServiceDefaults()` and `MapDefaultEndpoints()`
4. Add database if needed with EF Core DbContext
5. Add service to AppHost with appropriate dependencies
6. **DO NOT** add "Urls" to appsettings.json
7. Add OpenAPI documentation with `AddOpenApi()` and `MapOpenApi()`
8. Create corresponding API client in Store project if needed
9. Register API client in Store's Program.cs with service discovery

### Updating Data Models
1. Update entity classes in Models folder
2. Update DbContext and add DbSet properties
3. Update `OnModelCreating()` for relationships and seed data
4. Create and apply EF Core migration: `dotnet ef migrations add [Name]`
5. Update API endpoints to use new/modified models
6. Update Blazor components using the data
7. Test with both SQLite (development) and PostgreSQL (production)

### Adding New UI Feature
1. Create Blazor component in `Components/Pages` or `Components/Layout`
2. Add `@page` directive for routing
3. Follow loading/error state patterns (see Common Patterns)
4. Inject required services (`ILogger`, API clients)
5. Add Bootstrap 5 styling with Bootstrap Icons
6. Implement responsive design (mobile-first)
7. Add proper logging for diagnostics
8. Update navigation menu in layout if needed
9. Add `@rendermode InteractiveServer` if component needs interactivity
10. Test error scenarios (API down, network issues)

### Troubleshooting Port Conflicts
- Check for "Urls" in all appsettings.json files - **REMOVE IT**
- Verify AppHost is managing all services in AppHost.cs
- Check for duplicate service registrations in AppHost
- Ensure `.WaitFor()` dependencies are correct
- Restart the AppHost to get fresh port assignments
- Check Aspire dashboard to see assigned ports

### Debugging Aspire Applications
- Use Aspire dashboard to monitor all services
- Check logs in Aspire dashboard for each service
- Verify service discovery is working (endpoints showing in dashboard)
- Check health endpoints: `/health` and `/alive`
- Verify database connections in service logs
- Use distributed tracing to follow requests across services

## Static Files and Assets

### Image Handling
- Place images in `wwwroot/images` folder
- Reference images with `/images/filename.png` (not `~/images/`)
- Always implement error handling for missing images:
  ```csharp
  @onerror="@((args) => HandleImageError(args, product.Id))"
  ```
- Provide fallback UI for missing images (placeholder icon or text)
- Use lazy loading: `loading="lazy"`
- Optimize image sizes for web delivery

### Ensuring Static Files Deploy
Add to `.csproj` file:
```xml
<ItemGroup>
  <Content Include="wwwroot\**" CopyToPublishDirectory="PreserveNewest" />
</ItemGroup>
```

## Azure Deployment with Aspire

### Key Considerations
- Aspire handles containerization automatically via `azd` CLI
- Static files (wwwroot) must be explicitly included in .csproj
- Environment-specific settings use Aspire configuration injection
- **NEVER** use hardcoded connection strings or service URLs
- PostgreSQL databases are provisioned by Aspire in Azure
- Use Azure-provided connection strings via Aspire
- Monitor applications via Aspire dashboard and Azure Portal

### Deployment Process
1. Run `azd init` to initialize Azure Developer CLI
2. Run `azd up` to provision and deploy all services
3. Aspire creates Azure Container Apps for each service
4. Aspire provisions Azure Database for PostgreSQL
5. Service discovery and networking configured automatically
6. Monitor deployment in Aspire dashboard

## Security Best Practices
- Never commit connection strings or secrets to source control
- Use Aspire configuration for environment-specific settings
- Implement proper CORS policies (don't use wildcard in production)
- Validate all user inputs
- Use parameterized queries (EF Core does this automatically)
- Enable HTTPS redirection in production
- Implement proper authentication/authorization (future enhancement)

## Performance Optimization
- Use output caching for Blazor components: `@attribute [OutputCache]`
- Implement pagination for large data sets
- Use `AsNoTracking()` for read-only queries
- Optimize database queries with proper indexes
- Use lazy loading for images
- Minimize JavaScript interop calls
- Use streaming rendering for large pages

## When Making Changes
- Update both API and UI if data contracts change
- Test all affected microservices locally with AppHost
- Verify Aspire orchestration still works
- Check service discovery and inter-service communication
- Ensure database migrations are compatible
- Update API clients if endpoint signatures change
- Test error scenarios (service down, timeout, etc.)
- Update relevant documentation

## References
- [.NET Aspire Documentation](https://learn.microsoft.com/dotnet/aspire/)
- [Blazor Documentation](https://learn.microsoft.com/aspnet/core/blazor/)
- [Minimal APIs](https://learn.microsoft.com/aspnet/core/fundamentals/minimal-apis/)
- [Entity Framework Core](https://learn.microsoft.com/ef/core/)
