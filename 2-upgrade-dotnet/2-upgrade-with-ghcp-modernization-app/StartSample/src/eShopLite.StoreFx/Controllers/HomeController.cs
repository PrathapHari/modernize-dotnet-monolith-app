using eShopLite.StoreFx.Services;
using Microsoft.AspNetCore.Mvc;

namespace eShopLite.StoreFx.Controllers
{
    public class HomeController : Controller
    {
        private readonly IStoreService _storeService;

        public HomeController(IStoreService storeService)
        {
            _storeService = storeService;
        }

        public IActionResult Index()
        {
            return View();
        }

        public async Task<IActionResult> Products()
        {
            var products = await _storeService.GetProductsAsync();
            return View(products);
        }

        public async Task<IActionResult> Stores()
        {
            var stores = await _storeService.GetStoresAsync();
            return View(stores);
        }

        public IActionResult Error()
        {
            return View();
        }
    }
}