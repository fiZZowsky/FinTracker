using FinTracker.Models;

namespace FinTracker.Repositories
{
    public interface IStoreRepository : IBaseRepository<Store, int>
    {
        public Task<IEnumerable<string>> GetAllStoresName();
    }
}
