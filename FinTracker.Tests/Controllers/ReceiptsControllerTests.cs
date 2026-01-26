using FinTracker.API.Controllers;
using FinTracker.Models;
using FinTracker.Services;
using FluentAssertions;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Moq;

namespace FinTracker.Tests.Controllers
{
    public class ReceiptsControllerTests
    {
        private readonly Mock<IReceiptService> _receiptServiceMock;
        private readonly Mock<IFileValidationService> _fileValidatorMock;

        private readonly ReceiptsController _controller;

        public ReceiptsControllerTests()
        {
            _receiptServiceMock = new Mock<IReceiptService>();
            _fileValidatorMock = new Mock<IFileValidationService>();

            _controller = new ReceiptsController(
                _receiptServiceMock.Object,
                _fileValidatorMock.Object
            );
        }

        [Fact]
        public async Task UploadReceipt_ShouldReturnBadRequest_WhenFileValidationFails()
        {
            var fileMock = new Mock<IFormFile>();

            _fileValidatorMock.Setup(x => x.ValidateImage(It.IsAny<IFormFile>()))
                .Returns((false, "Plik jest zły"));

            var result = await _controller.UploadReceipt(fileMock.Object, OcrEngineType.GoogleGeminiAI);

            result.Should().BeOfType<BadRequestObjectResult>()
                .Which.Value.Should().Be("Plik jest zły");
        }

        [Fact]
        public async Task UploadReceipt_ShouldReturnOk_WhenProcessIsSuccessful()
        {
            var fileMock = new Mock<IFormFile>();

            fileMock.Setup(x => x.Length).Returns(1024);

            _fileValidatorMock.Setup(x => x.ValidateImage(It.IsAny<IFormFile>()))
                .Returns((true, ""));

            var expectedDto = new ReceiptDTO
            {
                Id = 1,
                StoreName = "Biedronka",
                TotalAmount = 50.00m
            };

            _receiptServiceMock.Setup(x => x.CreateReceiptFromImageAsync(
                    It.IsAny<OcrEngineType>(),
                    It.IsAny<Stream>(),
                    It.IsAny<string?>()))
                .ReturnsAsync(expectedDto);

            var result = await _controller.UploadReceipt(fileMock.Object, OcrEngineType.GoogleGeminiAI);

            if (result is BadRequestObjectResult badRequest)
            {
                throw new Exception($"Controller returned BadRequest: {badRequest.Value}");
            }

            var okResult = result.Should().BeOfType<OkObjectResult>().Subject;
            var returnedReceipt = okResult.Value.Should().BeOfType<ReceiptDTO>().Subject;

            returnedReceipt.StoreName.Should().Be("Biedronka");
        }

        [Fact]
        public async Task GetReceiptById_ShouldReturnOk_WhenReceiptExists()
        {
            int receiptId = 1;
            var dto = new ReceiptDTO { Id = receiptId, StoreName = "Test Store" };

            _receiptServiceMock.Setup(x => x.GetByIdAsync(receiptId))
                .ReturnsAsync(dto);

            var result = await _controller.GetReceiptById(receiptId);

            var okResult = result.Should().BeOfType<OkObjectResult>().Subject;
            var returnedDto = okResult.Value.Should().BeOfType<ReceiptDTO>().Subject;
            returnedDto.Id.Should().Be(receiptId);
        }

        [Fact]
        public async Task GetReceiptById_ShouldReturnNotFound_WhenReceiptDoesNotExist()
        {
            _receiptServiceMock.Setup(x => x.GetByIdAsync(It.IsAny<int>()))
                .ReturnsAsync((ReceiptDTO?)null);

            var result = await _controller.GetReceiptById(999);

            result.Should().BeOfType<NotFoundResult>();
        }

        [Fact]
        public async Task DeleteReceipt_ShouldReturnNoContent_WhenDeletionSuccessful()
        {
            int receiptId = 1;
            _receiptServiceMock.Setup(x => x.DeleteAsync(receiptId)).ReturnsAsync(true);

            var result = await _controller.DeleteReceipt(receiptId);

            result.Should().BeOfType<NoContentResult>();
        }

        [Fact]
        public async Task DeleteReceipt_ShouldReturnNotFound_WhenDeletionFails()
        {
            int receiptId = 999;
            _receiptServiceMock.Setup(x => x.DeleteAsync(receiptId)).ReturnsAsync(false);

            var result = await _controller.DeleteReceipt(receiptId);

            result.Should().BeOfType<NotFoundResult>();
        }
    }
}