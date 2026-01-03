using eShopLite.StoreFx.Data;
using eShopLite.StoreFx.Services;
using Microsoft.EntityFrameworkCore;

var builder = WebApplication.CreateBuilder(args);

// Configure comprehensive logging with diagnostic level
builder.Logging.ClearProviders();
builder.Logging.AddConsole();
builder.Logging.AddDebug();
builder.Logging.AddEventSourceLogger();

// Set minimum log level to Trace for diagnostic purposes
builder.Logging.SetMinimumLevel(LogLevel.Trace);

// Configure logging from appsettings
builder.Logging.AddConfiguration(builder.Configuration.GetSection("Logging"));

// Add Blazor services
builder.Services.AddRazorComponents()
    .AddInteractiveServerComponents();

// Configure SQLite database with connection string from configuration
var connectionString = builder.Configuration.GetConnectionString("DefaultConnection") 
    ?? "Data Source=eShopLite.db;Cache=Shared";

builder.Services.AddDbContext<StoreDbContext>(options =>
{
    options.UseSqlite(connectionString);
    
    // Enable diagnostic features in development
    if (builder.Environment.IsDevelopment())
    {
        options.EnableSensitiveDataLogging();
        options.EnableDetailedErrors();
        options.LogTo(Console.WriteLine, LogLevel.Information);
    }
    
    // Configure query tracking behavior
    options.UseQueryTrackingBehavior(QueryTrackingBehavior.NoTracking);
    
    // Enable diagnostic warnings
    options.ConfigureWarnings(warnings =>
    {
        warnings.Log(
            Microsoft.EntityFrameworkCore.Diagnostics.CoreEventId.FirstWithoutOrderByAndFilterWarning,
            Microsoft.EntityFrameworkCore.Diagnostics.CoreEventId.RowLimitingOperationWithoutOrderByWarning
        );
    });
});

// Register the interface to resolve from the concrete DbContext
builder.Services.AddScoped<IStoreDbContext>(provider => 
    provider.GetRequiredService<StoreDbContext>());

// Register application services with proper lifetime
builder.Services.AddScoped<IProductService, ProductService>();
builder.Services.AddScoped<IStoreService, StoreService>();

// Add health checks
builder.Services.AddHealthChecks()
    .AddDbContextCheck<StoreDbContext>("database");

// Configure response compression
builder.Services.AddResponseCompression(options =>
{
    options.EnableForHttps = true;
});

// Add memory cache
builder.Services.AddMemoryCache();

// Add response caching
builder.Services.AddResponseCaching();

var app = builder.Build();

// Log application startup
var logger = app.Services.GetRequiredService<ILogger<Program>>();
logger.LogInformation("========================================");
logger.LogInformation("eShopLite.StoreFx Application Starting (Blazor)");
logger.LogInformation("========================================");
logger.LogInformation("Environment: {Environment}", app.Environment.EnvironmentName);
logger.LogInformation("Content Root: {ContentRoot}", app.Environment.ContentRootPath);
logger.LogInformation("Web Root: {WebRoot}", app.Environment.WebRootPath);

// Initialize and seed the database
using (var scope = app.Services.CreateScope())
{
    var services = scope.ServiceProvider;
    var scopedLogger = services.GetRequiredService<ILogger<Program>>();
    
    try
    {
        scopedLogger.LogInformation("Initializing database...");
        var context = services.GetRequiredService<StoreDbContext>();
        
        // Ensure database is created and apply migrations
        await context.Database.EnsureCreatedAsync();
        scopedLogger.LogInformation("Database created successfully");
        
        // Log database statistics
        var productCount = await context.Products.CountAsync();
        var storeCount = await context.Stores.CountAsync();
        
        scopedLogger.LogInformation("Database initialized successfully");
        scopedLogger.LogInformation("Database contains {ProductCount} products and {StoreCount} stores", 
            productCount, storeCount);
        
        scopedLogger.LogDebug("Database connection string: {ConnectionString}", connectionString);
    }
    catch (Exception ex)
    {
        scopedLogger.LogError(ex, "An error occurred while initializing the database");
        scopedLogger.LogCritical("Application startup failed due to database initialization error");
        throw;
    }
}

// Configure the HTTP request pipeline
if (app.Environment.IsDevelopment())
{
    app.UseDeveloperExceptionPage();
    logger.LogInformation("Developer exception page enabled");
}
else
{
    app.UseExceptionHandler("/Error");
    app.UseHsts();
    logger.LogInformation("Production error handling enabled");
}

app.UseHttpsRedirection();

// Configure static files with proper options
var staticFileOptions = new StaticFileOptions
{
    OnPrepareResponse = ctx =>
    {
        // Add cache headers for better performance
        const int durationInSeconds = 60 * 60 * 24 * 30; // 30 days
        ctx.Context.Response.Headers.Append("Cache-Control", $"public,max-age={durationInSeconds}");
        
        // Log static file requests in development
        if (app.Environment.IsDevelopment())
        {
            logger.LogDebug("Serving static file: {Path}", ctx.Context.Request.Path);
        }
    }
};

app.UseStaticFiles(staticFileOptions);
logger.LogInformation("Static files middleware configured with caching");

// Enable response compression
app.UseResponseCompression();
logger.LogDebug("Response compression enabled");

// Enable response caching
app.UseResponseCaching();
logger.LogDebug("Response caching enabled");

app.UseAntiforgery();

// Map health check endpoint
app.MapHealthChecks("/health");
logger.LogInformation("Health check endpoint mapped at /health");

// Map diagnostic endpoint for static files in development
if (app.Environment.IsDevelopment())
{
    app.MapGet("/api/diagnostics/static-files", () =>
    {
        var wwwrootPath = app.Environment.WebRootPath;
        var files = new List<string>();
        
        if (Directory.Exists(wwwrootPath))
        {
            files = Directory.GetFiles(wwwrootPath, "*.*", SearchOption.AllDirectories)
                .Select(f => f.Replace(wwwrootPath, "").Replace("\\", "/"))
                .ToList();
        }
        
        return Results.Ok(new
        {
            wwwrootPath,
            fileCount = files.Count,
            files = files.Take(50) // Limit to first 50 files
        });
    });
    
    logger.LogInformation("Diagnostic endpoint mapped at /api/diagnostics/static-files");
}

// Map Blazor components
app.MapRazorComponents<eShopLite.StoreFx.Components.App>()
    .AddInteractiveServerRenderMode();
logger.LogInformation("Blazor components mapped");

// Log final startup message
logger.LogInformation("========================================");
logger.LogInformation("eShopLite.StoreFx Started Successfully");
logger.LogInformation("Database: SQLite at {ConnectionString}", connectionString);
logger.LogInformation("Listening on: {Urls}", string.Join(", ", builder.Configuration["urls"] ?? "default"));
logger.LogInformation("========================================");

app.Run();
