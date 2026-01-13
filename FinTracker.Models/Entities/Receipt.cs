namespace FinTracker.Models
{
    public class Receipt
    {
        public int Id { get; set; }
        public string StoreName { get; set; }
        public decimal TotalAmount { get; set; }
        public DateTime DateShopping { get; set; }
        public int? CategoryId { get; set; }
        public Guid UserId { get; set; }

        public Category? Category { get; set; }
        public User? User { get; set; }
    }
}
