using FinTracker.DataAccess;
using FinTracker.Models;
using Microsoft.EntityFrameworkCore;

namespace FinTracker.Repositories
{
    public class StoreRepository : BaseRepository<Store, int>, IStoreRepository
    {
        private readonly IUserContextRepository _userContext;

        public StoreRepository(FinTrackerDbContext context, IUserContextRepository userContext) : base(context)
        {
            _userContext = userContext;
        }

        public override async Task<IEnumerable<Store>> GetAllAsync()
        {
            var userId = _userContext.GetUserId();
            return await _dbSet
                .Where(s => s.IsDefault || (userId != null && s.UserId == userId))
                .OrderBy(s => s.Name)
                .ToListAsync();
        }

        public override async Task<Store?> GetByIdAsync(int id)
        {
            var userId = _userContext.GetUserId();
            return await _dbSet.FirstOrDefaultAsync(s => s.Id == id && (s.IsDefault || (userId != null && s.UserId == userId)));
        }

        public async Task<IEnumerable<string>> GetAllStoresName()
        {
            var userId = _userContext.GetUserId();
            return await _dbSet
               .Where(s => s.IsDefault || (userId != null && s.UserId == userId))
               .Select(s => s.Name)
               .ToListAsync();
        }
    }
}