using FinTracker.Models;
using FinTracker.Repositories;
using FinTracker.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace FinTracker.API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class AuthController : ControllerBase
    {
        private readonly IAuthService _authService;
        private readonly IUserContextRepository _userContext;

        public AuthController(IAuthService authService, IUserContextRepository userContext)
        {
            _authService = authService;
            _userContext = userContext;
        }

        [HttpPost("register")]
        public async Task<IActionResult> Register(RegisterDto dto)
        {
            var result = await _authService.RegisterAsync(dto);
            return Ok(result);
        }

        [HttpPost("login")]
        public async Task<IActionResult> Login(LoginDto dto)
        {
            var result = await _authService.LoginAsync(dto);
            return Ok(result);
        }

        [HttpPost("refresh-token")]
        public async Task<IActionResult> RefreshToken([FromBody] TokenRequestDTO dto)
        {
            var result = await _authService.RefreshTokenAsync(dto);
            return Ok(result);
        }

        [Authorize]
        [HttpPost("change-password")]
        public async Task<IActionResult> ChangePassword([FromBody] ChangePasswordDTO dto)
        {
            var userId = _userContext.GetUserId();
            if (userId == null) return Unauthorized();

            await _authService.ChangePasswordAsync(userId.Value, dto);
            return NoContent();
        }

        [Authorize]
        [HttpDelete("delete-account")]
        public async Task<IActionResult> DeleteAccount()
        {
            var userId = _userContext.GetUserId();
            if (userId == null) return Unauthorized();

            await _authService.DeleteAccountAsync(userId.Value);
            return NoContent();
        }
    }
}