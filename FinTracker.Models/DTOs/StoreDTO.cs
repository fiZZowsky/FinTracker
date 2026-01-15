namespace FinTracker.Models
{
    public class StoreDTO
    {
        public int Id { get; set; }
        public string Name { get; set; } = string.Empty;
        public byte[]? Logo { get; set; }
        public bool IsDefault { get; set; }
    }
}
