namespace FinTracker.Models
{
    public class Store
    {
        public int Id { get; set; }
        public string Name { get; set; } = string.Empty;
        public string? LogoUrl { get; set; }
        public bool IsDefault { get; set; } = false;
        public Guid? UserId { get; set; }
    }
}
