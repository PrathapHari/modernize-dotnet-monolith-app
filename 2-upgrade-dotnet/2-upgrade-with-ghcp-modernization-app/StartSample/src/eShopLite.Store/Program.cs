using eShopLite.Store.ApiClients;
using Polly;
using Polly.Extensions.Http;

var builder = WebApplication.CreateBuilder(args);

builder.AddRedisOutputCache("redis");

builder.AddServiceDefaults();

// Configure comprehensive logging
builder.Logging.ClearProviders();
builder.Logging.AddConsole();
builder.Logging.AddDebug();
builder.Logging.SetMinimumLevel(LogLevel.Information);

// Add Blazor services
builder.Services.AddRazorComponents()
    .AddInteractiveServerComponents();

// ===== Configure HTTP clients for microservices =====
// Products API Client
builder.Services.AddHttpClient<ProductApiClient>(client =>
{
    client.BaseAddress = new Uri("https+http://eshoplite-products");
    client.Timeout = TimeSpan.FromSeconds(30);
})
.AddPolicyHandler(GetRetryPolicy())
.AddPolicyHandler(GetCircuitBreakerPolicy());

// StoreInfo API Client
builder.Services.AddHttpClient<StoreInfoApiClient>(client =>
{
    client.BaseAddress = new Uri("https+http://eshoplite-storeinfo");
    client.Timeout = TimeSpan.FromSeconds(30);
})
.AddPolicyHandler(GetRetryPolicy())
.AddPolicyHandler(GetCircuitBreakerPolicy());

// Add health checks
builder.Services.AddHealthChecks()
    .AddUrlGroup(new Uri("https+http://eshoplite-products"), 
        name: "products-api", 
        timeout: TimeSpan.FromSeconds(5))
    .AddUrlGroup(new Uri("https+http://eshoplite-storeinfo"), 
        name: "storeinfo-api", 
        timeout: TimeSpan.FromSeconds(5));

// Add response compression
builder.Services.AddResponseCompression(options =>
{
    options.EnableForHttps = true;
});

// Add memory cache
builder.Services.AddMemoryCache();

var app = builder.Build();
app.UseOutputCache();

app.MapDefaultEndpoints();

// Log application startup
var logger = app.Services.GetRequiredService<ILogger<Program>>();
logger.LogInformation("========================================");
logger.LogInformation("eShopLite.Store Application Starting (Microservices)");
logger.LogInformation("========================================");
logger.LogInformation("Environment: {Environment}", app.Environment.EnvironmentName);
logger.LogInformation("Products API: {ProductsApi}", new Uri("https+http://eshoplite-products"));
logger.LogInformation("StoreInfo API: {StoreInfoApi}", new Uri("https+http://eshoplite-storeinfo"));

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
        .OrResult(msg => msg.StatusCode == System.Net.HttpStatusCode.NotFound)
        .WaitAndRetryAsync(3, retryAttempt => TimeSpan.FromSeconds(Math.Pow(2, retryAttempt)),
            onRetry: (outcome, timespan, retryCount, context) =>
            {
                Console.WriteLine($"Retry {retryCount} after {timespan.TotalSeconds}s due to: {outcome.Exception?.Message ?? outcome.Result.StatusCode.ToString()}");
            });
}

static IAsyncPolicy<HttpResponseMessage> GetCircuitBreakerPolicy()
{
    return HttpPolicyExtensions
        .HandleTransientHttpError()
        .CircuitBreakerAsync(5, TimeSpan.FromSeconds(30),
            onBreak: (outcome, timespan) =>
            {
                Console.WriteLine($"Circuit breaker opened for {timespan.TotalSeconds}s due to: {outcome.Exception?.Message ?? outcome.Result.StatusCode.ToString()}");
            },
            onReset: () =>
            {
                Console.WriteLine("Circuit breaker reset");
            });
}
