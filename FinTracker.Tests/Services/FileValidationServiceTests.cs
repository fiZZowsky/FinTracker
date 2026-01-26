using FinTracker.Services;
using FluentAssertions;
using Microsoft.AspNetCore.Http;
using Moq;

namespace FinTracker.Tests.Services.Validation
{
    public class FileValidationServiceTests
    {
        private readonly FileValidationService _service;

        public FileValidationServiceTests()
        {
            _service = new FileValidationService();
        }

        [Fact]
        public void ValidateImage_ShouldReturnTrue_WhenFileIsValidJpg()
        {
            var fileMock = new Mock<IFormFile>();
            var content = new byte[] { 0xFF, 0xD8, 0xFF, 0xE0 };
            var ms = new MemoryStream(content);

            fileMock.Setup(_ => _.OpenReadStream()).Returns(ms);
            fileMock.Setup(_ => _.FileName).Returns("paragon.jpg");
            fileMock.Setup(_ => _.Length).Returns(content.Length);

            var (isValid, errorMessage) = _service.ValidateImage(fileMock.Object);

            isValid.Should().BeTrue();
            errorMessage.Should().BeEmpty();
        }

        [Fact]
        public void ValidateImage_ShouldReturnFalse_WhenFileIsFakeJpg_WithExeContent()
        {
            var fileMock = new Mock<IFormFile>();
            var content = new byte[] { 0x4D, 0x5A };
            var ms = new MemoryStream(content);

            fileMock.Setup(_ => _.OpenReadStream()).Returns(ms);
            fileMock.Setup(_ => _.FileName).Returns("virus.jpg");
            fileMock.Setup(_ => _.Length).Returns(content.Length);

            var (isValid, errorMessage) = _service.ValidateImage(fileMock.Object);

            isValid.Should().BeFalse();
            errorMessage.Should().Contain("fałszerstwa");
        }

        [Fact]
        public void ValidateImage_ShouldReturnFalse_WhenFileIsEmpty()
        {
            var fileMock = new Mock<IFormFile>();
            fileMock.Setup(_ => _.Length).Returns(0);

            var (isValid, errorMessage) = _service.ValidateImage(fileMock.Object);

            isValid.Should().BeFalse();
            errorMessage.Should().Contain("pusty");
        }
    }
}