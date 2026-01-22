using FinTracker.Models;

namespace FinTracker.Services
{
    public interface IOcrServiceFactory
    {
        IOcrService GetOcrService(OcrEngineType type);
    }
}
