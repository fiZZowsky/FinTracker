using FinTracker.Models;

namespace FinTracker.Repositories
{
    public interface IExchangeRateRepository : IBaseRepository<ExchangeRateCache, int>
    {
        Task<decimal?> GetRateAsync(string currencyCode, DateTime date);
    }
}
