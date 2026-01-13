using Microsoft.Extensions.DependencyInjection;

namespace FinTracker.Services
{
    public static class ServicesExtensions
    {
        public static void AddServices(this IServiceCollection services)
        {
            services.AddScoped<IReceiptService, ReceiptService>();
            services.AddScoped<IStoreService, StoreService>();
            services.AddSingleton<IOcrService, TesseractOcrService>();
            services.AddSingleton<IAzureOcrService, AzureVisionOcrService>();
            services.AddScoped<ICategoryService, CategoryService>();
            services.AddScoped<IAuthService, AuthService>();
        }
    }
}
