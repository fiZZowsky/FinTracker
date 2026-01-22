using FinTracker.Models;
using Microsoft.Extensions.DependencyInjection;

namespace FinTracker.Services
{
    public class OcrServiceFactory : IOcrServiceFactory
    {
        private readonly IServiceProvider _serviceProvider;

        public OcrServiceFactory(IServiceProvider serviceProvider)
        {
            _serviceProvider = serviceProvider;
        }

        public IOcrService GetOcrService(OcrEngineType type)
        {
            return type switch
            {
                OcrEngineType.TesseractOCR => _serviceProvider.GetRequiredService<TesseractOcrService>(),
                OcrEngineType.AzureAIVision => _serviceProvider.GetRequiredService<AzureVisionOcrService>(),
                OcrEngineType.PaddleOCR => _serviceProvider.GetRequiredService<PaddleOcrService>(),
                OcrEngineType.GoogleGeminiAI => _serviceProvider.GetRequiredService<GoogleGeminiOcrService>(),
                _ => throw new ArgumentException("Nieznany silnik OCR", nameof(type))
            };
        }
    }
}
