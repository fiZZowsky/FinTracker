using FinTracker.DataAccess;
using FinTracker.Models;
using FluentAssertions;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Moq;
using System.Net;
using System.Net.Http.Headers;
using System.Net.Http.Json;
using Xunit;

namespace FinTracker.IntegrationTests
{
    public class ReceiptsIntegrationTests : IClassFixture<IntegrationTestFactory>
    {
        private readonly HttpClient _client;
        private readonly IntegrationTestFactory _factory;
        private readonly Guid _testUserId = Guid.Parse("11111111-1111-1111-1111-111111111111");

        public ReceiptsIntegrationTests(IntegrationTestFactory factory)
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
        public async Task UploadReceipt_ShouldSaveToDatabase_AndReturn200()
        {
            using (var scope = _factory.Services.CreateScope())
            {
                var dbContext = scope.ServiceProvider.GetRequiredService<FinTrackerDbContext>();
                dbContext.Database.EnsureCreated();
                await CleanDatabaseAsync(dbContext);

                dbContext.Stores.Add(new Store { Name = "Biedronka", UserId = _testUserId });
                await dbContext.SaveChangesAsync();
            }

            _factory.OcrServiceMock.Setup(x => x.RecognizeTextAsync(It.IsAny<Stream>()))
                .ReturnsAsync("Biedronka\nData: 2023-10-20\nSUMA: 150.00 PLN");

            using var multipartContent = new MultipartFormDataContent();
            var fileContent = new ByteArrayContent(new byte[] { 0xFF, 0xD8, 0xFF, 0xE0 });
            fileContent.Headers.ContentType = MediaTypeHeaderValue.Parse("image/jpeg");
            multipartContent.Add(fileContent, "file", "test-receipt.jpg");

            var response = await _client.PostAsync("/api/Receipts/Upload?ocrEngine=3", multipartContent);

            response.EnsureSuccessStatusCode();
            var receiptDto = await response.Content.ReadFromJsonAsync<ReceiptDTO>();

            receiptDto.Should().NotBeNull();
            receiptDto!.StoreName.Should().Be("Biedronka");
            receiptDto.TotalAmount.Should().Be(150.00m);
        }

        [Fact]
        public async Task GetReceiptById_ShouldReturnReceipt_WhenExistsAndBelongsToUser()
        {
            int receiptId;
            using (var scope = _factory.Services.CreateScope())
            {
                var dbContext = scope.ServiceProvider.GetRequiredService<FinTrackerDbContext>();
                dbContext.Database.EnsureCreated();
                await CleanDatabaseAsync(dbContext);

                var receipt = new Receipt
                {
                    UserId = _testUserId,
                    StoreName = "Test Store",
                    TotalAmount = 123.45m,
                    DateShopping = DateTime.Now
                };
                dbContext.Receipts.Add(receipt);
                await dbContext.SaveChangesAsync();
                receiptId = receipt.Id;
            }

            var response = await _client.GetAsync($"/api/Receipts/{receiptId}");

            response.StatusCode.Should().Be(HttpStatusCode.OK);
            var result = await response.Content.ReadFromJsonAsync<ReceiptDTO>();
            result.Should().NotBeNull();
            result!.Id.Should().Be(receiptId);
            result.TotalAmount.Should().Be(123.45m);
        }

        [Fact]
        public async Task GetReceiptById_ShouldReturn404_WhenReceiptDoesNotExist()
        {
            var response = await _client.GetAsync("/api/Receipts/99999");

            response.StatusCode.Should().Be(HttpStatusCode.NotFound);
        }

        [Fact]
        public async Task GetReceiptById_ShouldReturn404_WhenReceiptBelongsToAnotherUser()
        {
            int otherUserReceiptId;
            var otherUserId = Guid.NewGuid();

            using (var scope = _factory.Services.CreateScope())
            {
                var dbContext = scope.ServiceProvider.GetRequiredService<FinTrackerDbContext>();
                dbContext.Database.EnsureCreated();
                await CleanDatabaseAsync(dbContext);

                var receipt = new Receipt
                {
                    UserId = otherUserId,
                    StoreName = "Secret Store",
                    TotalAmount = 999.00m,
                    DateShopping = DateTime.Now
                };
                dbContext.Receipts.Add(receipt);
                await dbContext.SaveChangesAsync();
                otherUserReceiptId = receipt.Id;
            }

            var response = await _client.GetAsync($"/api/Receipts/{otherUserReceiptId}");

            response.StatusCode.Should().Be(HttpStatusCode.NotFound);
        }

        [Fact]
        public async Task DeleteReceipt_ShouldReturn204_AndRemoveFromDatabase()
        {
            int receiptId;
            using (var scope = _factory.Services.CreateScope())
            {
                var dbContext = scope.ServiceProvider.GetRequiredService<FinTrackerDbContext>();
                dbContext.Database.EnsureCreated();
                await CleanDatabaseAsync(dbContext);

                var receipt = new Receipt { UserId = _testUserId, StoreName = "To Delete", TotalAmount = 50, DateShopping = DateTime.Now };
                dbContext.Receipts.Add(receipt);
                await dbContext.SaveChangesAsync();
                receiptId = receipt.Id;
            }

            var response = await _client.DeleteAsync($"/api/Receipts/{receiptId}");

            response.StatusCode.Should().Be(HttpStatusCode.NoContent);

            using (var scope = _factory.Services.CreateScope())
            {
                var dbContext = scope.ServiceProvider.GetRequiredService<FinTrackerDbContext>();
                var deletedReceipt = await dbContext.Receipts.FindAsync(receiptId);
                deletedReceipt.Should().BeNull();
            }
        }

        [Fact]
        public async Task GetPaged_ShouldReturnOnlyUserReceipts()
        {
            using (var scope = _factory.Services.CreateScope())
            {
                var dbContext = scope.ServiceProvider.GetRequiredService<FinTrackerDbContext>();
                dbContext.Database.EnsureCreated();
                await CleanDatabaseAsync(dbContext);

                dbContext.Receipts.AddRange(
                    new Receipt { UserId = _testUserId, StoreName = "User Receipt 1", TotalAmount = 10, DateShopping = DateTime.Now },
                    new Receipt { UserId = _testUserId, StoreName = "User Receipt 2", TotalAmount = 20, DateShopping = DateTime.Now },
                    new Receipt { UserId = Guid.NewGuid(), StoreName = "Other User Receipt", TotalAmount = 30, DateShopping = DateTime.Now }
                );
                await dbContext.SaveChangesAsync();
            }

            var response = await _client.GetAsync("/api/Receipts?Page=1&PageSize=10");

            response.StatusCode.Should().Be(HttpStatusCode.OK);
            var result = await response.Content.ReadFromJsonAsync<IEnumerable<ReceiptDTO>>();

            result.Should().HaveCount(2);
            result!.All(r => r.StoreName.StartsWith("User Receipt")).Should().BeTrue();
        }

        [Fact]
        public async Task GetSummary_ShouldReturnCorrectSums()
        {
            using (var scope = _factory.Services.CreateScope())
            {
                var dbContext = scope.ServiceProvider.GetRequiredService<FinTrackerDbContext>();
                dbContext.Database.EnsureCreated();
                await CleanDatabaseAsync(dbContext);

                dbContext.Receipts.AddRange(
                    new Receipt { UserId = _testUserId, StoreName = "A", TotalAmount = 100, DateShopping = new DateTime(2023, 01, 10) },
                    new Receipt { UserId = _testUserId, StoreName = "B", TotalAmount = 50, DateShopping = new DateTime(2023, 01, 20) },
                    new Receipt { UserId = _testUserId, StoreName = "C", TotalAmount = 200, DateShopping = new DateTime(2023, 02, 10) }
                );
                await dbContext.SaveChangesAsync();
            }

            var url = "/api/Receipts/Summary?startDate=2023-01-01&endDate=2023-01-31&filterType=month";
            var response = await _client.GetAsync(url);

            response.StatusCode.Should().Be(HttpStatusCode.OK);
            var result = await response.Content.ReadFromJsonAsync<IEnumerable<SummaryDataDTO>>();

            var totalSum = result!.Sum(x => x.Total);
            totalSum.Should().Be(150);
        }

        [Fact]
        public async Task UploadReceipt_ShouldReturn400_WhenFileIsInvalid()
        {
            using var multipartContent = new MultipartFormDataContent();
            var fileContent = new ByteArrayContent(new byte[0]);
            multipartContent.Add(fileContent, "file", "empty.jpg");

            var response = await _client.PostAsync("/api/Receipts/Upload", multipartContent);

            response.StatusCode.Should().Be(HttpStatusCode.BadRequest);
        }

        [Fact]
        public async Task UpdateReceipt_ShouldModifyDatabase_WhenReceiptBelongsToUser()
        {
            int receiptId;
            using (var scope = _factory.Services.CreateScope())
            {
                var dbContext = scope.ServiceProvider.GetRequiredService<FinTrackerDbContext>();
                dbContext.Database.EnsureCreated();
                await CleanDatabaseAsync(dbContext);

                var receipt = new Receipt
                {
                    UserId = _testUserId,
                    StoreName = "Stara Nazwa",
                    TotalAmount = 10.00m,
                    DateShopping = DateTime.Now
                };
                dbContext.Receipts.Add(receipt);
                await dbContext.SaveChangesAsync();
                receiptId = receipt.Id;
            }

            var updateDto = new ReceiptDTO
            {
                Id = receiptId,
                StoreName = "Nowa Nazwa Sklepu",
                TotalAmount = 99.99m,
                DateShopping = DateTime.Now.AddDays(-1)
            };

            var response = await _client.PutAsJsonAsync($"/api/Receipts/{receiptId}", updateDto);

            response.EnsureSuccessStatusCode();

            using (var scope = _factory.Services.CreateScope())
            {
                var dbContext = scope.ServiceProvider.GetRequiredService<FinTrackerDbContext>();
                var updatedReceipt = await dbContext.Receipts.FindAsync(receiptId);

                updatedReceipt.Should().NotBeNull();
                updatedReceipt!.StoreName.Should().Be("Nowa Nazwa Sklepu");
                updatedReceipt.TotalAmount.Should().Be(99.99m);
            }
        }

        [Fact]
        public async Task UploadReceipt_ShouldReturn500_WhenOcrServiceFails()
        {
            _factory.OcrServiceMock.Setup(x => x.RecognizeTextAsync(It.IsAny<Stream>()))
                .ThrowsAsync(new Exception("Błąd połączenia z API Google Vision"));

            using var multipartContent = new MultipartFormDataContent();
            var fileContent = new ByteArrayContent(new byte[] { 0xFF, 0xD8, 0xFF, 0xE0 });
            multipartContent.Add(fileContent, "file", "receipt.jpg");

            var response = await _client.PostAsync("/api/Receipts/Upload", multipartContent);

            response.StatusCode.Should().Be(HttpStatusCode.InternalServerError);
        }

        [Fact]
        public async Task UpdateReceipt_ShouldReturn400_WhenAmountIsNegative()
        {
            int receiptId;
            using (var scope = _factory.Services.CreateScope())
            {
                var dbContext = scope.ServiceProvider.GetRequiredService<FinTrackerDbContext>();
                dbContext.Database.EnsureCreated();
                await CleanDatabaseAsync(dbContext);

                var receipt = new Receipt { UserId = _testUserId, StoreName = "Ok", TotalAmount = 10, DateShopping = DateTime.Now };
                dbContext.Receipts.Add(receipt);
                await dbContext.SaveChangesAsync();
                receiptId = receipt.Id;
            }

            var invalidDto = new ReceiptDTO
            {
                Id = receiptId,
                StoreName = "Ok",
                TotalAmount = -50.00m,
                DateShopping = DateTime.Now
            };

            var response = await _client.PutAsJsonAsync($"/api/Receipts/{receiptId}", invalidDto);

            response.StatusCode.Should().Be(HttpStatusCode.BadRequest);
        }
    }
}