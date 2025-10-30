using AutoMapper;
using FinTracker.Repositories;
using FinTracker.Services.Base;

namespace FinTracker.Services
{
    public class BaseService<TEntity, TDto, TId> : IBaseService<TDto, TId>
        where TEntity : class
    {
        protected readonly IBaseRepository<TEntity, TId> _repository;
        protected readonly IMapper _mapper;

        public BaseService(IBaseRepository<TEntity, TId> repository, IMapper mapper)
        {
            _repository = repository;
            _mapper = mapper;
        }
        
        public virtual async Task<TDto> CreateAsync(TDto dto)
        {
            if (dto == null)
            {
                throw new ArgumentNullException(nameof(dto));
            }

            var entity = _mapper.Map<TEntity>(dto);
            var createdEntity = await _repository.CreateAsync(entity);
            return _mapper.Map<TDto>(createdEntity);
        }

        public virtual async Task<bool> DeleteAsync(TId id)
        {
            return await _repository.DeleteAsync(id);
        }

        public virtual async Task<IEnumerable<TDto>> GetAllAsync()
        {
            var entities = await _repository.GetAllAsync();
            return _mapper.Map<IEnumerable<TDto>>(entities);
        }

        public virtual async Task<TDto?> GetByIdAsync(TId id)
        {
            var entity = await _repository.GetByIdAsync(id);
            return entity == null ? default(TDto) : _mapper.Map<TDto>(entity);
        }

        public virtual async Task<bool> UpdateAsync(TId id, TDto dto)
        {
            var entity = await _repository.GetByIdAsync(id);

            if (entity == null)
            {
                return false;
            }
            
            _mapper.Map(dto, entity);

            await _repository.UpdateAsync(entity);
            return true;
        }
    }
}