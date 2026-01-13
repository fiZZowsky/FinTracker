namespace FinTracker.Models
{
    public class AuthResponseDto
    {
        public string Token { get; set; }
        public Guid UserId { get; set; }
        public string Name { get; set; }
    }
}
