using Microsoft.EntityFrameworkCore;
using eShopLite.StoreInfo.Data;
using eShopLite.StoreInfo.Models;

var builder = WebApplication.CreateBuilder(args);

builder.AddServiceDefaults();

// Add services to the container
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddOpenApi();


// Configure PostgreSQL
builder.AddNpgsqlDbContext<StoreInfoDbContext>("storeinfodb", configureDbContextOptions: options =>
{
    // Enable sensitive data logging in development
    if (builder.Environment.IsDevelopment())
    {
        options.EnableSensitiveDataLogging();
        options.EnableDetailedErrors();
    }
});

// Add CORS for Blazor UI app
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowBlazorApp", policy =>
    {
        policy.WithOrigins("https://localhost:5001", "http://localhost:5000", "http://localhost:63769", "https://localhost:63769")
              .AllowAnyHeader()
              .AllowAnyMethod();
    });
});

var app = builder.Build();

app.MapDefaultEndpoints();

// Configure the HTTP request pipeline
if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
}

app.UseHttpsRedirection();
app.UseCors("AllowBlazorApp");

// ===== Minimal API Endpoints =====

// GET /api/stores - Get all stores
app.MapGet("/api/stores", async (StoreInfoDbContext db, ILogger<Program> logger) =>
{
    logger.LogInformation("Retrieving all stores");
    return await db.Stores.ToListAsync();
})
.WithName("GetStores")
.WithDescription("Retrieves all stores from the database");

// GET /api/stores/{id} - Get store by ID
app.MapGet("/api/stores/{id:int}", async (int id, StoreInfoDbContext db, ILogger<Program> logger) =>
{
    logger.LogInformation("Retrieving store with ID: {StoreId}", id);
    var store = await db.Stores.FindAsync(id);
    
    return store is not null 
        ? Results.Ok(store) 
        : Results.NotFound(new { Message = $"Store with ID {id} not found" });
})
.WithName("GetStoreById")
.WithDescription("Retrieves a specific store by ID");

// Initialize database on startup
using (var scope = app.Services.CreateScope())
{
    var db = scope.ServiceProvider.GetRequiredService<StoreInfoDbContext>();
    var startupLogger = scope.ServiceProvider.GetRequiredService<ILogger<Program>>();
    
    try
    {
        startupLogger.LogInformation("========================================");
        startupLogger.LogInformation("Initializing StoreInfo database...");
        await db.Database.EnsureCreatedAsync();
        
        var storeCount = await db.Stores.CountAsync();
        startupLogger.LogInformation("StoreInfo database initialized successfully");
        startupLogger.LogInformation("Database contains {Count} stores", storeCount);
        startupLogger.LogInformation("========================================");
    }
    catch (Exception ex)
    {
        startupLogger.LogError(ex, "Error initializing StoreInfo database");
        throw;
    }
}

var appLogger = app.Services.GetRequiredService<ILogger<Program>>();
appLogger.LogInformation("eShopLite.StoreInfo API started successfully");
appLogger.LogInformation("Listening on: {Urls}", string.Join(", ", builder.Configuration["Urls"]?.Split(';') ?? new[] { "https://localhost:7002" }));

app.Run();
