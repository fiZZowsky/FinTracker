using Microsoft.AspNetCore.Hosting;
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Processing;
using TesseractOCR;
using TesseractOCR.Enums;

namespace FinTracker.Services
{
    public class TesseractOcrService : IOcrService, IDisposable
    {
        private readonly Engine _engine;

        public TesseractOcrService(IWebHostEnvironment env)
        {
            string rootPath = env.ContentRootPath;
            string tessdataBasePath = Path.Combine(rootPath, "tessdata");

            _engine = new Engine(tessdataBasePath, "pol", EngineMode.TesseractAndLstm);
            _engine.DefaultPageSegMode = PageSegMode.SingleColumn;
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
                        image.Mutate(ctx =>
                            {
                                if (image.Width > image.Height)
                                    ctx.Rotate(90);

                                ctx.Resize(new ResizeOptions
                                {
                                    Size = new Size(2000, 0),
                                    Mode = ResizeMode.Max,
                                    Sampler = KnownResamplers.Lanczos3
                                });
                                ctx.Grayscale();
                                ctx.Contrast(1.3f);
                                ctx.GaussianSharpen(0.7f);
                                ctx.BinaryThreshold(0.5f, SixLabors.ImageSharp.Processing.BinaryThresholdMode.Luminance);
                            }
                        );

                        string desktopPath = Environment.GetFolderPath(Environment.SpecialFolder.Desktop);
                        string fileName = "przerobione_zdjecie.png";
                        string fullPath = Path.Combine(desktopPath, fileName);
                        image.Save(fullPath);

                        using (var pngStream = new MemoryStream())
                        {
                            image.SaveAsPng(pngStream);

                            pngStream.Position = 0;
                            
                            using (var img = TesseractOCR.Pix.Image.LoadFromMemory(pngStream))
                            using (var page = _engine.Process(img))
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

        public void Dispose()
        {
            _engine?.Dispose();
        }
    }
}
