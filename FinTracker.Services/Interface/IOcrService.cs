namespace FinTracker.Services
{
    public interface IOcrService
    {
        Task<string> RecognizeTextAsync(Stream imageStream);
    }
}
