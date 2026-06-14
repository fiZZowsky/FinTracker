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

            modelBuilder.Entity<Category>().HasData(
                new Category { Id = 1, Name = "Spożywcze", IsDefault = true },
                new Category { Id = 2, Name = "Jedzenie na mieście", IsDefault = true },
                new Category { Id = 3, Name = "Transport i Paliwo", IsDefault = true },
                new Category { Id = 4, Name = "Dom i Rachunki", IsDefault = true },
                new Category { Id = 5, Name = "Zdrowie i Uroda", IsDefault = true },
                new Category { Id = 6, Name = "Odzież i Obuwie", IsDefault = true },
                new Category { Id = 7, Name = "Rozrywka", IsDefault = true },
                new Category { Id = 8, Name = "Elektronika i AGD", IsDefault = true },
                new Category { Id = 9, Name = "Dzieci", IsDefault = true },
                new Category { Id = 10, Name = "Zwierzęta", IsDefault = true },
                new Category { Id = 11, Name = "Edukacja", IsDefault = true },
                new Category { Id = 12, Name = "Prezenty", IsDefault = true },
                new Category { Id = 13, Name = "Inne", IsDefault = true }
            );

            modelBuilder.Entity<Store>().HasData(
                new Store { Id = 1, Name = "BIEDRONKA", LogoUrl = "biedronka.png", IsDefault = true },
                new Store { Id = 2, Name = "KFC", LogoUrl = "kfc.png", IsDefault = true },
                new Store { Id = 3, Name = "LEWIATAN", LogoUrl = "lewiatan.png", IsDefault = true },
                new Store { Id = 4, Name = "LIDL", LogoUrl = "lidl.png", IsDefault = true },
                new Store { Id = 5, Name = "MCDONALS", LogoUrl = "mcdonalds.png", IsDefault = true },
                new Store { Id = 6, Name = "SPOŁEM", LogoUrl = "spolem.png", IsDefault = true },
                new Store { Id = 7, Name = "ŻABKA", LogoUrl = "zabka.png", IsDefault = true },
                new Store { Id = 8, Name = "KAUFLAND", LogoUrl = "kaufland.png", IsDefault = true },
                new Store { Id = 9, Name = "CARREFOUR", LogoUrl = "carrefour.png", IsDefault = true },
                new Store { Id = 10, Name = "AUCHAN", LogoUrl = "auchan.png", IsDefault = true },
                new Store { Id = 11, Name = "ROSSMAN", LogoUrl = "rossman.png", IsDefault = true },
                new Store { Id = 12, Name = "HEBE", LogoUrl = "hebe.png", IsDefault = true },
                new Store { Id = 13, Name = "NETTO", LogoUrl = "netto.png", IsDefault = true },
                new Store { Id = 14, Name = "ALDI", LogoUrl = "aldi.png", IsDefault = true },
                new Store { Id = 15, Name = "STOKROTKA", LogoUrl = "stokrotka.png", IsDefault = true },
                new Store { Id = 16, Name = "INTERMARCHE", LogoUrl = "intermarche.png", IsDefault = true },
                new Store { Id = 17, Name = "ORLEN", LogoUrl = "orlen.png", IsDefault = true },
                new Store { Id = 18, Name = "WAFELEK", LogoUrl = "wafelek.png", IsDefault = true },
                new Store { Id = 19, Name = "RTVEUROAGD", LogoUrl = "rtveuroagd.png", IsDefault = true },
                new Store { Id = 20, Name = "MEDIA EXPERT", LogoUrl = "media-expert.png", IsDefault = true },
                new Store { Id = 21, Name = "X-KOM", LogoUrl = "x-kom.png", IsDefault = true },
                new Store { Id = 22, Name = "KOMPUTRONIK", LogoUrl = "komputronik.png", IsDefault = true },
                new Store { Id = 23, Name = "CIRCLE K", LogoUrl = "circle-k.png", IsDefault = true },
                new Store { Id = 24, Name = "PIEKARNIA POD TELEGRAFEM", LogoUrl = "piekarnia-pod-telegrafem.png", IsDefault = true }
            );
        }
    }
}