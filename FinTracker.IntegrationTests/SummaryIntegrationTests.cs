using FinTracker.DataAccess;
using FinTracker.Models;
using FluentAssertions;
using Google.GenAI;
using Microsoft.Extensions.DependencyInjection;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http.Headers;
using System.Net.Http.Json;
using System.Text;
using System.Threading.Tasks;
using Xunit;

namespace FinTracker.IntegrationTests
{
    public class SummaryIntegrationTests : IClassFixture<IntegrationTestFactory>
    {
        private readonly HttpClient _client;
        private readonly IntegrationTestFactory _factory;
        private readonly Guid _testUserId = Guid.Parse("11111111-1111-1111-1111-111111111111");

        public SummaryIntegrationTests(IntegrationTestFactory factory)
        {
            _factory = factory;
            _client = factory.CreateClient();
            _client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Test");
        }

        private async Task CleanDatabaseAsync(FinTrackerDbContext dbContext)
        {
            dbContext.Receipts.RemoveRange(dbContext.Receipts);
            dbContext.Stores.RemoveRange(dbContext.Stores);
            await dbContext.SaveChangesAsync();
        }
        [Fact]
        public async Task GetPaged_ShouldFilterByDateRange()
        {
            using (var scope = _factory.Services.CreateScope())
            {
                var dbContext = scope.ServiceProvider.GetRequiredService<FinTrackerDbContext>();
                dbContext.Database.EnsureCreated();
                await CleanDatabaseAsync(dbContext);

                dbContext.Receipts.AddRange(
                    new Receipt { UserId = _testUserId, StoreName = "In Range", TotalAmount = 10, DateShopping = new DateTime(2023, 10, 15) },
                    new Receipt { UserId = _testUserId, StoreName = "Too Early", TotalAmount = 10, DateShopping = new DateTime(2023, 09, 30) },
                    new Receipt { UserId = _testUserId, StoreName = "Too Late", TotalAmount = 10, DateShopping = new DateTime(2023, 11, 01) }
                );
                await dbContext.SaveChangesAsync();
            }

            var url = "/api/Receipts?startDate=2023-10-01&endDate=2023-10-31&Page=1&PageSize=10";
            var response = await _client.GetAsync(url);

            response.StatusCode.Should().Be(HttpStatusCode.OK);
            var result = await response.Content.ReadFromJsonAsync<IEnumerable<ReceiptDTO>>();

            result.Should().HaveCount(1);
            result!.First().StoreName.Should().Be("In Range");
        }
    }
}
