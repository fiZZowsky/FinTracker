namespace FinTracker.Models
{
    public class ExchangeRateCache
    {
        public int Id { get; set; }
        public string CurrencyCode { get; set; } = string.Empty;
        public DateTime Date { get; set; }
        public decimal Rate { get; set; }
    }
}
