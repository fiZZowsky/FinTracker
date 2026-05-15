namespace FinTracker.Models
{
    public class SummaryDataDTO
    {
        public string Label { get; set; } = string.Empty;
        public decimal Total { get; set; }
        public DateTime ShoppingDate { get; set; }
    }
}