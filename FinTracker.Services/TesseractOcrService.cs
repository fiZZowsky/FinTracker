using Microsoft.AspNetCore.Hosting;
using OpenCvSharp;
using TesseractOCR;
using TesseractOCR.Enums;

namespace FinTracker.Services
{
    public class TesseractOcrService : IOcrService, IDisposable
    {
        private readonly Engine _engine;

        public TesseractOcrService(IWebHostEnvironment env)
        {
            string rootPath = AppDomain.CurrentDomain.BaseDirectory;
            string tessdataBasePath = Path.Combine(rootPath, "tessdata");

            _engine = new Engine(tessdataBasePath, "pol", EngineMode.Default);
            _engine.DefaultPageSegMode = PageSegMode.Auto;

            string charWhitelist = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789ąćęłńóśźżĄĆĘŁŃÓŚŹŻ.,:/-%*() ";
            _engine.SetVariable("tessedit_char_whitelist", charWhitelist);
        }

        public async Task<string> RecognizeTextAsync(Stream imageStream)
        {
            try
            {
                using (var memoryStream = new MemoryStream())
                {
                    await imageStream.CopyToAsync(memoryStream);
                    memoryStream.Position = 0;

                    using (Mat srcImage = Mat.FromStream(memoryStream, ImreadModes.Color))
                    {
                        if (srcImage.Empty())
                            throw new Exception("Nie można załadować obrazu.");

                        var workingImage = new Mat();

                        if (srcImage.Width > srcImage.Height)
                        {
                            Cv2.Rotate(srcImage, workingImage, RotateFlags.Rotate90Clockwise);
                        }
                        else
                        {
                            workingImage = srcImage;
                        }

                        using (Mat grayImage = new Mat())
                        using (Mat blurredImage = new Mat())
                        using (Mat sharpenedImage = new Mat())
                        using (Mat processedImage = new Mat())
                        {
                            Cv2.CvtColor(workingImage, grayImage, ColorConversionCodes.BGR2GRAY);
                            Cv2.MedianBlur(grayImage, blurredImage, 3);

                            using (Mat gaussianBlur = new Mat())
                            {
                                double alpha = 2.2;
                                double beta = -1.2;
                                Cv2.GaussianBlur(blurredImage, gaussianBlur, new Size(0, 0), 3);
                                Cv2.AddWeighted(blurredImage, alpha, gaussianBlur, beta, 0, sharpenedImage);
                            }

                            Cv2.AdaptiveThreshold(blurredImage, processedImage, 255,
                                AdaptiveThresholdTypes.GaussianC,
                                ThresholdTypes.Binary, 31, 15);

                            string desktopPath = Environment.GetFolderPath(Environment.SpecialFolder.Desktop);
                            string fileName = "przerobione_zdjecie_opencv.png";
                            string fullPath = Path.Combine(desktopPath, fileName);
                            processedImage.SaveImage(fullPath);

                            using (var pngStream = processedImage.ToMemoryStream(".png"))
                            {
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