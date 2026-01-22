namespace FinTracker.Services
{
    public class PaddleOcrService : IOcrService
    {
        public async Task<string> RecognizeTextAsync(Stream imageStream)
        {
            return "DEBUG: Odczytano przez PaddleOcr (Symulacja)\nSKLEP\nSuma: 150.00 PLN";
        }
    }
}
