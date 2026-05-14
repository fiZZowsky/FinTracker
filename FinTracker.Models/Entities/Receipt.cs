namespace FinTracker.Models
{
    public class Receipt
    {
        public int Id { get; set; }
        public string StoreName { get; set; }
        public decimal TotalAmount { get; set; }
        public string CurrencyCode { get; set; } = "PLN";
        public decimal ExchangeRate { get; set; } = 1.0m;

        public decimal TotalAmountInPln => TotalAmount * ExchangeRate;
        public DateTime DateShopping { get; set; }
        public int? CategoryId { get; set; }
        public Guid UserId { get; set; }

        public Category? Category { get; set; }
        public User? User { get; set; }
    }
}
