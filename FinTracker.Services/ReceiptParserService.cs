using FinTracker.Models;
using FinTracker.Repositories;
using System.Globalization;
using System.Text;
using System.Text.RegularExpressions;

namespace FinTracker.Services
{
    public class ReceiptParserService : IReceiptParserService
    {
        private readonly IStoreRepository _storeRepository;

        public ReceiptParserService(IStoreRepository storeRepository)
        {
            _storeRepository = storeRepository;
        }

        public async Task<ReceiptDTO> ParseReceiptTextAsync(string ocrText)
        {
            decimal totalAmount = 0.0m;
            DateTime dateShopping = DateTime.UtcNow;

            string storeName = await _ParseStoreName(ocrText);

            string amountPattern = @"(SUMA|S[U0O]M[A4]|RAZEM|KWOTA|DO\s*ZAP[LŁ1I]ATY|WARTO[SŚ][CĆ]|BRUTTO)\s*[\s:.;]*\s*(PLN|Z[LŁ1I]|P1N)?\s*([0-9OoSsDdBQ]+(?:[\s][0-9OoSsDdBQ]+)*[.,][0-9OoSs]{2})\b";
            var matches = Regex.Matches(ocrText, amountPattern, RegexOptions.IgnoreCase | RegexOptions.Multiline);

            if (matches.Count > 0)
            {
                var lastMatch = matches[matches.Count - 1];
                string dirtyAmount = lastMatch.Groups[3].Value;
                string cleanAmount = CleanOcrNumber(dirtyAmount);
                decimal.TryParse(cleanAmount, NumberStyles.Any, CultureInfo.InvariantCulture, out totalAmount);
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

        private string CleanOcrNumber(string input)
        {
            if (string.IsNullOrEmpty(input)) return "0";

            return input
                .ToUpper()
                .Replace(" ", "")
                .Replace(",", ".")
                .Replace("S", "5")
                .Replace("O", "0")
                .Replace("D", "0")
                .Replace("Q", "0")
                .Replace("B", "8")
                .Replace("I", "1")
                .Replace("L", "1");
        }

        private async Task<string> _ParseStoreName(string ocrText)
        {
            var stores = await _storeRepository.GetAllStoresName();
            string normalizedOcrText = _RemoveDiacritics(ocrText.ToUpper()).Replace(" ", "");

            const int maxDistanceThreshold = 2;

            foreach (var store in stores)
            {
                string normalizedStore = _RemoveDiacritics(store.ToUpper());
                int storeLen = normalizedStore.Length;

                if (storeLen > normalizedOcrText.Length + maxDistanceThreshold) continue;
                if (storeLen < 3) continue;

                int minLen = Math.Max(1, storeLen - 1);
                int maxLen = storeLen + 1;

                for (int currLen = minLen; currLen <= maxLen; currLen++)
                {
                    if (currLen > normalizedOcrText.Length) break;

                    for (int i = 0; i <= normalizedOcrText.Length - currLen; i++)
                    {
                        string ocrSubstring = normalizedOcrText.Substring(i, currLen);
                        int distance = _LevenshteinDistance(ocrSubstring, normalizedStore);
                        int dynamicThreshold = storeLen <= 4 ? 1 : maxDistanceThreshold;

                        if (distance <= dynamicThreshold)
                        {
                            return store;
                        }
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
                .Replace("ą", "a").Replace("ć", "c").Replace("ę", "e")
                .Replace("ł", "l").Replace("ń", "n").Replace("ó", "o")
                .Replace("ś", "s").Replace("ź", "z").Replace("ż", "z");
        }
    }
}