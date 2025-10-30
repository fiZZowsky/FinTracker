namespace FinTracker.Services.Base
{
    public interface IBaseService<TDto, TId>
    {
        Task<TDto?> GetByIdAsync(TId id);
        Task<IEnumerable<TDto>> GetAllAsync();
        Task<TDto> CreateAsync(TDto dto);
        Task<bool> UpdateAsync(TId id, TDto dto);
        Task<bool> DeleteAsync(TId id);
    }
}