using FinTracker.API.Extensions;
using FinTracker.Models;
using FinTracker.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace FinTracker.API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
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

        [HttpPost("user")]
        public async Task<IActionResult> CreateUserStore([FromBody] CreateUserStoreDTO dto)
        {
            if (dto == null) return BadRequest();

            var storeDto = new StoreDTO { Name = dto.Name, Logo = null };
            var createdStore = await _storeService.CreateAsync(storeDto);

            return Ok(createdStore);
        }

        [HttpPut("user/{id}")]
        public async Task<IActionResult> UpdateUserStore(int id, [FromBody] CreateUserStoreDTO dto)
        {
            if (dto == null) return BadRequest();

            var result = await _storeService.UpdateAsync(id, new StoreDTO { Id = id, Name = dto.Name });
            if (!result) return NotFound("Nie znaleziono sklepu lub jest systemowy.");

            return NoContent();
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteStore(int id)
        {
            var result = await _storeService.DeleteAsync(id);
            if (!result) return NotFound("Nie znaleziono sklepu lub jest systemowy.");

            return NoContent();
        }
    }
}