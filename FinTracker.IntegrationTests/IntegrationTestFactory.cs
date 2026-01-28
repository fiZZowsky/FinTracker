using FinTracker.DataAccess;
using FinTracker.Models;
using FinTracker.Services;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.AspNetCore.TestHost;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Storage; // Ważny using
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using Moq;
using System.Security.Claims;
using System.Text.Encodings.Web;
using Microsoft.Extensions.Options;

namespace FinTracker.IntegrationTests
{
    public class IntegrationTestFactory : WebApplicationFactory<Program>
    {
        public Mock<IOcrServiceFactory> OcrFactoryMock { get; } = new();
        public Mock<IOcrService> OcrServiceMock { get; } = new();

        // "Kotwica" trzymająca bazę w pamięci
        private readonly InMemoryDatabaseRoot _databaseRoot = new InMemoryDatabaseRoot();

        protected override void ConfigureWebHost(IWebHostBuilder builder)
        {
            builder.ConfigureTestServices(services =>
            {
                // 1. ROBUST CLEANUP: Usuwamy WSZYSTKIE rejestracje związane z bazą
                // (Zarówno DbContextOptions jak i sam FinTrackerDbContext)
                var dbContextDescriptors = services.Where(d =>
                    d.ServiceType == typeof(DbContextOptions<FinTrackerDbContext>) ||
                    d.ServiceType == typeof(FinTrackerDbContext)).ToList();

                foreach (var descriptor in dbContextDescriptors)
                {
                    services.Remove(descriptor);
                }

                // 2. Dodajemy bazę In-Memory z zakotwiczeniem (_databaseRoot)
                services.AddDbContext<FinTrackerDbContext>(options =>
                {
                    options.UseInMemoryDatabase("InMemoryDbForIntegrationTesting", _databaseRoot);
                    options.EnableSensitiveDataLogging(); // Pomoże w debugowaniu błędów EF
                });

                // 3. HttpContextAccessor (niezbędny dla UserContextService)
                services.AddHttpContextAccessor();

                // 4. Mockowanie OCR
                var ocrFactoryDescriptor = services.SingleOrDefault(d => d.ServiceType == typeof(IOcrServiceFactory));
                if (ocrFactoryDescriptor != null) services.Remove(ocrFactoryDescriptor);

                OcrFactoryMock.Setup(x => x.GetOcrService(It.IsAny<OcrEngineType>()))
                    .Returns(OcrServiceMock.Object);

                services.AddSingleton(OcrFactoryMock.Object);

                // 5. Autoryzacja testowa
                services.AddAuthentication("Test")
                        .AddScheme<AuthenticationSchemeOptions, TestAuthHandler>("Test", options => { });
            });
        }
    }

    public class TestAuthHandler : AuthenticationHandler<AuthenticationSchemeOptions>
    {
        public TestAuthHandler(IOptionsMonitor<AuthenticationSchemeOptions> options,
            ILoggerFactory logger, UrlEncoder encoder)
            : base(options, logger, encoder)
        {
        }

        protected override async Task<AuthenticateResult> HandleAuthenticateAsync()
        {
            var claims = new[]
            {
                new Claim(ClaimTypes.Name, "TestUser"),
                // ID musi być zgodne z tym w teście
                new Claim(ClaimTypes.NameIdentifier, "11111111-1111-1111-1111-111111111111")
            };
            var identity = new ClaimsIdentity(claims, "Test");
            var principal = new ClaimsPrincipal(identity);
            var ticket = new AuthenticationTicket(principal, "Test");

            return AuthenticateResult.Success(ticket);
        }
    }
}