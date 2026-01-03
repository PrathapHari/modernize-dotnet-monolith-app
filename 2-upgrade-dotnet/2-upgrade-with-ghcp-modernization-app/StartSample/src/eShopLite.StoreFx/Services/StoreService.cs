using Microsoft.EntityFrameworkCore;
using eShopLite.StoreFx.Data;
using eShopLite.StoreFx.Models;
using Microsoft.Extensions.Logging;

namespace eShopLite.StoreFx.Services
{
    /// <summary>
    /// Service interface for store operations
    /// </summary>
    public interface IStoreService
    {
        Task<IEnumerable<StoreInfo>> GetStoresAsync();
        Task<StoreInfo?> GetStoreByIdAsync(int id);
    }

    /// <summary>
    /// Service implementation for store operations
    /// </summary>
    public class StoreService : IStoreService
    {
        private readonly IStoreDbContext _context;
        private readonly ILogger<StoreService> _logger;

        public StoreService(IStoreDbContext context, ILogger<StoreService> logger)
        {
            _context = context ?? throw new ArgumentNullException(nameof(context));
            _logger = logger ?? throw new ArgumentNullException(nameof(logger));
        }

        public async Task<IEnumerable<StoreInfo>> GetStoresAsync()
        {
            try
            {
                _logger.LogInformation("Retrieving all stores");
                return await _context.Stores.ToListAsync();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving stores");
                throw;
            }
        }

        public async Task<StoreInfo?> GetStoreByIdAsync(int id)
        {
            try
            {
                _logger.LogInformation("Retrieving store with ID: {StoreId}", id);
                var store = await _context.Stores
                    .FirstOrDefaultAsync(s => s.Id == id);
                return store;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving store with ID: {StoreId}", id);
                throw;
            }
        }
    }
}
