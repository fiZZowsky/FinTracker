namespace FinTracker.Services
{
    public interface IAzureOcrService
    {
        Task<string> RecognizeTextAsync(Stream imageStream);
    }
}
