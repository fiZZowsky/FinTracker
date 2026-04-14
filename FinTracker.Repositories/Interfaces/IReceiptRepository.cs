using FinTracker.Models;

namespace FinTracker.Repositories
{
    public interface IReceiptRepository : IBaseRepository<Receipt, int>
    {
        Task<IEnumerable<Receipt>> GetPagedAsync(ReceiptQueryParameters query);
        Task<IEnumerable<SummaryDataDTO>> GetSummaryAsync(ReceiptQueryParameters query);
        Task<(int CategoryId, int Count)?> GetUserCategoryStatsAsync(string normalizedStoreName, Guid? userId);
        Task<(int CategoryId, int Count)?> GetGlobalCategoryStatsAsync(string normalizedStoreName, Guid? userId);
    }
}
