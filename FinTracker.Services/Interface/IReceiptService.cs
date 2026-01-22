using FinTracker.Models;
using FinTracker.Services.Base;

namespace FinTracker.Services
{
    public interface IReceiptService : IBaseService<ReceiptDTO, int>
    {
        Task<ReceiptDTO> CreateReceiptFromImageAsync(Stream imageStream, OcrEngineType ocrEngine);
        Task<IEnumerable<ReceiptDTO>> GetPagedAsync(ReceiptQueryParameters query);
        Task<IEnumerable<SummaryDataDTO>> GetSummaryAsync(ReceiptQueryParameters query);
        Task<int?> GetSuggestedCategoryForStoreAsync(string storeName);
    }
}
