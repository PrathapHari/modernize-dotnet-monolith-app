using eShopLite.Store.Models;

namespace eShopLite.Store.ApiClients;

/// <summary>
/// API client for Product service operations
/// </summary>
public class ProductApiClient : ApiClient
{
    private const string ProductsEndpoint = "api/products";

    public ProductApiClient(HttpClient httpClient, ILogger<ProductApiClient> logger)
        : base(httpClient, logger)
    {
    }

    /// <summary>
    /// Retrieve all products from the Products API
    /// </summary>
    public async Task<IEnumerable<Product>> GetProductsAsync(CancellationToken cancellationToken = default)
    {
        try
        {
            _logger.LogInformation("Retrieving all products from Products API");
            return await GetCollectionAsync<Product>(ProductsEndpoint, cancellationToken);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving products from Products API");
            throw;
        }
    }

    /// <summary>
    /// Retrieve a specific product by ID from the Products API
    /// </summary>
    public async Task<Product?> GetProductByIdAsync(int id, CancellationToken cancellationToken = default)
    {
        try
        {
            _logger.LogInformation("Retrieving product with ID: {ProductId} from Products API", id);
            return await GetAsync<Product>($"{ProductsEndpoint}/{id}", cancellationToken);
        }
        catch (HttpRequestException ex) when (ex.StatusCode == System.Net.HttpStatusCode.NotFound)
        {
            _logger.LogWarning("Product with ID: {ProductId} not found", id);
            return null;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving product with ID: {ProductId} from Products API", id);
            throw;
        }
    }
}
