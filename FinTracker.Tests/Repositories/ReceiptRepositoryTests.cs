using FinTracker.DataAccess;
using FinTracker.Models;
using FinTracker.Repositories;
using FluentAssertions;
using Microsoft.EntityFrameworkCore;
using Moq;

namespace FinTracker.Tests.Repositories
{
    public class ReceiptRepositoryTests
    {
        private async Task<FinTrackerDbContext> GetDatabaseContext()
        {
            var options = new DbContextOptionsBuilder<FinTrackerDbContext>()
                .UseInMemoryDatabase(databaseName: Guid.NewGuid().ToString())
                .Options;

            var databaseContext = new FinTrackerDbContext(options);
            await databaseContext.Database.EnsureCreatedAsync();

            return databaseContext;
        }

        [Fact]
        public async Task GetPagedAsync_ShouldFilterByUserId()
        {
            var dbContext = await GetDatabaseContext();
            var userId1 = Guid.NewGuid();
            var userId2 = Guid.NewGuid();

            var userContextMock = new Mock<IUserContextRepository>();
            userContextMock.Setup(x => x.GetUserId()).Returns(userId1);

            dbContext.Receipts.AddRange(
                new Receipt { Id = 1, UserId = userId1, StoreName = "User1 Store", DateShopping = DateTime.Now, TotalAmount = 10 },
                new Receipt { Id = 2, UserId = userId1, StoreName = "User1 Store 2", DateShopping = DateTime.Now, TotalAmount = 20 },
                new Receipt { Id = 3, UserId = userId2, StoreName = "User2 Store", DateShopping = DateTime.Now, TotalAmount = 30 }
            );
            await dbContext.SaveChangesAsync();

            var repository = new ReceiptRepository(dbContext, userContextMock.Object);

            var queryParams = new ReceiptQueryParameters
            {
                Page = 1,
                PageSize = 10
            };

            var result = await repository.GetPagedAsync(queryParams);

            result.Should().HaveCount(2);
            result.All(r => r.UserId == userId1).Should().BeTrue();
        }

        [Fact]
        public async Task GetPagedAsync_ShouldFilterByDateRange()
        {
            var dbContext = await GetDatabaseContext();
            var userId1 = Guid.NewGuid();

            var userContextMock = new Mock<IUserContextRepository>();
            userContextMock.Setup(x => x.GetUserId()).Returns(userId1);

            dbContext.Receipts.AddRange(
                new Receipt { Id = 1, UserId = userId1, StoreName = "Sklep A", DateShopping = new DateTime(2023, 10, 01), TotalAmount = 10 },
                new Receipt { Id = 2, UserId = userId1, StoreName = "Sklep B", DateShopping = new DateTime(2023, 10, 15), TotalAmount = 20 },
                new Receipt { Id = 3, UserId = userId1, StoreName = "Sklep C", DateShopping = new DateTime(2023, 11, 01), TotalAmount = 30 }
            );
            await dbContext.SaveChangesAsync();

            var repository = new ReceiptRepository(dbContext, userContextMock.Object);

            var queryParams = new ReceiptQueryParameters
            {
                StartDate = new DateTime(2023, 10, 10),
                EndDate = new DateTime(2023, 10, 20),
                Page = 1,
                PageSize = 10
            };

            var result = await repository.GetPagedAsync(queryParams);

            result.Should().HaveCount(1);
            result.First().Id.Should().Be(2);
        }

        //[Fact]
        //public async Task GetSummaryAsync_ShouldGroupDataByMonth()
        //{
        //    var dbContext = await GetDatabaseContext();
        //    var userId = Guid.NewGuid();
        //    var userContextMock = new Mock<IUserContextRepository>();
        //    userContextMock.Setup(x => x.GetUserId()).Returns(userId);

        //    dbContext.Receipts.AddRange(
        //        new Receipt { UserId = userId, StoreName = "A", DateShopping = new DateTime(2023, 01, 10), TotalAmount = 100 },
        //        new Receipt { UserId = userId, StoreName = "A", DateShopping = new DateTime(2023, 01, 20), TotalAmount = 50 },
        //        new Receipt { UserId = userId, StoreName = "B", DateShopping = new DateTime(2023, 02, 10), TotalAmount = 200 }
        //    );
        //    await dbContext.SaveChangesAsync();

        //    var repository = new ReceiptRepository(dbContext, userContextMock.Object);

        //    var query = new ReceiptQueryParameters
        //    {
        //        FilterType = "year",
        //        StartDate = new DateTime(2023, 01, 01),
        //        EndDate = new DateTime(2023, 12, 31)
        //    };

        //    var result = await repository.GetSummaryAsync(query);

        //    result.Should().HaveCount(2);

        //    var january = result.FirstOrDefault(x => x.Label.Contains("2023-01") || x.Label == "1");
        //    january.Should().NotBeNull();
        //    january!.Total.Should().Be(150);
        //}
    }
}