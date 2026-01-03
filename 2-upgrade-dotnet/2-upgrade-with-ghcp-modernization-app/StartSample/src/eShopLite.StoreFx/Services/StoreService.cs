using eShopLite.StoreFx.Data;
using eShopLite.StoreFx.Models;
using Microsoft.EntityFrameworkCore;

namespace eShopLite.StoreFx.Services
{
    public interface IStoreService
    {
        Task<List<Product>> GetProductsAsync();
        Task<List<StoreInfo>> GetStoresAsync();
    }

    public class StoreService : IStoreService
    {
        private readonly StoreDbContext _context;

        public StoreService(StoreDbContext context)
        {
            _context = context;
        }

        public async Task<List<Product>> GetProductsAsync()
        {
            return await _context.Products.ToListAsync();
        }

        public async Task<List<StoreInfo>> GetStoresAsync()
        {
            return await _context.Stores.ToListAsync();
        }
    }
}