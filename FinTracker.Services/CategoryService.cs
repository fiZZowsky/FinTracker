using AutoMapper;
using FinTracker.Models;
using FinTracker.Repositories;

namespace FinTracker.Services
{
    public class CategoryService : BaseService<Category, CategoryDTO, int>, ICategoryService
    {
        private readonly IUserContextRepository _userContext;

        public CategoryService(ICategoryRepository repository, IMapper mapper, IUserContextRepository userContext)
            : base(repository, mapper)
        {
            _userContext = userContext;
        }

        public override async Task<CategoryDTO> CreateAsync(CategoryDTO dto)
        {
            var userId = _userContext.GetUserId();
            if (userId == null) throw new UnauthorizedAccessException("Brak użytkownika.");

            var entity = _mapper.Map<Category>(dto);

            entity.UserId = userId;
            entity.IsDefault = false;

            var created = await _repository.CreateAsync(entity);
            return _mapper.Map<CategoryDTO>(created);
        }

        public override async Task<bool> DeleteAsync(int id)
        {
            var category = await _repository.GetByIdAsync(id);

            if (category == null || category.IsDefault)
            {
                return false;
            }

            return await _repository.DeleteAsync(id);
        }

        public override async Task<bool> UpdateAsync(int id, CategoryDTO dto)
        {
            var category = await _repository.GetByIdAsync(id);

            if (category == null || category.IsDefault)
            {
                return false;
            }

            _mapper.Map(dto, category);
            category.IsDefault = false;

            await _repository.UpdateAsync(category);
            return true;
        }
    }
}