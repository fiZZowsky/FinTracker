using AutoMapper;
using FinTracker.Models;
using FinTracker.Repositories;

namespace FinTracker.Services
{
    public class StoreService : BaseService<Store, StoreDTO, int>, IStoreService
    {
        public StoreService(IStoreRepository repository, IMapper mapper)
            : base(repository, mapper)
        {
        }
    }
}
