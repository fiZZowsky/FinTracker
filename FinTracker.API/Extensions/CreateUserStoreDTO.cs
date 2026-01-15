using System.ComponentModel.DataAnnotations;

namespace FinTracker.API.Extensions
{
    public class CreateUserStoreDTO
    {
        [Required]
        public string Name { get; set; } = string.Empty;
    }
}