using AutoMapper;
using FinTracker.Models;
using FinTracker.Repositories;

namespace FinTracker.Services
{
    public class CategoryService : BaseService<Category, CategoryDTO, int>, ICategoryService
    {
        public CategoryService(ICategoryRepository repository, IMapper mapper)
            : base(repository, mapper)
        {
        }
    }
}