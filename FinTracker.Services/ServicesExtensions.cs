using Microsoft.Extensions.DependencyInjection;

namespace FinTracker.Services
{
    public static class ServicesExtensions
    {
        public static void AddServices(this IServiceCollection services)
        {
            services.AddScoped<IReceiptService, ReceiptService>();
            services.AddScoped<IStoreService, StoreService>();
            services.AddScoped<ICategoryService, CategoryService>();
            services.AddScoped<IAuthService, AuthService>();
            services.AddScoped<IReceiptParserService, ReceiptParserService>();
            services.AddScoped<TesseractOcrService>();
            services.AddScoped<AzureVisionOcrService>();
            services.AddScoped<GoogleGeminiOcrService>();
            services.AddScoped<IOcrServiceFactory, OcrServiceFactory>();
            services.AddScoped<IFileValidationService, FileValidationService>();
            services.AddHttpClient<IExchangeRateService, ExchangeRateService>();
        }
    }
}
