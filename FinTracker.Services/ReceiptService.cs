using AutoMapper;
using FinTracker.Models;
using FinTracker.Repositories;
using System.Text.RegularExpressions;

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

                Receipt newReceipt = _ParseTextToReceipt(ocrText);

                //var createdEntity = await _repository.CreateAsync(newReceipt);
                return new ReceiptDTO();
                //return _mapper.Map<ReceiptDTO>(createdEntity);
            }
            catch (Exception e)
            {
                Console.WriteLine(e);
                throw;
            }
        }

        private Receipt _ParseTextToReceipt(string ocrText)
        {
            // TODO: Zaimplementuj logikę parsowania (np. używając Regex)

            string storeName = "Nieznany Sklep";
            decimal totalAmount = 0.0m;

            var match = Regex.Match(ocrText,
                @"(SUMA:|RAZEM:|KWOTA:|DO ZAPŁATY:)\s*(PLN)?\s*(\d+[\s,.]+(\d{2}|S{2}|O{2}))",
                RegexOptions.IgnoreCase);
            if (match.Success)
            {
                string amountStr = match.Groups[3].Value
                    .Replace(',', '.') 
                    .Replace('S', '5')
                    .Replace('O', '0')
                    .Replace(" ", "");
                
                decimal.TryParse(amountStr,
                    System.Globalization.NumberStyles.Any,
                    System.Globalization.CultureInfo.InvariantCulture,
                    out totalAmount);
            }

            return new Receipt
            {
                StoreName = storeName,
                TotalAmount = totalAmount,
                DateShopping = DateTime.UtcNow
            };
        }
    }
}
