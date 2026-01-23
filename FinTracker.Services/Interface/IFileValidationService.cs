using Microsoft.AspNetCore.Http;

namespace FinTracker.Services
{
    public interface IFileValidationService
    {
        (bool IsValid, string ErrorMessage) ValidateImage(IFormFile file);
    }
}
