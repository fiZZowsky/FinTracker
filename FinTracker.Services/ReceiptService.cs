using AutoMapper;
using FinTracker.Models;
using FinTracker.Repositories;
using System.Globalization;
using System.Text.RegularExpressions;
using System.Text;

namespace FinTracker.Services
{
    public class ReceiptService : BaseService<Receipt, ReceiptDTO, int>, IReceiptService
    {
        private readonly IReceiptRepository _receiptRepository;
        private readonly IOcrService _ocrService;

        public ReceiptService(IReceiptRepository repository, IOcrService ocrService, IMapper mapper)
            : base(repository, mapper)
        {
            _receiptRepository = repository;
            _ocrService = ocrService;
        }

        public async Task<IEnumerable<ReceiptDTO>> GetPagedAsync(ReceiptQueryParameters query)
        {
            var entities = await _receiptRepository.GetPagedAsync(query);
            
            return _mapper.Map<IEnumerable<ReceiptDTO>>(entities);
        }
        
        public async Task<IEnumerable<SummaryDataDTO>> GetSummaryAsync(ReceiptQueryParameters query)
        {
            return await _receiptRepository.GetSummaryAsync(query);
        }

        public async Task<ReceiptDTO> CreateReceiptFromImageAsync(Stream imageStream)
        {
            try
            {
                string ocrText = await _ocrService.RecognizeTextAsync(imageStream);

                ReceiptDTO newReceipt = _ParseTextToReceipt(ocrText);
                return newReceipt;
            }
            catch (Exception e)
            {
                Console.WriteLine(e);
                throw;
            }
        }

        private ReceiptDTO _ParseTextToReceipt(string ocrText)
        {
            decimal totalAmount = 0.0m;
            DateTime dateShopping = DateTime.UtcNow;

            string storeName = _ParseStoreName(ocrText);

            var totalMatch = Regex.Match(ocrText,
                @"(SUMA:|RAZEM:|SUMA PLN|KWOTA:|DO ZAPŁATY:)\s*(PLN)?\s*(\d+[\s,.]+(\d{2}|S{2}|O{2}))",
                RegexOptions.IgnoreCase | RegexOptions.Multiline);

            if (totalMatch.Success)
            {
                string amountStr = totalMatch.Groups[3].Value
                    .Replace(',', '.')
                    .Replace('S', '5')
                    .Replace('O', '0')
                    .Replace(" ", "");

                decimal.TryParse(amountStr,
                    NumberStyles.Any,
                    CultureInfo.InvariantCulture,
                    out totalAmount);
            }
            
            var dateMatch = Regex.Match(ocrText, @"(\d{4}-\d{2}-\d{2})|(\d{2}[.-]\d{2}[.-]\d{4})");

            if (dateMatch.Success)
            {
                string dateStr = dateMatch.Value;
                
                if (DateTime.TryParse(dateStr, CultureInfo.GetCultureInfo("pl-PL"), DateTimeStyles.None, out DateTime parsedDate))
                {
                    dateShopping = parsedDate;
                }
                else if (DateTime.TryParse(dateStr, CultureInfo.InvariantCulture, DateTimeStyles.None, out parsedDate))
                {
                    dateShopping = parsedDate;
                }
            }

            return new ReceiptDTO
            {
                StoreName = storeName,
                TotalAmount = totalAmount,
                DateShopping = dateShopping
            };
        }

        private string _ParseStoreName(string ocrText)
        {
            var knownStores = new List<string>
            {
                "SPOŁEM", "BIEDRONKA", "LIDL", "ŻABKA", "AUCHAN",
                "CARREFOUR", "KAUFLAND", "ROSSMANN", "HEBE", "NETTO",
                "ALDI", "STOKROTKA", "INTERMARCHE", "LEWIATAN", "ORLEN"
            };

            string normalizedOcrText = _RemoveDiacritics(ocrText.ToUpper()).Replace(" ", "");

            const int maxDistanceThreshold = 1;

            foreach (var store in knownStores)
            {
                string normalizedStore = _RemoveDiacritics(store.ToUpper());
                int storeLen = normalizedStore.Length;
                
                if (storeLen < 4) continue;
                
                for (int i = 0; i <= normalizedOcrText.Length - storeLen; i++)
                {
                    string ocrSubstring = normalizedOcrText.Substring(i, storeLen);
                    int distance = _LevenshteinDistance(ocrSubstring, normalizedStore);
                    if (distance <= maxDistanceThreshold)
                    {
                        return store;
                    }
                }
            }
            
            return "Nieznany Sklep";
        }

        private int _LevenshteinDistance(string s, string t)
        {
            int n = s.Length;
            int m = t.Length;
            int[,] d = new int[n + 1, m + 1];

            if (n == 0) return m;
            if (m == 0) return n;

            for (int i = 0; i <= n; d[i, 0] = i++) { }
            for (int j = 0; j <= m; d[0, j] = j++) { }

            for (int i = 1; i <= n; i++)
            {
                for (int j = 1; j <= m; j++)
                {
                    int cost = (t[j - 1] == s[i - 1]) ? 0 : 1;
                    d[i, j] = Math.Min(
                        Math.Min(d[i - 1, j] + 1, d[i, j - 1] + 1),
                        d[i - 1, j - 1] + cost);
                }
            }
            return d[n, m];
        }

        private string _RemoveDiacritics(string text)
        {
            var normalizedString = text.Normalize(NormalizationForm.FormD);
            var stringBuilder = new StringBuilder();

            foreach (var c in normalizedString)
            {
                var unicodeCategory = CharUnicodeInfo.GetUnicodeCategory(c);
                if (unicodeCategory != UnicodeCategory.NonSpacingMark)
                {
                    stringBuilder.Append(c);
                }
            }
            
            return stringBuilder.ToString()
                .Normalize(NormalizationForm.FormC)
                .Replace('Ł', 'L')
                .Replace('ł', 'l');
        }
    }
}
