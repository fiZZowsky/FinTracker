using FinTracker.Models;
using FinTracker.Services;
using Microsoft.AspNetCore.Mvc;

namespace FinTracker.API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class ReceiptsController : ControllerBase
    {
        private readonly IReceiptService _receiptService;
        
        public ReceiptsController(IReceiptService receiptService)
        {
            _receiptService = receiptService;
        }

        [HttpGet]
        public async Task<IActionResult> GetReceipts([FromQuery] ReceiptQueryParameters query)
        {
            var receipts = await _receiptService.GetAllAsync();
            return Ok(receipts);
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetReceiptById(int id)
        {
            var receipt = await _receiptService.GetByIdAsync(id);
            if (receipt == null)
            {
                return NotFound();
            }
            return Ok(receipt);
        }

        [HttpGet("summary")]
        public async Task<IActionResult> GetSummary(
            [FromQuery] ReceiptQueryParameters query)
        {
            var summaryData = await _receiptService.GetSummaryAsync(query);
            return Ok(summaryData);
        }
        
        [HttpPost]
        public async Task<IActionResult> CreateReceipt([FromBody] ReceiptDTO receiptDto)
        {
            if (receiptDto == null)
            {
                return BadRequest();
            }
            
            var createdReceipt = await _receiptService.CreateAsync(receiptDto);
            
            return CreatedAtAction(nameof(GetReceiptById), new { id = createdReceipt.Id }, createdReceipt);
        }

        [HttpPost("Upload")]
        public async Task<IActionResult> UploadReceipt(IFormFile file)
        {
            if (file == null || file.Length == 0)
            {
                return BadRequest("Nie przesłano pliku.");
            }
            
            using (var stream = file.OpenReadStream())
            {
                try
                {
                    var createdReceipt = await _receiptService.CreateReceiptFromImageAsync(stream);
                    return Ok(createdReceipt);
                }
                catch (Exception ex)
                {
                    return StatusCode(500, $"Wystąpił błąd serwera: {ex.Message}");
                }
            }
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateReceipt(int id, [FromBody] ReceiptDTO receiptDto)
        {
            if (receiptDto == null)
            {
                return BadRequest();
            }

            var result = await _receiptService.UpdateAsync(id, receiptDto);
            if (!result)
            {
                return NotFound();
            }

            return NoContent();
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteReceipt(int id)
        {
            var result = await _receiptService.DeleteAsync(id);
            if (!result)
            {
                return NotFound();
            }

            return NoContent();
        }
    }
}