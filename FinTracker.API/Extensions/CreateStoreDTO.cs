using System.ComponentModel.DataAnnotations;

namespace FinTracker.API.Extensions
{
    public class CreateStoreDTO
    {
        [Required]
        public string Name { get; set; }
        [Required]
        public IFormFile Logo { get; set; }
    }
}
