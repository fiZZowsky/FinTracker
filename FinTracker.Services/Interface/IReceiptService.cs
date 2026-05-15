using FinTracker.Models;
using FinTracker.Services.Base;

namespace FinTracker.Services
{
    public interface IReceiptService : IBaseService<ReceiptDTO, int>
    {
        Task<ReceiptDTO> CreateReceiptFromImageAsync(OcrEngineType ocrEngine, Stream imageStream, string? extractedText);
        Task<ReceiptDTO> GetByIdAsync(int id, string? targetCurrency = null);
        Task<IEnumerable<ReceiptDTO>> GetPagedAsync(ReceiptQueryParameters query);
        Task<IEnumerable<SummaryDataDTO>> GetSummaryAsync(ReceiptQueryParameters query);
        Task<int?> PredictCategoryAsync(string rawStoreName);
    }
}
