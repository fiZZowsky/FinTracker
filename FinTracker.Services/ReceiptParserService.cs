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
        private readonly IUserContextRepository _userContextRepository;
        private readonly IReceiptRepository _receiptRepository;
        private readonly IExchangeRateService _exchangeRateService;

        public ReceiptParserService(IStoreRepository storeRepository, IUserContextRepository userContextRepository, IReceiptRepository receiptRepository, IExchangeRateService exchangeRateService)
        {
            _storeRepository = storeRepository;
            _userContextRepository = userContextRepository;
            _receiptRepository = receiptRepository;
            _exchangeRateService = exchangeRateService;
        }

        public async Task<ReceiptDTO> ParseReceiptTextAsync(string ocrText)
        {
            decimal totalAmount = 0.0m;
            DateTime dateShopping = DateTime.UtcNow;
            string currencyCode = "PLN";

            string amountPattern = @"(SUMA|S[U0O]M[A4]|RAZEM|KWOTA|DO\s*ZAP[LŁ1I]ATY|WARTO[SŚ][CĆ]|BRUTTO|TOTAL|T[O0]TAL|AMOUNT|AM[O0]UNT|AMOUNT\s*DUE|BALANCE|DUE)"
                    + @"\s*[\s:.;]*\s*(PLN|Z[LŁ1I]|P1N|EUR|USD|€|\$)?\s*([0-9OoSsDdBQ]+(?:[\s][0-9OoSsDdBQ]+)*[.,][0-9OoSs]{2})\s*(PLN|Z[LŁ1I]|P1N|EUR|USD|€|\$)?(?!\w)";
            var matches = Regex.Matches(ocrText, amountPattern, RegexOptions.IgnoreCase | RegexOptions.Multiline);

            if (matches.Count > 0)
            {
                var lastMatch = matches[matches.Count - 1];

                string dirtyAmount = lastMatch.Groups[3].Value;
                string cleanAmount = CleanOcrNumber(dirtyAmount);
                decimal.TryParse(cleanAmount, NumberStyles.Any, CultureInfo.InvariantCulture, out totalAmount);

                for (int i = matches.Count - 1; i >= 0; i--)
                {
                    var match = matches[i];
                    string foundCurrency = match.Groups[2].Success ? match.Groups[2].Value :
                                          (match.Groups[4].Success ? match.Groups[4].Value : "");

                    if (!string.IsNullOrWhiteSpace(foundCurrency))
                    {
                        currencyCode = MapCurrencyToIsoCode(foundCurrency);
                        break;
                    }
                }
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

            var exchangeRate = await _exchangeRateService.GetRateAsync(currencyCode, dateShopping);

            string storeName = await _ParseStoreName(ocrText);

            var categoryId = await PredictCategoryAsync(storeName);

            return new ReceiptDTO
            {
                StoreName = storeName,
                TotalAmount = totalAmount,
                DateShopping = dateShopping,
                CategoryId = categoryId,
                CurrencyCode = currencyCode,
                ExchangeRate = exchangeRate
            };
        }

        private string MapCurrencyToIsoCode(string rawCurrency)
        {
            if (string.IsNullOrWhiteSpace(rawCurrency)) return "PLN";

            var c = rawCurrency.ToUpper().Trim();
            if (c.Contains("EUR") || c.Contains("€")) return "EUR";
            if (c.Contains("USD") || c.Contains("$")) return "USD";

            return "PLN"; 
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
            string normalizedOcrText = Regex.Replace(_RemoveDiacritics(ocrText.ToUpper()), @"\s+", "");

            const int maxDistanceThreshold = 2;
            string bestStore = "Nieznany Sklep";
            int bestDistance = int.MaxValue;
            int bestMatchIndex = int.MaxValue;

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
                            if (distance < bestDistance || (distance == bestDistance && i < bestMatchIndex))
                            {
                                bestDistance = distance;
                                bestMatchIndex = i;
                                bestStore = store;
                            }
                        }
                    }
                }
            }

            return bestStore;
        }

        public async Task<int?> PredictCategoryAsync(string rawStoreName)
        {
            var normalizedStoreName = NormalizeStoreName(rawStoreName);

            if (string.IsNullOrWhiteSpace(normalizedStoreName) || normalizedStoreName.Length < 3)
            {
                return null;
            }

            var userId = _userContextRepository.GetUserId();
            if (userId == null) throw new UnauthorizedAccessException("Brak użytkownika.");

            var userResult = await _receiptRepository.GetUserCategoryStatsAsync(normalizedStoreName, userId);
            var globalResult = await _receiptRepository.GetGlobalCategoryStatsAsync(normalizedStoreName, userId);

            if (userResult != null && globalResult == null) return userResult.Value.CategoryId;
            if (userResult == null && globalResult != null) return globalResult.Value.CategoryId;
            if (userResult == null && globalResult == null) return null;

            const int UserWeightMultiplier = 15;

            int userScore = userResult.Value.Count * UserWeightMultiplier;
            int globalScore = globalResult.Value.Count;

            if (userScore >= globalScore)
            {
                return userResult.Value.CategoryId;
            }
            else
            {
                return globalResult.Value.CategoryId;
            }
        }

        private string NormalizeStoreName(string input)
        {
            if (string.IsNullOrWhiteSpace(input)) return string.Empty;
            var normalized = input.ToLower();
            string[] suffixesToRemove = { "sp. z o.o.", "sp. z oo", "sp.j.", "s.a.", "sp. k." };
            foreach (var suffix in suffixesToRemove) normalized = normalized.Replace(suffix, "");
            normalized = Regex.Replace(normalized, @"[^a-zżółćęśąźń\s]", "");
            return Regex.Replace(normalized, @"\s+", " ").Trim();
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