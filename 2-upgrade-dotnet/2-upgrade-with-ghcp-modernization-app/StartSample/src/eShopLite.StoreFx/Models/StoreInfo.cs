using Newtonsoft.Json;

namespace eShopLite.StoreFx.Models
{
    public class StoreInfo
    {
        [JsonProperty("id")]
        public int Id { get; set; }
        [JsonProperty("name")]
        public string Name { get; set; } = string.Empty;
        [JsonProperty("city")]
        public string City { get; set; } = string.Empty;
        [JsonProperty("state")]
        public string State { get; set; } = string.Empty;
        [JsonProperty("hours")]
        public string Hours { get; set; } = string.Empty;
    }
}
