using System.ComponentModel.DataAnnotations;

namespace FinTracker.Models
{
    public class RegisterDto
    {
        [Required] public string Name { get; set; }
        [Required, EmailAddress] public string Email { get; set; }
        [Required, MinLength(6)] public string Password { get; set; }
        [Compare("Password")] public string ConfirmPassword { get; set; }
    }
}
