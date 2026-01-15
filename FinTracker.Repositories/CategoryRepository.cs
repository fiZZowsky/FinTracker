using FinTracker.DataAccess;
using FinTracker.Models;
using Microsoft.EntityFrameworkCore;

namespace FinTracker.Repositories
{
    public class CategoryRepository : BaseRepository<Category, int>, ICategoryRepository
    {
        private readonly IUserContextRepository _userContext;

        public CategoryRepository(FinTrackerDbContext context, IUserContextRepository userContext) : base(context)
        {
            _userContext = userContext;
        }

        public override async Task<IEnumerable<Category>> GetAllAsync()
        {
            var userId = _userContext.GetUserId();

            return await _dbSet
                .Where(c => c.IsDefault || (userId != null && c.UserId == userId))
                .OrderBy(c => c.Name)
                .ToListAsync();
        }

        public override async Task<Category?> GetByIdAsync(int id)
        {
            var userId = _userContext.GetUserId();
            return await _dbSet.FirstOrDefaultAsync(c =>
                c.Id == id &&
                (c.IsDefault || (userId != null && c.UserId == userId)));
        }
    }
}