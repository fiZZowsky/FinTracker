using AutoMapper;
using FinTracker.Models;
using FinTracker.Repositories;
using System.Text.RegularExpressions;

namespace FinTracker.Services
{
    public class ReceiptService : BaseService<Receipt, ReceiptDTO, int>, IReceiptService
    {
        private readonly IOcrService _ocrService;

        public ReceiptService(IReceiptRepository repository, IOcrService ocrService, IMapper mapper)
            : base(repository, mapper)
        {
            _ocrService = ocrService;
        }

        public async Task<ReceiptDTO> CreateReceiptFromImageAsync(Stream imageStream)
        {
            string ocrText = await _ocrService.RecognizeTextAsync(imageStream);
            
            Receipt newReceipt = _ParseTextToReceipt(ocrText);
            
            var createdEntity = await _repository.CreateAsync(newReceipt);
            
            return _mapper.Map<ReceiptDTO>(createdEntity);
        }

        private Receipt _ParseTextToReceipt(string ocrText)
        {
            // TODO: Zaimplementuj logikę parsowania (np. używając Regex)
            // To jest bardzo uproszczony przykład.
            // W Twojej pracy magisterskiej będziesz analizować 'ocrText'
            // z obu silników, aby zobaczyć, który lepiej radzi sobie
            // z odnalezieniem np. "SUMA PLN" lub nazwy sklepu.

            string storeName = "Nieznany Sklep";
            decimal totalAmount = 0.0m;
            
            var match = Regex.Match(ocrText, @"(SUMA|RAZEM)\s*(\d+[,.]\d{2})");
            if (match.Success)
            {
                string amountStr = match.Groups[2].Value.Replace(',', '.');
                decimal.TryParse(amountStr, out totalAmount);
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
