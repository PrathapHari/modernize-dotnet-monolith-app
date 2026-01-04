using System.Net.Http.Json;
using System.Text.Json;

namespace eShopLite.Store.ApiClients;

/// <summary>
/// Base class for all API clients providing common HTTP functionality
/// </summary>
public abstract class ApiClient
{
    protected readonly HttpClient _httpClient;
    protected readonly ILogger _logger;
    protected readonly JsonSerializerOptions _jsonOptions;

    protected ApiClient(HttpClient httpClient, ILogger logger)
    {
        _httpClient = httpClient ?? throw new ArgumentNullException(nameof(httpClient));
        _logger = logger ?? throw new ArgumentNullException(nameof(logger));
        
        _jsonOptions = new JsonSerializerOptions
        {
            PropertyNameCaseInsensitive = true
        };
    }

    /// <summary>
    /// Execute GET request and deserialize response
    /// </summary>
    protected async Task<T?> GetAsync<T>(string requestUri, CancellationToken cancellationToken = default)
    {
        try
        {
            _logger.LogInformation("GET request to: {RequestUri}", requestUri);
            
            var response = await _httpClient.GetAsync(requestUri, cancellationToken);
            response.EnsureSuccessStatusCode();
            
            var result = await response.Content.ReadFromJsonAsync<T>(_jsonOptions, cancellationToken);
            _logger.LogInformation("Successfully retrieved data from: {RequestUri}", requestUri);
            
            return result;
        }
        catch (HttpRequestException ex)
        {
            _logger.LogError(ex, "HTTP request failed for: {RequestUri}", requestUri);
            throw;
        }
        catch (JsonException ex)
        {
            _logger.LogError(ex, "JSON deserialization failed for: {RequestUri}", requestUri);
            throw;
        }
    }

    /// <summary>
    /// Execute GET request for collection
    /// </summary>
    protected async Task<IEnumerable<T>> GetCollectionAsync<T>(string requestUri, CancellationToken cancellationToken = default)
    {
        var result = await GetAsync<List<T>>(requestUri, cancellationToken);
        return result ?? Enumerable.Empty<T>();
    }
}
