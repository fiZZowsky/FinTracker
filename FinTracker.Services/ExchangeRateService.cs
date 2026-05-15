using FinTracker.Models;
using FinTracker.Repositories;
using System.Text.Json;

namespace FinTracker.Services
{
    public class ExchangeRateService : IExchangeRateService
    {
        private readonly HttpClient _httpClient;
        private readonly IExchangeRateRepository _exchangeRateRepository;

        public ExchangeRateService(HttpClient httpClient, IExchangeRateRepository exchangeRateRepository)
        {
            _httpClient = httpClient;
            _exchangeRateRepository = exchangeRateRepository;
        }

        public async Task<decimal> GetRateAsync(string currencyCode, DateTime? date = null)
        {
            var code = currencyCode.ToUpper();
            if (code == "PLN") return 1.0m;

            DateTime targetDate = (date ?? DateTime.Now).Date;

            var cachedRate = await _exchangeRateRepository.GetRateAsync(currencyCode, targetDate);

            if (cachedRate != null)
                return cachedRate.Value;

            decimal fetchedRate = 1.0m;
            string dateStr = targetDate.AddDays(-i).ToString("yyyy-MM-dd");
            var response = await _httpClient.GetAsync($"http://api.nbp.pl/api/exchangerates/rates/A/{code}/{dateStr}/?format=json");

            if (response.IsSuccessStatusCode)
            {
                var content = await response.Content.ReadAsStringAsync();
                using var doc = JsonDocument.Parse(content);
                fetchedRate = doc.RootElement.GetProperty("rates")[0].GetProperty("mid").GetDecimal();

                await _exchangeRateRepository.CreateAsync(new ExchangeRateCache
                {
                    CurrencyCode = code,
                    Date = targetDate,
                    Rate = fetchedRate
                });
            }

            return fetchedRate;
        }
    }
}