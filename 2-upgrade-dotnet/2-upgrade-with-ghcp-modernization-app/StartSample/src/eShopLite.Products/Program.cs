using Microsoft.EntityFrameworkCore;
using eShopLite.Products.Data;
using eShopLite.Products.Models;

var builder = WebApplication.CreateBuilder(args);

builder.AddServiceDefaults();

// Add services to the container
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddOpenApi();

// Configure PostgreSQL
builder.AddNpgsqlDbContext<ProductDbContext>("productsdb", configureDbContextOptions: options =>
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

// GET /api/products - Get all products
app.MapGet("/api/products", async (ProductDbContext db, ILogger<Program> logger) =>
{
    logger.LogInformation("Retrieving all products");
    return await db.Products.ToListAsync();
})
.WithName("GetProducts")
.WithDescription("Retrieves all products from the database");

// GET /api/products/{id} - Get product by ID
app.MapGet("/api/products/{id:int}", async (int id, ProductDbContext db, ILogger<Program> logger) =>
{
    logger.LogInformation("Retrieving product with ID: {ProductId}", id);
    var product = await db.Products.FindAsync(id);
    
    return product is not null 
        ? Results.Ok(product) 
        : Results.NotFound(new { Message = $"Product with ID {id} not found" });
})
.WithName("GetProductById")
.WithDescription("Retrieves a specific product by ID");

// Initialize database on startup
using (var scope = app.Services.CreateScope())
{
    var db = scope.ServiceProvider.GetRequiredService<ProductDbContext>();
    var startupLogger = scope.ServiceProvider.GetRequiredService<ILogger<Program>>();
    
    try
    {
        startupLogger.LogInformation("========================================");
        startupLogger.LogInformation("Initializing Products database...");
        await db.Database.EnsureCreatedAsync();
        
        var productCount = await db.Products.CountAsync();
        startupLogger.LogInformation("Products database initialized successfully");
        startupLogger.LogInformation("Database contains {Count} products", productCount);
        startupLogger.LogInformation("========================================");
    }
    catch (Exception ex)
    {
        startupLogger.LogError(ex, "Error initializing Products database");
        throw;
    }
}

var appLogger = app.Services.GetRequiredService<ILogger<Program>>();
appLogger.LogInformation("eShopLite.Products API started successfully");
appLogger.LogInformation("Listening on: {Urls}", string.Join(", ", builder.Configuration["Urls"]?.Split(';') ?? new[] { "https://localhost:7001" }));

app.Run();
