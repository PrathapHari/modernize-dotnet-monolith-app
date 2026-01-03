using eShopLite.StoreFx.Data;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace eShopLite.StoreFx.Controllers
{
    public class DiagnosticsController : Controller
    {
        private readonly StoreDbContext _context;

        public DiagnosticsController(StoreDbContext context)
        {
            _context = context;
        }

        // Navigate to: /Diagnostics/DatabaseStatus
        public async Task<IActionResult> DatabaseStatus()
        {
            var productCount = await _context.Products.CountAsync();
            var storeCount = await _context.Stores.CountAsync();
            
            var products = await _context.Products.ToListAsync();
            var stores = await _context.Stores.ToListAsync();

            ViewBag.ProductCount = productCount;
            ViewBag.StoreCount = storeCount;
            ViewBag.Products = products;
            ViewBag.Stores = stores;

            return View();
        }

        // API endpoint for JSON response: /Diagnostics/ApiStatus
        [HttpGet]
        public async Task<IActionResult> ApiStatus()
        {
            var productCount = await _context.Products.CountAsync();
            var storeCount = await _context.Stores.CountAsync();
            
            var products = await _context.Products.ToListAsync();
            
            return Json(new
            {
                success = true,
                productCount,
                storeCount,
                products = products.Select(p => new
                {
                    p.Id,
                    p.Name,
                    p.Price,
                    p.Description,
                    p.ImageUrl
                }),
                timestamp = DateTime.Now
            });
        }
    }
}