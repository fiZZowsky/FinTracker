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
            return await GetUserReceipts().ToListAsync();
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

            if (entity == null)
            {
                return false;
            }

            _dbSet.Remove(entity);
            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<IEnumerable<Receipt>> GetPagedAsync(ReceiptQueryParameters queryParams)
        {
            var query = GetUserReceipts().Include(r => r.Category).AsQueryable();

            if (queryParams.StartDate.HasValue)
            {
                query = query.Where(r => r.DateShopping.Date >= queryParams.StartDate.Value.Date);
            }
            if (queryParams.EndDate.HasValue)
            {
                query = query.Where(r => r.DateShopping.Date <= queryParams.EndDate.Value.Date);
            }

            query = query.OrderByDescending(r => r.DateShopping);

            return await query
                .Skip((queryParams.Page - 1) * queryParams.PageSize)
                .Take(queryParams.PageSize)
                .ToListAsync();
        }

        public async Task<IEnumerable<SummaryDataDTO>> GetSummaryAsync(ReceiptQueryParameters queryParams)
        {
            var query = GetUserReceipts();

            if (queryParams.StartDate.HasValue)
            {
                query = query.Where(r => r.DateShopping.Date >= queryParams.StartDate.Value.Date);
            }
            if (queryParams.EndDate.HasValue)
            {
                query = query.Where(r => r.DateShopping.Date <= queryParams.EndDate.Value.Date);
            }

            var filterType = queryParams.FilterType?.ToLower();
            if (string.IsNullOrEmpty(filterType) && (queryParams.StartDate.HasValue || queryParams.EndDate.HasValue))
            {
                filterType = "month";
            }

            switch (filterType)
            {
                case "week":
                    var receiptsInWeek = await query.ToListAsync();
                    var weeklyData = receiptsInWeek
                        .GroupBy(r => r.DateShopping.DayOfWeek)
                        .Select(g => new
                        {
                            DayOfWeek = g.Key,
                            Total = g.Sum(r => r.TotalAmount)
                        })
                        .ToList();

                    return weeklyData.Select(g => new SummaryDataDTO
                    {
                        Label = (g.DayOfWeek == DayOfWeek.Sunday ? 7 : (int)g.DayOfWeek).ToString(),
                        Total = g.Total
                    })
                    .OrderBy(x => int.Parse(x.Label))
                    .ToList();

                case "month":
                    return await query
                        .GroupBy(r => r.DateShopping.Day)
                        .OrderBy(g => g.Key)
                        .Select(g => new SummaryDataDTO
                        {
                            Label = g.Key.ToString(),
                            Total = g.Sum(r => r.TotalAmount)
                        })
                        .ToListAsync();

                case "sixmonths":
                case "year":
                    var monthlyData = await query
                        .GroupBy(r => new { r.DateShopping.Year, r.DateShopping.Month })
                        .Select(g => new
                        {
                            g.Key.Year,
                            g.Key.Month,
                            Total = g.Sum(r => r.TotalAmount)
                        })
                        .OrderBy(s => s.Year)
                        .ThenBy(s => s.Month)
                        .ToListAsync();

                    return monthlyData.Select(g => new SummaryDataDTO
                    {
                        Label = $"{g.Year}-{g.Month:D2}",
                        Total = g.Total
                    })
                    .ToList();

                case "all":
                default:
                    return await query
                        .GroupBy(r => r.DateShopping.Year)
                        .OrderBy(g => g.Key)
                        .Select(g => new SummaryDataDTO
                        {
                            Label = g.Key.ToString(),
                            Total = g.Sum(r => r.TotalAmount)
                        })
                        .ToListAsync();
            }
        }

        public async Task<int?> GetMostFrequentCategoryIdAsync(string storeName)
        {
            if (string.IsNullOrWhiteSpace(storeName)) return null;
            var normalizedStoreName = storeName.ToLower();

            return await GetUserReceipts()
                .Where(r => r.StoreName.ToLower() == normalizedStoreName && r.CategoryId != null)
                .GroupBy(r => r.CategoryId)
                .OrderByDescending(g => g.Count())
                .Select(g => g.Key)
                .FirstOrDefaultAsync();
        }
    }
}