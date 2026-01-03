using Autofac;
using Autofac.Extensions.DependencyInjection;
using eShopLite.StoreFx.Data;
using eShopLite.StoreFx.Services;
using Microsoft.EntityFrameworkCore;

var builder = WebApplication.CreateBuilder(new WebApplicationOptions
{
    Args = args,
    ContentRootPath = Directory.GetCurrentDirectory(),
    WebRootPath = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot")
});

// Add services to the container
builder.Services.AddControllersWithViews();

// CRITICAL: Add Entity Framework Core with In-Memory Database
builder.Services.AddDbContext<StoreDbContext>(options =>
{
    options.UseInMemoryDatabase("StoreDb");
    options.EnableSensitiveDataLogging(); // For debugging
});

// Configure Autofac
builder.Host.UseServiceProviderFactory(new AutofacServiceProviderFactory());
builder.Host.ConfigureContainer<ContainerBuilder>(containerBuilder =>
{
    // Register StoreService
    containerBuilder.RegisterType<StoreService>().As<IStoreService>().InstancePerLifetimeScope();
});

var app = builder.Build();

// CRITICAL: Initialize and seed the database
using (var scope = app.Services.CreateScope())
{
    var services = scope.ServiceProvider;
    try
    {
        var context = services.GetRequiredService<StoreDbContext>();
        
        // Ensure database is created
        context.Database.EnsureCreatedAsync().GetAwaiter().GetResult();
        
        // Log to verify data is seeded
        var productCount = context.Products.Count();
        var storeCount = context.Stores.Count();
        
        Console.WriteLine($"Database initialized with {productCount} products and {storeCount} stores");
    }
    catch (Exception ex)
    {
        var logger = services.GetRequiredService<ILogger<Program>>();
        logger.LogError(ex, "An error occurred while seeding the database.");
    }
}

// Configure the HTTP request pipeline
if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Home/Error");
    app.UseHsts();
}

app.UseHttpsRedirection();
app.UseStaticFiles();

app.UseRouting();

app.UseAuthorization();

app.MapControllerRoute(
    name: "default",
    pattern: "{controller=Home}/{action=Index}/{id?}");

app.Run();
