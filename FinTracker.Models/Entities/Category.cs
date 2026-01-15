namespace FinTracker.Models
{
    public class Category
    {
        public int Id { get; set; }
        public string Name { get; set; } = string.Empty;
        public bool IsDefault { get; set; } = false;
        public Guid? UserId { get; set; }
    }
}
