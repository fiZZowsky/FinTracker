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
        public DbSet<Store> Stores { get; set; }
        public DbSet<Category> Categories { get; set; }
        public DbSet<User> Users { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<Receipt>()
                .HasOne(r => r.User)
                .WithMany()
                .HasForeignKey(r => r.UserId)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<Receipt>()
                .Property(r => r.TotalAmount)
                .HasColumnType("decimal(18,2)");
        }
    }
}
