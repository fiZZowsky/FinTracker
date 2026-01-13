using Microsoft.AspNetCore.Http;
using System.Security.Claims;

namespace FinTracker.Repositories
{
    public class UserContextRepository : IUserContextRepository
    {
        private readonly IHttpContextAccessor _httpContextAccessor;

        public UserContextRepository(IHttpContextAccessor httpContextAccessor)
        {
            _httpContextAccessor = httpContextAccessor;
        }

        public Guid? GetUserId()
        {
            var user = _httpContextAccessor.HttpContext?.User;
            if (user == null) return null;

            var idClaim = user.FindFirst(ClaimTypes.NameIdentifier);
            if (idClaim != null && Guid.TryParse(idClaim.Value, out var userId))
            {
                return userId;
            }
            return null;
        }
    }
}