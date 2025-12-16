using FinTracker.DataAccess;
using FinTracker.Models;

namespace FinTracker.Repositories
{
    public class CategoryRepository : BaseRepository<Category, int>, ICategoryRepository
    {
        public CategoryRepository(FinTrackerDbContext context) : base(context)
        {
        }
    }
}