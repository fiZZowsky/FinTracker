using FinTracker.Models;
using FinTracker.Services.Base;

namespace FinTracker.Services
{
    public interface IReceiptService : IBaseService<ReceiptDTO, int>
    {
        Task<ReceiptDTO> CreateReceiptFromImageAsync(Stream imageStream);
        Task<IEnumerable<ReceiptDTO>> GetPagedAsync(ReceiptQueryParameters query);
        Task<IEnumerable<SummaryDataDTO>> GetSummaryAsync(ReceiptQueryParameters query);
    }
}
