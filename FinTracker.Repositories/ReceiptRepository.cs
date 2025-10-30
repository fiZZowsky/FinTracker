using FinTracker.DataAccess;
using FinTracker.Models;

namespace FinTracker.Repositories
{
    public class ReceiptRepository : BaseRepository<Receipt, int>, IReceiptRepository
    {
        public ReceiptRepository(FinTrackerDbContext context) : base(context)
        {
        }
    }
}
