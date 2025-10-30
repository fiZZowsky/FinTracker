using Tesseract;
using Microsoft.AspNetCore.Hosting;

namespace FinTracker.Services
{
    public class TesseractOcrService : IOcrService
    {
        private readonly string _tessDataPath;

        public TesseractOcrService(IWebHostEnvironment env)
        {
            string exePath = AppDomain.CurrentDomain.BaseDirectory;
            _tessDataPath = Path.Combine(exePath, "tessdata");
        }

        public async Task<string> RecognizeTextAsync(Stream imageStream)
        {
            using (var engine = new TesseractEngine(_tessDataPath, "pol", EngineMode.Default))
            {
                using (var memoryStream = new MemoryStream())
                {
                    await imageStream.CopyToAsync(memoryStream);
                    using (var img = Pix.LoadFromMemory(memoryStream.ToArray()))
                    {
                        using (var page = engine.Process(img))
                        {
                            return page.GetText();
                        }
                    }
                }
            }
        }
    }
}