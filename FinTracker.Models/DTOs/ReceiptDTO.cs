namespace FinTracker.Models
{
    public class ReceiptDTO
    {
        public int Id { get; set; }
        public string StoreName { get; set; }
        public byte[]? StoreLogo { get; set; }
        public decimal TotalAmount { get; set; }
        public DateTime DateShopping { get; set; }
    }
}
