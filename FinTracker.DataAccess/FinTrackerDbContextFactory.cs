using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Design;

namespace FinTracker.DataAccess
{
    public class FinTrackerDbContextFactory : IDesignTimeDbContextFactory<FinTrackerDbContext>
    {
        public FinTrackerDbContext CreateDbContext(string[] args)
        {
            var optionsBuilder = new DbContextOptionsBuilder<FinTrackerDbContext>();

            optionsBuilder.UseSqlServer("Server=tcp:mojserwer.database.windows.net,1433;Initial Catalog=FinTrackerDb;");

            return new FinTrackerDbContext(optionsBuilder.Options);
        }
    }
}