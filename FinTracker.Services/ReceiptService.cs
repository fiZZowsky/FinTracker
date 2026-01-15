using AutoMapper;
using FinTracker.Models;
using FinTracker.Repositories;
using System.Globalization;
using System.Text;
using System.Text.RegularExpressions;

namespace FinTracker.Services
{
    public class ReceiptService : BaseService<Receipt, ReceiptDTO, int>, IReceiptService
    {
        private readonly IReceiptRepository _receiptRepository;
        private readonly IOcrService _ocrService;
        private readonly IStoreRepository _storeRepository;
        private readonly IAzureOcrService _azureOcrService;
        private readonly IUserContextRepository _userContextRepository;

        public ReceiptService(
            IReceiptRepository repository,
            IOcrService ocrService,
            IStoreRepository storeRepository,
            IAzureOcrService azureOcrService,
            IUserContextRepository userContextRepository,
            IMapper mapper)
            : base(repository, mapper)
        {
            _receiptRepository = repository;
            _ocrService = ocrService;
            _storeRepository = storeRepository;
            _azureOcrService = azureOcrService;
            _userContextRepository = userContextRepository;
        }

        public override async Task<ReceiptDTO> GetByIdAsync(int id)
        {
            var receiptDto = await base.GetByIdAsync(id);
            if (receiptDto == null) return null;

            receiptDto.StoreLogo = await _GetLogoBytesForStore(receiptDto.StoreName);
            return receiptDto;
        }

        public override async Task<ReceiptDTO> CreateAsync(ReceiptDTO dto)
        {
            var userId = _userContextRepository.GetUserId();
            if (userId == null) throw new UnauthorizedAccessException("Nie można zidentyfikować użytkownika.");

            var entity = _mapper.Map<Receipt>(dto);
            entity.UserId = userId.Value;

            var createdEntity = await _receiptRepository.CreateAsync(entity);
            return _mapper.Map<ReceiptDTO>(createdEntity);
        }

        public override async Task<bool> UpdateAsync(int id, ReceiptDTO dto)
        {
            var existingEntity = await _receiptRepository.GetByIdAsync(id);
            if (existingEntity == null) return false;

            _mapper.Map(dto, existingEntity);
            await _receiptRepository.UpdateAsync(existingEntity);
            return true;
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

        public async Task<ReceiptDTO> CreateReceiptFromImageAsync(Stream imageStream, bool useAzure)
        {
            string ocrText = useAzure
                ? await _azureOcrService.RecognizeTextAsync(imageStream)
                : await _ocrService.RecognizeTextAsync(imageStream);

            return await _ParseTextToReceipt(ocrText);
        }

        private async Task<ReceiptDTO> _ParseTextToReceipt(string ocrText)
        {
            decimal totalAmount = 0.0m;
            DateTime dateShopping = DateTime.UtcNow;
            string storeName = await _ParseStoreName(ocrText);

            string amountPattern = @"(SUMA|S[U0O]M[A4]|RAZEM|KWOTA|DO\s*ZAP[LŁ1I]ATY|WARTOŚĆ)\s*[\s:.;]*\s*(PLN|Z[LŁ1I]|P1N)?\s*([0-9OoSsDd]{1,}[\s.,]+[0-9OoSs]{2})\b";
            var matches = Regex.Matches(ocrText, amountPattern, RegexOptions.IgnoreCase | RegexOptions.Multiline);

            if (matches.Count > 0)
            {
                string cleanAmount = CleanOcrNumber(matches[^1].Groups[3].Value);
                decimal.TryParse(cleanAmount, NumberStyles.Any, CultureInfo.InvariantCulture, out totalAmount);
            }

            var dateMatch = Regex.Match(ocrText, @"(\d{4}-\d{2}-\d{2})|(\d{2}[.-]\d{2}[.-]\d{4})");
            if (dateMatch.Success)
            {
                if (!DateTime.TryParse(dateMatch.Value, CultureInfo.GetCultureInfo("pl-PL"), DateTimeStyles.None, out dateShopping))
                    DateTime.TryParse(dateMatch.Value, CultureInfo.InvariantCulture, DateTimeStyles.None, out dateShopping);
            }

            return new ReceiptDTO { StoreName = storeName, TotalAmount = totalAmount, DateShopping = dateShopping };
        }

        private string CleanOcrNumber(string input)
        {
            if (string.IsNullOrEmpty(input)) return "0";
            return input.ToUpper().Replace(" ", "").Replace(",", ".").Replace("S", "5").Replace("O", "0").Replace("D", "0").Replace("Q", "0").Replace("B", "8").Replace("I", "1").Replace("L", "1");
        }

        private async Task<string> _ParseStoreName(string ocrText)
        {
            var stores = await _storeRepository.GetAllStoresName();
            string normalizedOcrText = _RemoveDiacritics(ocrText.ToUpper()).Replace(" ", "");

            foreach (var store in stores)
            {
                string normalizedStore = _RemoveDiacritics(store.ToUpper());
                if (normalizedStore.Length < 4) continue;
                for (int i = 0; i <= normalizedOcrText.Length - normalizedStore.Length; i++)
                {
                    if (_LevenshteinDistance(normalizedOcrText.Substring(i, normalizedStore.Length), normalizedStore) <= 1)
                        return store;
                }
            }
            return "Nieznany Sklep";
        }

        private int _LevenshteinDistance(string s, string t)
        {
            int n = s.Length, m = t.Length;
            int[,] d = new int[n + 1, m + 1];
            if (n == 0) return m; if (m == 0) return n;
            for (int i = 0; i <= n; i++) d[i, 0] = i;
            for (int j = 0; j <= m; j++) d[0, j] = j;
            for (int i = 1; i <= n; i++)
                for (int j = 1; j <= m; j++)
                    d[i, j] = Math.Min(Math.Min(d[i - 1, j] + 1, d[i, j - 1] + 1), d[i - 1, j - 1] + (t[j - 1] == s[i - 1] ? 0 : 1));
            return d[n, m];
        }

        private string _RemoveDiacritics(string text)
        {
            var normalizedString = text.Normalize(NormalizationForm.FormD);
            var stringBuilder = new StringBuilder();
            foreach (var c in normalizedString)
                if (CharUnicodeInfo.GetUnicodeCategory(c) != UnicodeCategory.NonSpacingMark) stringBuilder.Append(c);
            return stringBuilder.ToString().Normalize(NormalizationForm.FormC).Replace("ł", "l"); // Uproszczone
        }

        private async Task<byte[]?> _GetLogoBytesForStore(string storeName)
        {
            var stores = await _storeRepository.GetAllAsync();
            var store = stores.FirstOrDefault(s => s.Name.Equals(storeName, StringComparison.CurrentCultureIgnoreCase));
            if (store == null || string.IsNullOrEmpty(store.LogoUrl)) return null;
            return await _ReadFileBytes(Path.GetFileName(store.LogoUrl));
        }

        private async Task<byte[]?> _ReadFileBytes(string fileName)
        {
            try
            {
                string path = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "Logos", fileName);
                if (File.Exists(path)) return await File.ReadAllBytesAsync(path);
            }
            catch (Exception) {}
            return null;
        }

        public async Task<int?> GetSuggestedCategoryForStoreAsync(string storeName)
        {
            return await _receiptRepository.GetMostFrequentCategoryIdAsync(storeName);
        }
    }
}