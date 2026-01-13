using Microsoft.Extensions.DependencyInjection;

namespace FinTracker.Repositories
{
    public static class RepositoriesExtensions
    {
        public static void AddRepositories(this IServiceCollection services)
        {
            services.AddScoped(typeof(IBaseRepository<,>), typeof(BaseRepository<,>));
            services.AddScoped<IReceiptRepository, ReceiptRepository>();
            services.AddScoped<IStoreRepository, StoreRepository>();
            services.AddScoped<ICategoryRepository, CategoryRepository>();
            services.AddScoped<IUserContextRepository, UserContextRepository>();
        }
    }
}
