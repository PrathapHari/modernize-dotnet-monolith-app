using eShopLite.Store.Models;

namespace eShopLite.Store.ApiClients;

/// <summary>
/// API client for Store Info service operations
/// </summary>
public class StoreInfoApiClient : ApiClient
{
    private const string StoresEndpoint = "api/stores";

    public StoreInfoApiClient(HttpClient httpClient, ILogger<StoreInfoApiClient> logger)
        : base(httpClient, logger)
    {
    }

    /// <summary>
    /// Retrieve all stores from the StoreInfo API
    /// </summary>
    public async Task<IEnumerable<StoreInfo>> GetStoresAsync(CancellationToken cancellationToken = default)
    {
        try
        {
            _logger.LogInformation("Retrieving all stores from StoreInfo API");
            return await GetCollectionAsync<StoreInfo>(StoresEndpoint, cancellationToken);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving stores from StoreInfo API");
            throw;
        }
    }

    /// <summary>
    /// Retrieve a specific store by ID from the StoreInfo API
    /// </summary>
    public async Task<StoreInfo?> GetStoreByIdAsync(int id, CancellationToken cancellationToken = default)
    {
        try
        {
            _logger.LogInformation("Retrieving store with ID: {StoreId} from StoreInfo API", id);
            return await GetAsync<StoreInfo>($"{StoresEndpoint}/{id}", cancellationToken);
        }
        catch (HttpRequestException ex) when (ex.StatusCode == System.Net.HttpStatusCode.NotFound)
        {
            _logger.LogWarning("Store with ID: {StoreId} not found", id);
            return null;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving store with ID: {StoreId} from StoreInfo API", id);
            throw;
        }
    }
}
