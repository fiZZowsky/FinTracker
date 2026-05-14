using System.ComponentModel.DataAnnotations;

namespace FinTracker.Models
{
    public class ReceiptDTO
    {
        public int Id { get; set; }
        public string StoreName { get; set; }
        public byte[]? StoreLogo { get; set; }
        [Range(0.01, double.MaxValue, ErrorMessage = "Kwota musi być większa od zera.")]
        public decimal TotalAmount { get; set; }
        public string CurrencyCode { get; set; } = "PLN";
        public DateTime DateShopping { get; set; }
        public int? CategoryId { get; set; }
        public string? CategoryName { get; set; }
    }
}
