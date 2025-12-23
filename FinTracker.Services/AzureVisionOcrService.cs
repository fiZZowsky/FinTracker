using Microsoft.Azure.CognitiveServices.Vision.ComputerVision;
using Microsoft.Azure.CognitiveServices.Vision.ComputerVision.Models;
using Microsoft.Extensions.Configuration;
using System.Text;

namespace FinTracker.Services
{
    public class AzureVisionOcrService : IAzureOcrService
    {
        private readonly string _endpoint;
        private readonly string _key;

        public AzureVisionOcrService(IConfiguration configuration)
        {
            _endpoint = configuration["AzureComputerVision:Endpoint"];
            _key = configuration["AzureComputerVision:Key"];
        }

        public async Task<string> RecognizeTextAsync(Stream imageStream)
        {
            var client = Authenticate(_endpoint, _key);

            if (imageStream.Position != 0)
                imageStream.Position = 0;

            var textHeaders = await client.ReadInStreamAsync(imageStream);

            string operationLocation = textHeaders.OperationLocation;
            string operationId = operationLocation.Substring(operationLocation.Length - 36);

            ReadOperationResult results;
            do
            {
                await Task.Delay(500);
                results = await client.GetReadResultAsync(Guid.Parse(operationId));
            }
            while (results.Status == OperationStatusCodes.Running ||
                   results.Status == OperationStatusCodes.NotStarted);

            var sb = new StringBuilder();
            var textUrlFileResults = results.AnalyzeResult.ReadResults;

            foreach (var page in textUrlFileResults)
            {
                foreach (var line in page.Lines)
                {
                    sb.AppendLine(line.Text);
                }
            }

            return sb.ToString();
        }

        private ComputerVisionClient Authenticate(string endpoint, string key)
        {
            return new ComputerVisionClient(new ApiKeyServiceClientCredentials(key))
            {
                Endpoint = endpoint
            };
        }
    }
}