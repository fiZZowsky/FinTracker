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
        public async Task<IActionResult> GetReceipts()
        {
            var receipts = await _receiptService.GetAllAsync();
            //var receipts = new List<ReceiptDTO>
            //{
            //    new ReceiptDTO { Id = 1, StoreName = "Test", TotalAmount = 150, DateShopping = DateTime.Now },
            //    new ReceiptDTO { Id = 2, StoreName = "Test2", TotalAmount = 12, DateShopping = DateTime.Now }
            //};
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
                    return CreatedAtAction(nameof(GetReceiptById), new { id = createdReceipt.Id }, createdReceipt);
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