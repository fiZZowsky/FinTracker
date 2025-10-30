// using Azure;
// using Azure.AI.Vision.ImageAnalysis;
// using System.Text;

// namespace FinTracker.Services
// {
//     public class AzureVisionOcrService : IOcrService
//     {
//         private readonly ImageAnalysisClient _client;

//         public AzureVisionOcrService(IConfiguration configuration)
//         {
//             string endpoint = configuration["AzureVision:Endpoint"]!;
//             string key = configuration["AzureVision:Key"]!;
//             _client = new ImageAnalysisClient(new Uri(endpoint), new AzureKeyCredential(key));
//         }

//         public async Task<string> RecognizeTextAsync(Stream imageStream)
//         {
//             using (var memoryStream = new MemoryStream())
//             {
//                 await imageStream.CopyToAsync(memoryStream);
//                 memoryStream.Position = 0; // Zresetuj strumień

//                 ImageAnalysisResult result = await _client.AnalyzeAsync(
//                     BinaryData.FromStream(memoryStream),
//                     VisualFeatures.Read);

//                 if (result.Read == null)
//                 {
//                     return string.Empty;
//                 }

//                 StringBuilder sb = new StringBuilder();
//                 foreach (var line in result.Read.Blocks.SelectMany(b => b.Lines))
//                 {
//                     sb.AppendLine(line.Text);
//                 }
//                 return sb.ToString();
//             }
//         }
//     }
// }