using FinTracker.Models;
using FinTracker.Services;
using Microsoft.AspNetCore.Mvc;

namespace FinTracker.API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class CategoriesController : ControllerBase
    {
        private readonly ICategoryService _categoryService;

        public CategoriesController(ICategoryService categoryService)
        {
            _categoryService = categoryService;
        }

        [HttpGet]
        public async Task<IActionResult> GetAll()
        {
            var categories = await _categoryService.GetAllAsync();
            return Ok(categories);
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetById(int id)
        {
            var category = await _categoryService.GetByIdAsync(id);
            if (category == null)
            {
                return NotFound();
            }
            return Ok(category);
        }

        [HttpPost]
        public async Task<IActionResult> Create([FromBody] CategoryDTO categoryDto)
        {
            if (categoryDto == null)
            {
                return BadRequest("Dane kategorii są nieprawidłowe.");
            }

            var created = await _categoryService.CreateAsync(categoryDto);

            return CreatedAtAction(nameof(GetById), new { id = created.Id }, created);
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateCategory(int id, [FromBody] CategoryDTO categoryDto)
        {
            if (categoryDto == null || id != categoryDto.Id)
            {
                return BadRequest("Niezgodność ID lub brak danych.");
            }

            var result = await _categoryService.UpdateAsync(id, categoryDto);

            if (!result)
            {
                return NotFound($"Nie znaleziono kategorii o ID: {id}");
            }

            return NoContent();
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteCategory(int id)
        {
            var result = await _categoryService.DeleteAsync(id);

            if (!result)
            {
                return NotFound($"Nie znaleziono kategorii o ID: {id}");
            }

            return NoContent();
        }
    }
}