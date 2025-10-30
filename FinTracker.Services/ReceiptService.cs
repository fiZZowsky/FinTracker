using AutoMapper;
using FinTracker.Models;
using FinTracker.Repositories;

namespace FinTracker.Services
{
    public class ReceiptService : BaseService<Receipt, ReceiptDTO, int>, IReceiptService
    {
        public ReceiptService(IReceiptRepository repository, IMapper mapper)
            : base(repository, mapper)
        {
        }
    }
}
