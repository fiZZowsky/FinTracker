using FinTracker.DataAccess;
using FinTracker.Models;
using Microsoft.EntityFrameworkCore;

namespace FinTracker.Repositories
{
    public class ReceiptRepository : BaseRepository<Receipt, int>, IReceiptRepository
    {
        private readonly IUserContextRepository _userContext;

        public ReceiptRepository(FinTrackerDbContext context, IUserContextRepository userContext) : base(context)
        {
            _userContext = userContext;
        }

        private IQueryable<Receipt> GetUserReceipts()
        {
            var userId = _userContext.GetUserId();
            if (userId == null) return _dbSet.Where(r => false);
            return _dbSet.Where(r => r.UserId == userId);
        }

        public override async Task<IEnumerable<Receipt>> GetAllAsync()
        {
            return await GetUserReceipts()
                .AsNoTracking()
                .ToListAsync();
        }

        public override async Task<Receipt?> GetByIdAsync(int id)
        {
            return await GetUserReceipts()
                .Include(r => r.Category)
                .FirstOrDefaultAsync(r => r.Id == id);
        }

        public override async Task<bool> DeleteAsync(int id)
        {
            var entity = await GetUserReceipts().FirstOrDefaultAsync(r => r.Id == id);
            if (entity == null) return false;

            _dbSet.Remove(entity);
            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<IEnumerable<Receipt>> GetPagedAsync(ReceiptQueryParameters queryParams)
        {
            var query = GetUserReceipts()
                .AsNoTracking()
                .Include(r => r.Category)
                .AsQueryable();

            if (queryParams.StartDate.HasValue)
                query = query.Where(r => r.DateShopping.Date >= queryParams.StartDate.Value.Date);
            if (queryParams.EndDate.HasValue)
                query = query.Where(r => r.DateShopping.Date <= queryParams.EndDate.Value.Date);

            query = query.OrderByDescending(r => r.DateShopping);

            return await query
                .Skip((queryParams.Page - 1) * queryParams.PageSize)
                .Take(queryParams.PageSize)
                .ToListAsync();
        }

        public async Task<IEnumerable<Receipt>> GetReceiptsByQueryAsync(ReceiptQueryParameters queryParams)
        {
            var query = GetUserReceipts().AsNoTracking();

            if (queryParams.StartDate.HasValue)
                query = query.Where(r => r.DateShopping.Date >= queryParams.StartDate.Value.Date);
            if (queryParams.EndDate.HasValue)
                query = query.Where(r => r.DateShopping.Date <= queryParams.EndDate.Value.Date);

            return await query.ToListAsync();
        }

        public async Task<(int CategoryId, int Count)?> GetUserCategoryStatsAsync(string normalizedStoreName, Guid? userId)
        {
            var result = await _context.Receipts
                    .AsNoTracking()
                    .Where(r => r.UserId == userId
                             && r.CategoryId != null
                             && r.StoreName.ToLower().Contains(normalizedStoreName))
                    .GroupBy(r => r.CategoryId)
                    .Select(g => new { CategoryId = g.Key.Value, Count = g.Count() })
                    .OrderByDescending(x => x.Count)
                    .FirstOrDefaultAsync();

            if (result == null) return null;
            return (result.CategoryId, result.Count);
        }

        public async Task<(int CategoryId, int Count)?> GetGlobalCategoryStatsAsync(string normalizedStoreName, Guid? userId)
        {
            var result = await _context.Receipts
                .AsNoTracking()
                .Where(r => r.UserId != userId
                         && r.CategoryId != null
                         && r.StoreName.ToLower().Contains(normalizedStoreName))
                .GroupBy(r => r.CategoryId)
                .Select(g => new { CategoryId = g.Key.Value, Count = g.Count() })
                .OrderByDescending(x => x.Count)
                .FirstOrDefaultAsync();

            if (result == null) return null;
            return (result.CategoryId, result.Count);
        }
    }
}