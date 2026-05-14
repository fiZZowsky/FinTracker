using System.Text.Json;

namespace FinTracker.Services
{
    public class ExchangeRateService : IExchangeRateService
    {
        private readonly HttpClient _httpClient;

        public ExchangeRateService(HttpClient httpClient)
        {
            _httpClient = httpClient;
        }

        public async Task<decimal> GetRateAsync(string currencyCode)
        {
            var code = currencyCode.ToUpper();
            if (code == "PLN") return 1.0m;

            try
            {
                var response = await _httpClient.GetAsync($"http://api.nbp.pl/api/exchangerates/rates/A/{code}/?format=json");

                if (response.IsSuccessStatusCode)
                {
                    var content = await response.Content.ReadAsStringAsync();
                    using var doc = JsonDocument.Parse(content);
                    var rate = doc.RootElement.GetProperty("rates")[0].GetProperty("mid").GetDecimal();
                    return rate;
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Błąd pobierania kursu walut: {ex.Message}");
            }

            return 1.0m;
        }
    }
}