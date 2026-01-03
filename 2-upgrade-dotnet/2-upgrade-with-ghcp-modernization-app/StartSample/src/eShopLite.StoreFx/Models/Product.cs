using Newtonsoft.Json;

namespace eShopLite.StoreFx.Models
{
    public class Product
    {
        [JsonProperty("id")]
        public int Id { get; set; }

        [JsonProperty("name")]
        public string Name { get; set; } = string.Empty;

        [JsonProperty("description")]
        public string Description { get; set; } = string.Empty;

        [JsonProperty("price")]
        public decimal Price { get; set; }

        [JsonProperty("imageUrl")]
        public string ImageUrl { get; set; } = string.Empty;
    }
}
