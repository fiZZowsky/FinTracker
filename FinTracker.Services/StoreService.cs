using AutoMapper;
using FinTracker.Models;
using FinTracker.Repositories;

namespace FinTracker.Services
{
    public class StoreService : BaseService<Store, StoreDTO, int>, IStoreService
    {
        private readonly IUserContextRepository _userContext;

        public StoreService(IStoreRepository repository, IMapper mapper, IUserContextRepository userContext)
            : base(repository, mapper)
        {
            _userContext = userContext;
        }

        public override async Task<StoreDTO> CreateAsync(StoreDTO dto)
        {
            var userId = _userContext.GetUserId();
            if (userId == null) throw new UnauthorizedAccessException();

            var entity = _mapper.Map<Store>(dto);
            entity.UserId = userId;
            entity.IsDefault = false;

            var created = await _repository.CreateAsync(entity);
            return _mapper.Map<StoreDTO>(created);
        }

        public override async Task<bool> UpdateAsync(int id, StoreDTO dto)
        {
            var store = await _repository.GetByIdAsync(id);
            if (store == null || store.IsDefault) return false;

            store.Name = dto.Name;
            await _repository.UpdateAsync(store);
            return true;
        }

        public override async Task<bool> DeleteAsync(int id)
        {
            var store = await _repository.GetByIdAsync(id);
            if (store == null || store.IsDefault) return false;
            return await _repository.DeleteAsync(id);
        }
    }
}