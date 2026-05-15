using AutoMapper;
using FinTracker.Models;
using FinTracker.Repositories;
using FinTracker.Services;
using FluentAssertions;
using Microsoft.Extensions.Logging;
using Moq;

namespace FinTracker.Tests.Services
{
    public class ReceiptServiceTests
    {
        private readonly Mock<IReceiptRepository> _receiptRepoMock;
        private readonly Mock<IStoreRepository> _storeRepoMock;
        private readonly Mock<IUserContextRepository> _userContextMock;
        private readonly Mock<IReceiptParserService> _parserMock;
        private readonly Mock<IOcrServiceFactory> _ocrFactoryMock;
        private readonly Mock<IMapper> _mapperMock;
        private readonly Mock<IExchangeRateService> _exchangeRateMock;
        private readonly Mock<ILogger<ReceiptService>> _loggerMock;

        private readonly ReceiptService _service;

        public ReceiptServiceTests()
        {
            _receiptRepoMock = new Mock<IReceiptRepository>();
            _storeRepoMock = new Mock<IStoreRepository>();
            _userContextMock = new Mock<IUserContextRepository>();
            _parserMock = new Mock<IReceiptParserService>();
            _ocrFactoryMock = new Mock<IOcrServiceFactory>();
            _mapperMock = new Mock<IMapper>();
            _exchangeRateMock = new Mock<IExchangeRateService>();
            _loggerMock = new Mock<ILogger<ReceiptService>>();

            _service = new ReceiptService(
                _receiptRepoMock.Object,
                _storeRepoMock.Object,
                _userContextMock.Object,
                _parserMock.Object,
                _ocrFactoryMock.Object,
                _mapperMock.Object,
                _exchangeRateMock.Object,
                _loggerMock.Object
            );
        }

        [Fact]
        public async Task CreateAsync_ShouldThrowUnauthorized_WhenUserIdIsNull()
        {
            _userContextMock.Setup(x => x.GetUserId()).Returns((Guid?)null);

            var dto = new ReceiptDTO();

            await Assert.ThrowsAsync<UnauthorizedAccessException>(() => _service.CreateAsync(dto));
        }

        [Fact]
        public async Task CreateReceiptFromImageAsync_ShouldUseOcrAndParser()
        {
            var stream = new MemoryStream();
            var extractedText = "Mleko 2.00";
            var expectedDto = new ReceiptDTO { StoreName = "Sklepik", TotalAmount = 2.00m };

            var ocrServiceMock = new Mock<IOcrService>();
            ocrServiceMock.Setup(x => x.RecognizeTextAsync(It.IsAny<Stream>()))
                .ReturnsAsync(extractedText);

            _ocrFactoryMock.Setup(x => x.GetOcrService(It.IsAny<OcrEngineType>()))
                .Returns(ocrServiceMock.Object);

            _parserMock.Setup(x => x.ParseReceiptTextAsync(extractedText))
                .ReturnsAsync(expectedDto);

            var result = await _service.CreateReceiptFromImageAsync(OcrEngineType.GoogleGeminiAI, stream, null);

            result.Should().Be(expectedDto);

            ocrServiceMock.Verify(x => x.RecognizeTextAsync(It.IsAny<Stream>()), Times.Once);
        }

        [Fact]
        public async Task CreateReceiptFromImageAsync_ShouldSkipOcr_WhenTextIsProvided()
        {
            var providedText = "Tekst z frontend";
            var stream = new MemoryStream();

            await _service.CreateReceiptFromImageAsync(OcrEngineType.GoogleGeminiAI, stream, providedText);

            _ocrFactoryMock.Verify(x => x.GetOcrService(It.IsAny<OcrEngineType>()), Times.Never);

            _parserMock.Verify(x => x.ParseReceiptTextAsync(providedText), Times.Once);
        }

        [Fact]
        public async Task DeleteAsync_ShouldReturnTrue_WhenReceiptExists()
        {
            int receiptId = 1;
            _receiptRepoMock.Setup(x => x.DeleteAsync(receiptId)).ReturnsAsync(true);

            var result = await _service.DeleteAsync(receiptId);

            result.Should().BeTrue();
            _receiptRepoMock.Verify(x => x.DeleteAsync(receiptId), Times.Once);
        }

        [Fact]
        public async Task DeleteAsync_ShouldReturnFalse_WhenReceiptDoesNotExist()
        {
            int receiptId = 999;
            _receiptRepoMock.Setup(x => x.DeleteAsync(receiptId)).ReturnsAsync(false);

            var result = await _service.DeleteAsync(receiptId);

            result.Should().BeFalse();
        }

        [Fact]
        public async Task UpdateAsync_ShouldUpdateAndReturnTrue_WhenReceiptExists()
        {
            int receiptId = 1;
            var updateDto = new ReceiptDTO { StoreName = "Nowa Nazwa", TotalAmount = 100 };
            var existingEntity = new Receipt { Id = receiptId, StoreName = "Stara", TotalAmount = 50 };

            _receiptRepoMock.Setup(x => x.GetByIdAsync(receiptId)).ReturnsAsync(existingEntity);
            _receiptRepoMock.Setup(x => x.UpdateAsync(It.IsAny<Receipt>())).Returns(Task.CompletedTask);

            _mapperMock.Setup(m => m.Map(updateDto, existingEntity))
                       .Callback<ReceiptDTO, Receipt>((src, dest) =>
                       {
                           dest.StoreName = src.StoreName;
                           dest.TotalAmount = src.TotalAmount;
                       });

            var result = await _service.UpdateAsync(receiptId, updateDto);

            result.Should().BeTrue();
            existingEntity.StoreName.Should().Be("Nowa Nazwa");
        }
    }
}