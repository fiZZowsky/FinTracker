using AutoMapper;
using FinTracker.Models;
using FinTracker.Repositories;
using Microsoft.Extensions.Logging;

namespace FinTracker.Services
{
    public class ReceiptService : BaseService<Receipt, ReceiptDTO, int>, IReceiptService
    {
        private readonly IReceiptRepository _receiptRepository;
        private readonly IStoreRepository _storeRepository;
        private readonly IUserContextRepository _userContextRepository;
        private readonly IReceiptParserService _receiptParserService;
        private readonly IOcrServiceFactory _ocrFactory;
        private readonly IExchangeRateService _exchangeRateService;
        private readonly ILogger<ReceiptService> _logger;

        public ReceiptService(
            IReceiptRepository repository,
            IStoreRepository storeRepository,
            IUserContextRepository userContextRepository,
            IReceiptParserService receiptParserService,
            IOcrServiceFactory ocrFactory,
            IMapper mapper,
            IExchangeRateService exchangeRateService,
            ILogger<ReceiptService> logger)
            : base(repository, mapper)
        {
            _receiptRepository = repository;
            _storeRepository = storeRepository;
            _userContextRepository = userContextRepository;
            _receiptParserService = receiptParserService;
            _ocrFactory = ocrFactory;
            _exchangeRateService = exchangeRateService;
            _logger = logger;
        }

        public async Task<ReceiptDTO> CreateReceiptFromImageAsync(OcrEngineType ocrEngine, Stream imageStream, string? extractedText, string? targetCurrency = null)
        {
            _logger.LogInformation("Rozpoczynanie ekstrakcji danych przy użyciu modelu: {EngineType}", ocrEngine.ToString());
            extractedText ??= await _ocrFactory.GetOcrService(ocrEngine).RecognizeTextAsync(imageStream);
            _logger.LogInformation("OCR Raw Response: {rawText}", extractedText);

            var receiptDto = await _receiptParserService.ParseReceiptTextAsync(extractedText);

            receiptDto.OriginalAmount = receiptDto.TotalAmount;
            receiptDto.OriginalCurrencyCode = receiptDto.CurrencyCode;

            var currency = targetCurrency?.ToUpper() ?? "PLN";
            if (receiptDto.CurrencyCode.ToUpper() != currency)
            {
                decimal targetRate = 1.0m;
                if (currency != "PLN")
                {
                    targetRate = await _exchangeRateService.GetRateAsync(currency, receiptDto.DateShopping);
                }

                receiptDto.TotalAmount = (receiptDto.TotalAmount * receiptDto.ExchangeRate) / targetRate;
                receiptDto.CurrencyCode = currency;
            }

            return receiptDto;
        }

        public async Task<ReceiptDTO> GetByIdAsync(int id, string? targetCurrency = null)
        {
            var receiptDto = await base.GetByIdAsync(id);
            if (receiptDto == null) return null;

            receiptDto.StoreLogo = await _GetLogoBytesForStore(receiptDto.StoreName);

            var currency = targetCurrency?.ToUpper() ?? "PLN";
            if (receiptDto.CurrencyCode.ToUpper() != currency)
            {
                decimal targetRate = 1.0m;
                if (currency != "PLN")
                {
                    targetRate = await _exchangeRateService.GetRateAsync(currency, receiptDto.DateShopping);
                }

                receiptDto.TotalAmount = (receiptDto.TotalAmount * receiptDto.ExchangeRate) / targetRate;
                receiptDto.CurrencyCode = currency;
            }

            return receiptDto;
        }

        public override async Task<ReceiptDTO> CreateAsync(ReceiptDTO dto)
        {
            if (dto.OriginalAmount.HasValue && !string.IsNullOrWhiteSpace(dto.OriginalCurrencyCode))
            {
                dto.TotalAmount = dto.OriginalAmount.Value;
                dto.CurrencyCode = dto.OriginalCurrencyCode;
            }

            var userId = _userContextRepository.GetUserId();
            if (userId == null) throw new UnauthorizedAccessException("Nie można zidentyfikować użytkownika.");

            var entity = _mapper.Map<Receipt>(dto);
            entity.UserId = userId.Value;
            entity.ExchangeRate = await _exchangeRateService.GetRateAsync(entity.CurrencyCode, entity.DateShopping);

            var createdEntity = await _receiptRepository.CreateAsync(entity);
            return _mapper.Map<ReceiptDTO>(createdEntity);
        }

        public override async Task<bool> UpdateAsync(int id, ReceiptDTO dto)
        {
            var existingEntity = await _receiptRepository.GetByIdAsync(id);
            if (existingEntity == null) return false;

            bool currencyChanged = existingEntity.CurrencyCode != dto.CurrencyCode;
            bool dateChanged = existingEntity.DateShopping.Date != dto.DateShopping.Date;

            _mapper.Map(dto, existingEntity);

            if (currencyChanged || dateChanged)
            {
                existingEntity.ExchangeRate = await _exchangeRateService.GetRateAsync(
                    existingEntity.CurrencyCode,
                    existingEntity.DateShopping
                );
            }

            await _receiptRepository.UpdateAsync(existingEntity);
            return true;
        }

        public async Task<IEnumerable<ReceiptDTO>> GetPagedAsync(ReceiptQueryParameters query)
        {
            var entities = await _receiptRepository.GetPagedAsync(query);
            var dtos = _mapper.Map<IEnumerable<ReceiptDTO>>(entities);
            var targetCurrency = query.CurrencyCode?.ToUpper() ?? "PLN";

            foreach (var dto in dtos)
            {
                var targetRate = await _exchangeRateService.GetRateAsync(targetCurrency, dto.DateShopping);
                dto.TotalAmount = (dto.TotalAmount * dto.ExchangeRate) / targetRate;
                dto.CurrencyCode = targetCurrency;
            }

            return dtos;
        }

        public async Task<IEnumerable<SummaryDataDTO>> GetSummaryAsync(ReceiptQueryParameters query)
        {
            var receipts = await _receiptRepository.GetReceiptsByQueryAsync(query);
            var targetCurrency = query.CurrencyCode?.ToUpper() ?? "PLN";
            var processedReceipts = new List<Receipt>();
            var localRequestCache = new Dictionary<string, decimal>();

            foreach (var r in receipts)
            {
                decimal targetRate = 1.0m;
                if (targetCurrency != "PLN")
                {
                    string cacheKey = $"{targetCurrency}_{r.DateShopping:yyyy-MM-dd}";
                    if (!localRequestCache.ContainsKey(cacheKey))
                    {
                        localRequestCache[cacheKey] = await _exchangeRateService.GetRateAsync(targetCurrency, r.DateShopping);
                    }
                    targetRate = localRequestCache[cacheKey];
                }

                decimal valueInTargetCurrency = (r.TotalAmount * r.ExchangeRate) / targetRate;

                processedReceipts.Add(new Receipt
                {
                    DateShopping = r.DateShopping,
                    TotalAmount = valueInTargetCurrency
                });
            }

            var filterType = query.FilterType?.ToLower() ?? "month";
            if (string.IsNullOrEmpty(query.FilterType) && (query.StartDate.HasValue || query.EndDate.HasValue))
                filterType = "month";

            switch (filterType)
            {
                case "week":
                    return processedReceipts
                        .GroupBy(r => r.DateShopping.DayOfWeek)
                        .Select(g => new SummaryDataDTO { Label = (g.Key == DayOfWeek.Sunday ? 7 : (int)g.Key).ToString(), Total = g.Sum(r => r.TotalAmount) })
                        .OrderBy(x => int.Parse(x.Label)).ToList();
                case "sixmonths":
                case "year":
                    return processedReceipts
                        .GroupBy(r => new { r.DateShopping.Year, r.DateShopping.Month })
                        .Select(g => new SummaryDataDTO { Label = $"{g.Key.Year}-{g.Key.Month:D2}", Total = g.Sum(r => r.TotalAmount) })
                        .OrderBy(s => s.Label).ToList();
                case "all":
                case "month":
                default:
                    return processedReceipts
                        .GroupBy(r => r.DateShopping.Day)
                        .OrderBy(g => g.Key)
                        .Select(g => new SummaryDataDTO { Label = g.Key.ToString(), Total = g.Sum(r => r.TotalAmount) })
                        .ToList();
            }
        }

        public async Task<int?> PredictCategoryAsync(string rawStoreName)
        {
            return await _receiptParserService.PredictCategoryAsync(rawStoreName);
        }

        private async Task<byte[]?> _GetLogoBytesForStore(string storeName)
        {
            var stores = await _storeRepository.GetAllAsync();
            var store = stores.FirstOrDefault(s => s.Name.Equals(storeName, StringComparison.CurrentCultureIgnoreCase));
            if (store == null || string.IsNullOrEmpty(store.LogoUrl)) return null;

            string filename = Path.GetFileName(store.LogoUrl);
            return await _ReadFileBytes(filename);
        }

        private async Task<byte[]?> _ReadFileBytes(string fileName)
        {
            try
            {
                string basePath = AppDomain.CurrentDomain.BaseDirectory;
                string filePath = Path.Combine(basePath, "Logos", fileName);
                if (File.Exists(filePath)) return await File.ReadAllBytesAsync(filePath);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[ReceiptService] Błąd odczytu logo: {ex.Message}");
            }
            return null;
        }
    }
}