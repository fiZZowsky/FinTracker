using FinTracker.DataAccess;
using FinTracker.Models;
using Microsoft.EntityFrameworkCore;

namespace FinTracker.Repositories
{
    public class ReceiptRepository : BaseRepository<Receipt, int>, IReceiptRepository
    {
        public ReceiptRepository(FinTrackerDbContext context) : base(context)
        {
        }

        public async Task<IEnumerable<Receipt>> GetPagedAsync(ReceiptQueryParameters queryParams)
        {
            var query = _dbSet.AsQueryable();

            if (queryParams.StartDate.HasValue)
            {
                query = query.Where(r => r.DateShopping.Date >= queryParams.StartDate.Value.Date);
            }
            if (queryParams.EndDate.HasValue)
            {
                query = query.Where(r => r.DateShopping.Date <= queryParams.EndDate.Value.Date);
            }

            query = query.OrderByDescending(r => r.DateShopping);

            query = query
              .Skip((queryParams.Page - 1) * queryParams.PageSize)
              .Take(queryParams.PageSize);

            return await query.ToListAsync();
        }

        public async Task<IEnumerable<SummaryDataDTO>> GetSummaryAsync(ReceiptQueryParameters queryParams)
        {
            var query = _dbSet.AsQueryable();

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
                    var weeklyData = await query
                        .GroupBy(r => r.DateShopping.DayOfWeek)
                        .Select(g => new
                        {
                            DayOfWeek = g.Key,
                            Total = g.Sum(r => r.TotalAmount)
                        })
                        .ToListAsync();

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
                                  .Select(g => new SummaryDataDTO
                                  {
                                      Label = g.Key.ToString(),
                                      Total = g.Sum(r => r.TotalAmount)
                                  })
                      .OrderBy(s => int.Parse(s.Label))
                      .ToListAsync();

                case "sixmonths":
                case "year":
                    return await query
                      .GroupBy(r => new { r.DateShopping.Year, r.DateShopping.Month })
                      .Select(g => new SummaryDataDTO
                      {
                          Label = $"{g.Key.Year}-{g.Key.Month:D2}",
                          Total = g.Sum(r => r.TotalAmount)
                      })
                      .OrderBy(s => s.Label)
                      .ToListAsync();

                case "all":
                default:
                    return await query
                      .GroupBy(r => r.DateShopping.Year)
                                  .Select(g => new SummaryDataDTO
                                  {
                                      Label = g.Key.ToString(),
                                      Total = g.Sum(r => r.TotalAmount)
                                  })
                      .OrderBy(s => s.Label)
                      .ToListAsync();
            }
        }
    }
}
