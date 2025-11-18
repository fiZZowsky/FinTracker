using FinTracker.API.Extensions;
using FinTracker.Models;
using FinTracker.Services;
using Microsoft.AspNetCore.Mvc;

namespace FinTracker.API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class StoreController : ControllerBase
    {
        private readonly IStoreService _storeService;

        public StoreController(IStoreService storeService)
        {
            _storeService = storeService;
        }

        [HttpGet]
        public async Task<IActionResult> GetStores()
        {
            var stores = await _storeService.GetAllAsync();
            return Ok(stores);
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetStore(int id)
        {
            var store = await _storeService.GetByIdAsync(id);
            if (store == null)
            {
                return NotFound();
            }
            return Ok(store);
        }

        [HttpPost]
        public async Task<IActionResult> CreateStore([FromForm] CreateStoreDTO form)
        {
            byte[] logoBytes;
            using (var memoryStream = new MemoryStream())
            {
                await form.Logo.CopyToAsync(memoryStream);
                logoBytes = memoryStream.ToArray();
            }
            var createdStore = await _storeService.CreateAsync(new StoreDTO { Id = 0, Name = form.Name, Logo = logoBytes });
            return CreatedAtAction(nameof(GetStore), new { id = createdStore.Id }, createdStore);
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateStore(int id, [FromForm] CreateStoreDTO form)
        {
            byte[] logoBytes;
            using (var memoryStream = new MemoryStream())
            {
                await form.Logo.CopyToAsync(memoryStream);
                logoBytes = memoryStream.ToArray();
            }

            var result = await _storeService.UpdateAsync(id, new StoreDTO(){ Id = id, Name = form.Name, Logo = logoBytes });
            if (!result)
            {
                return NotFound();
            }

            return NoContent();
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteStore(int id)
        {
            var result = await _storeService.DeleteAsync(id);
            if(!result)
            {
                return NotFound();
            }

            return NoContent();
        }
    }
}
