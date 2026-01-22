namespace FinTracker.Services
{
    public class GoogleGeminiOcrService : IOcrService
    {
        public async Task<string> RecognizeTextAsync(Stream imageStream)
        {
            return "DEBUG: Odczytano przez Google Gemini AI (Symulacja)\nSKLEP\nSuma: 99.99 PLN";
        }
    }
}
