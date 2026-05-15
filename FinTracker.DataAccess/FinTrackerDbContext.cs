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
        public DbSet<ExchangeRateCache> ExchangeRatesCache { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<Receipt>()
                .HasOne(r => r.User)
                .WithMany()
                .HasForeignKey(r => r.UserId)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<Receipt>()
                .Property(r => r.CurrencyCode)
                .HasMaxLength(3)
                .IsRequired();

            modelBuilder.Entity<Receipt>()
                .Property(r => r.ExchangeRate)
                .HasColumnType("decimal(18,4)");

            modelBuilder.Entity<ExchangeRateCache>()
                .Property(e => e.Rate)
                .HasColumnType("decimal(18,4)");

            modelBuilder.Entity<ExchangeRateCache>()
                .HasIndex(e => new { e.CurrencyCode, e.Date })
                .IsUnique();

            modelBuilder.Entity<Category>()
                .HasOne<User>()
                .WithMany()
                .HasForeignKey(c => c.UserId)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<Store>()
                .HasOne<User>()
                .WithMany()
                .HasForeignKey(s => s.UserId)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<Receipt>()
                .Property(r => r.TotalAmount)
                .HasColumnType("decimal(18,2)");
        }
    }
}
