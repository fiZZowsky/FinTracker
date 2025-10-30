namespace FinTracker.Repositories
{
    public interface IBaseRepository<TEntity, TId> where TEntity : class
    {
        Task<TEntity?> GetByIdAsync(TId id);
        Task<IEnumerable<TEntity>> GetAllAsync();
        Task<TEntity> CreateAsync(TEntity entity);
        Task UpdateAsync(TEntity entity);
        Task<bool> DeleteAsync(TId id);
    }
}
