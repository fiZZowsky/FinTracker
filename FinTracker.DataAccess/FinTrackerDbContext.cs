using FinTracker.Models;
using Microsoft.EntityFrameworkCore;

namespace FinTracker.DataAccess
{
    public class FinTrackerDbContext : DbContext
    {
        public FinTrackerDbContext(DbContextOptions<FinTrackerDbContext> options) : base(options)
        {
        }

        public DbSet<Receipt> Receipts { get; set; }
    }
}
