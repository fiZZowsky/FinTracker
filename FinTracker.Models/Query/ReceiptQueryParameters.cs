namespace FinTracker.Models
{
    public class ReceiptQueryParameters : BaseQuery
    {
        public DateTime? StartDate { get; set; }
        public DateTime? EndDate { get; set; }
        public string? FilterType { get; set; }
    }
}
