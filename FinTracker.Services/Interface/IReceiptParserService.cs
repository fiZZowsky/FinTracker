using FinTracker.Models;

namespace FinTracker.Services
{
    public interface IReceiptParserService
    {
        Task<ReceiptDTO> ParseReceiptTextAsync(string ocrText);
    }
}