using FinTracker.DataAccess;
using FinTracker.Models;
using Microsoft.EntityFrameworkCore;

namespace FinTracker.Repositories
{
    public class StoreRepository : BaseRepository<Store, int>, IStoreRepository
    {
        public StoreRepository(FinTrackerDbContext context) : base(context)
        {
        }

        public async Task<IEnumerable<string>> GetAllStoresName()
        {
            return await _dbSet
                .Select(store => store.Name)
                .ToListAsync();
        }
    }
}
