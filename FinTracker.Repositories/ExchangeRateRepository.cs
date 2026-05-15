using FinTracker.DataAccess;
using FinTracker.Models;
using Microsoft.EntityFrameworkCore;

namespace FinTracker.Repositories
{
    public class ExchangeRateRepository : BaseRepository<ExchangeRateCache, int>, IExchangeRateRepository
    {
        public ExchangeRateRepository(FinTrackerDbContext context) : base(context)
        {
        }

        public async Task<decimal?> GetRateAsync(string currencyCode, DateTime date)
        {
            var exchangeRate = await _dbSet
                            .AsNoTracking()
                            .FirstOrDefaultAsync(e => e.CurrencyCode == currencyCode && e.Date == date);

            return exchangeRate?.Rate;
        }
    }
}
