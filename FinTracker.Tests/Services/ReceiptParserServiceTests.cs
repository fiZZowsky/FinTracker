using FinTracker.Repositories;
using FinTracker.Services;
using FluentAssertions;
using Moq;

namespace FinTracker.Tests.Services
{
    public class ReceiptParserServiceTests
    {
        private readonly ReceiptParserService _parser;
        private readonly Mock<IStoreRepository> _storeRepoMock;
        private readonly Mock<IUserContextRepository> _userContextRepoMock;
        private readonly Mock<IReceiptRepository> _receiptRepoMock;

        public ReceiptParserServiceTests()
        {
            _storeRepoMock = new Mock<IStoreRepository>();
            _userContextRepoMock = new Mock<IUserContextRepository>();
            _receiptRepoMock = new Mock<IReceiptRepository>();

            _storeRepoMock.Setup(x => x.GetAllStoresName())
            .ReturnsAsync(new List<string>
             {
                    "Biedronka",
                    "Lidl",
                    "Żabka",
                    "Carrefour",
                    "Auchan",
                    "Pepco"
             });

            _userContextRepoMock.Setup(x => x.GetUserId()).Returns(Guid.NewGuid());

            _parser = new ReceiptParserService(
                            _storeRepoMock.Object,
                            _userContextRepoMock.Object,
                            _receiptRepoMock.Object);
        }

        [Theory]
        [InlineData("SUMA: 100.00 PLN", 100.00)]
        [InlineData("RAZEM 50,99", 50.99)]
        [InlineData("DO ZAPLATY 20.50", 20.50)]

        [InlineData("SUMA 1O0.00", 100.00)]
        [InlineData("RAZEM 5O,99", 50.99)]
        [InlineData("WARTOSC S0.00", 50.00)]
        [InlineData("SUMA B0.00", 80.00)]
        [InlineData("DO ZAPLATY 1200,00", 1200.00)]
        [InlineData("SUMA 1 200,00", 1200.00)]
        public async Task ParseReceiptTextAsync_ShouldExtractCorrectAmount(string ocrText, decimal expectedAmount)
        {
            var result = await _parser.ParseReceiptTextAsync(ocrText);

            result.TotalAmount.Should().Be(expectedAmount);
        }

        [Fact]
        public async Task ParseReceiptTextAsync_ShouldReturnZero_WhenNoKeywordsFound()
        {
            string text = "Mleko 2.00\nChleb 3.00\nDziękujemy zapraszamy ponownie";

            var result = await _parser.ParseReceiptTextAsync(text);

            result.TotalAmount.Should().Be(0m);
        }

        [Theory]
        [InlineData("Sklep Biedronka S.A.", "Biedronka")]
        [InlineData("Zakupy w LIDL sp z o.o.", "Lidl")]
        [InlineData("Zabka Polska", "Żabka")]
        [InlineData("Sklep Biedrnka", "Biedronka")]
        [InlineData("LID1", "Lidl")]
        public async Task ParseReceiptTextAsync_ShouldExtractStoreName(string ocrText, string expectedStore)
        {
            var result = await _parser.ParseReceiptTextAsync(ocrText);

            result.StoreName.Should().Be(expectedStore);
        }

        [Fact]
        public async Task ParseReceiptTextAsync_ShouldReturnUnknownStore_WhenNoMatchFound()
        {
            string text = "Nieznany Supermarket sp. z o.o.";

            var result = await _parser.ParseReceiptTextAsync(text);

            result.StoreName.Should().Be("Nieznany Sklep");
        }

        [Theory]
        [InlineData("Data: 2023-10-15", "2023-10-15")]
        [InlineData("Zakupy 15.10.2023", "2023-10-15")]
        [InlineData("15-10-2023", "2023-10-15")]
        public async Task ParseReceiptTextAsync_ShouldExtractDate(string ocrText, string expectedDateString)
        {
            var result = await _parser.ParseReceiptTextAsync(ocrText);

            var expectedDate = DateTime.Parse(expectedDateString);
            result.DateShopping.Date.Should().Be(expectedDate.Date);
        }

        [Fact]
        public async Task ParseReceiptTextAsync_ShouldReturnUtcNow_WhenNoDateFound()
        {
            string text = "Brak daty na paragonie";

            var result = await _parser.ParseReceiptTextAsync(text);

            result.DateShopping.Should().BeCloseTo(DateTime.UtcNow, TimeSpan.FromMinutes(1));
        }

        [Fact]
        public async Task ParseReceiptTextAsync_ShouldReturnDefault_WhenTextIsGarbage()
        {
            string garbageText = "Asdfghjkl\nqwertyuiop";

            var result = await _parser.ParseReceiptTextAsync(garbageText);

            result.TotalAmount.Should().Be(0);
            result.StoreName.Should().NotBeNull();
        }
    }
}