using Microsoft.AspNetCore.Hosting;
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Processing;
using TesseractOCR;
using TesseractOCR.Enums;

namespace FinTracker.Services
{
    public class TesseractOcrService : IOcrService
    {
        private readonly string _tessdataBasePath;
        private readonly string _language;

        public TesseractOcrService(IWebHostEnvironment env)
        {
            string rootPath = env.ContentRootPath;
            _tessdataBasePath = Path.Combine(rootPath, "tessdata");
            _language = "pol";
        }

        public async Task<string> RecognizeTextAsync(Stream imageStream)
        {
            try
            {
                using (var memoryStream = new MemoryStream())
                {
                    await imageStream.CopyToAsync(memoryStream);
                    memoryStream.Position = 0;

                    using (var image = Image.Load(memoryStream))
                    {
                        image.Mutate(x => x.Grayscale());
                        
                        using (var pngStream = new MemoryStream())
                        {
                            image.SaveAsPng(pngStream);
                            
                            pngStream.Position = 0;
                            
                            using (var img = TesseractOCR.Pix.Image.LoadFromMemory(pngStream))
                            using (var engine = new Engine(_tessdataBasePath, _language, EngineMode.Default))
                            using (var page = engine.Process(img))
                            {
                                return page.Text;
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[OcrService Error] Błąd podczas przetwarzania OCR: {ex.Message}");
                throw;
            }
        }
    }
}
