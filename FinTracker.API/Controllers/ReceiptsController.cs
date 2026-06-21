using FinTracker.Models;
using FinTracker.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace FinTracker.API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class ReceiptsController : ControllerBase
    {
        private readonly IReceiptService _receiptService;
        private readonly IFileValidationService _fileValidator;

        public ReceiptsController(IReceiptService receiptService, IFileValidationService fileValidator)
        {
            _receiptService = receiptService;
            _fileValidator = fileValidator;
        }

        [HttpGet]
        public async Task<IActionResult> GetReceipts([FromQuery] ReceiptQueryParameters query)
        {
            var receipts = await _receiptService.GetPagedAsync(query);
            return Ok(receipts);
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetReceiptById(int id, [FromQuery] string? currencyCode)
        {
            var receipt = await _receiptService.GetByIdAsync(id, currencyCode);
            if (receipt == null) return NotFound();
            return Ok(receipt);
        }

        [HttpGet("summary")]
        public async Task<IActionResult> GetSummary([FromQuery] ReceiptQueryParameters query)
        {
            var summaryData = await _receiptService.GetSummaryAsync(query);
            return Ok(summaryData);
        }

        [HttpGet("suggest-category")]
        public async Task<IActionResult> GetSuggestedCategory([FromQuery] string storeName)
        {
            var categoryId = await _receiptService.PredictCategoryAsync(storeName);
            if (categoryId == null) return NoContent();
            return Ok(categoryId);
        }

        [HttpPost]
        public async Task<IActionResult> CreateReceipt([FromBody] ReceiptDTO receiptDto)
        {
            if (receiptDto == null) return BadRequest();

            var createdReceipt = await _receiptService.CreateAsync(receiptDto);
            return CreatedAtAction(nameof(GetReceiptById), new { id = createdReceipt.Id }, createdReceipt);
        }

        [HttpPost("Upload")]
        public async Task<IActionResult> UploadReceipt(IFormFile file, [FromQuery] string? targetCurrency = null, [FromQuery] OcrEngineType ocrEngine = OcrEngineType.TesseractOCR, [FromForm] string? extractedText = null)
        {
            var validationResult = _fileValidator.ValidateImage(file);
            if (!validationResult.IsValid)
            {
                return BadRequest(validationResult.ErrorMessage);
            }

            if (file == null || file.Length == 0) return BadRequest("Nie przesłano pliku.");

            using var stream = file.OpenReadStream();
            var createdReceipt = await _receiptService.CreateReceiptFromImageAsync(ocrEngine, stream, extractedText, targetCurrency);
            return Ok(createdReceipt);
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateReceipt(int id, [FromBody] ReceiptDTO receiptDto)
        {
            if (receiptDto == null) return BadRequest();

            var result = await _receiptService.UpdateAsync(id, receiptDto);
            if (!result) return NotFound();

            return NoContent();
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteReceipt(int id)
        {
            var result = await _receiptService.DeleteAsync(id);
            if (!result) return NotFound();

            return NoContent();
        }
    }
}