using FinTracker.Models;

namespace FinTracker.Services
{
    public interface IAuthService
    {
        Task<AuthResponseDto> RegisterAsync(RegisterDto dto);
        Task<AuthResponseDto> LoginAsync(LoginDto dto);
        Task<AuthResponseDto> RefreshTokenAsync(TokenRequestDTO dto);
        Task ChangePasswordAsync(Guid userId, ChangePasswordDTO dto);
        Task DeleteAccountAsync(Guid userId);
    }
}
