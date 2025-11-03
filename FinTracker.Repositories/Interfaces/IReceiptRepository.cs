using FinTracker.Models;

namespace FinTracker.Repositories
{
    public interface IReceiptRepository : IBaseRepository<Receipt, int>
    {
        Task<IEnumerable<Receipt>> GetPagedAsync(ReceiptQueryParameters query);
        Task<IEnumerable<SummaryDataDTO>> GetSummaryAsync(ReceiptQueryParameters query);
    }
}
