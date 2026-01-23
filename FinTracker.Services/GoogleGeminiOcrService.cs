using System.Text;
using System.Text.Json;
using Microsoft.Extensions.Configuration;

namespace FinTracker.Services
{
    public class GoogleGeminiOcrService : IOcrService
    {
        private readonly string _apiKey;
        private readonly HttpClient _httpClient;
        private const string Model = "gemini-2.5-flash-lite";

        public GoogleGeminiOcrService(IConfiguration configuration)
        {
            _apiKey = configuration["Gemini:ApiKey"]
                      ?? throw new ArgumentNullException("Nie znaleziono klucza API Gemini w konfiguracji.");

            _httpClient = new HttpClient();
        }

        public async Task<string> RecognizeTextAsync(Stream imageStream)
        {
            try
            {
                byte[] imageBytes;
                using (var memoryStream = new MemoryStream())
                {
                    await imageStream.CopyToAsync(memoryStream);
                    imageBytes = memoryStream.ToArray();
                }
                string base64Image = Convert.ToBase64String(imageBytes);

                var requestBody = new
                {
                    contents = new[]
                    {
                        new
                        {
                            parts = new object[]
                            {
                                new { text = "Jesteś dokładnym silnikiem OCR który potrafi rozpoznawać tekst z polskich paragonów. Przepisz CAŁY tekst z tego paragonu, linia po linii. Nie pomijaj cen ani dat. Nie dodawaj żadnego formatowania markdown (pogrubień itp.), tylko czysty tekst." },
                                new
                                {
                                    inline_data = new
                                    {
                                        mime_type = "image/jpeg",
                                        data = base64Image
                                    }
                                }
                            }
                        }
                    }
                };

                var jsonContent = new StringContent(
                    JsonSerializer.Serialize(requestBody),
                    Encoding.UTF8,
                    "application/json");

                var url = $"https://generativelanguage.googleapis.com/v1beta/models/{Model}:generateContent?key={_apiKey}";

                var response = await _httpClient.PostAsync(url, jsonContent);
                var responseString = await response.Content.ReadAsStringAsync();

                if (!response.IsSuccessStatusCode)
                {
                    return $"Błąd API Google: {response.StatusCode} - {responseString}";
                }

                using var doc = JsonDocument.Parse(responseString);

                if (doc.RootElement.TryGetProperty("candidates", out var candidates) && candidates.GetArrayLength() > 0)
                {
                    var firstCandidate = candidates[0];
                    if (firstCandidate.TryGetProperty("content", out var content) &&
                        content.TryGetProperty("parts", out var parts) &&
                        parts.GetArrayLength() > 0)
                    {
                        var text = parts[0].GetProperty("text").GetString();
                        return text ?? "";
                    }
                }

                return "Gemini zwrócił odpowiedź, ale nie znaleziono tekstu.";
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Gemini Exception: {ex.Message}");
                return string.Empty;
            }
        }
    }
}