using AutoMapper;
using FinTracker.Models;
using FinTracker.Repositories;

namespace FinTracker.Services
{
    public class ReceiptService : BaseService<Receipt, ReceiptDTO, int>, IReceiptService
    {
        private readonly IReceiptRepository _receiptRepository;
        private readonly IStoreRepository _storeRepository;
        private readonly IUserContextRepository _userContextRepository;
        private readonly IReceiptParserService _receiptParserService;
        private readonly IOcrServiceFactory _ocrFactory;

        public ReceiptService(
            IReceiptRepository repository,
            IStoreRepository storeRepository,
            IUserContextRepository userContextRepository,
            IReceiptParserService receiptParserService,
            IOcrServiceFactory ocrFactory,
            IMapper mapper)
            : base(repository, mapper)
        {
            _receiptRepository = repository;
            _storeRepository = storeRepository;
            _userContextRepository = userContextRepository;
            _receiptParserService = receiptParserService;
            _ocrFactory = ocrFactory;
        }

        public async Task<ReceiptDTO> CreateReceiptFromImageAsync(Stream imageStream, OcrEngineType ocrEngine)
        {
            var ocrService = _ocrFactory.GetOcrService(ocrEngine);
            var text = await ocrService.RecognizeTextAsync(imageStream);

            return await _receiptParserService.ParseReceiptTextAsync(text);
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

        public async Task<int?> GetSuggestedCategoryForStoreAsync(string storeName)
        {
            return await _receiptRepository.GetMostFrequentCategoryIdAsync(storeName);
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