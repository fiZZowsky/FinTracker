namespace FinTracker.Services
{
    public interface IExchangeRateService
    {
        Task<decimal> GetRateAsync(string currencyCode);
    }
}