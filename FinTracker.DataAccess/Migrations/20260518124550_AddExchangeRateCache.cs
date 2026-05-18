using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace FinTracker.DataAccess.Migrations
{
    /// <inheritdoc />
    public partial class AddExchangeRateCache : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "ExchangeRatesCache",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    CurrencyCode = table.Column<string>(type: "nvarchar(450)", nullable: false),
                    Date = table.Column<DateTime>(type: "datetime2", nullable: false),
                    Rate = table.Column<decimal>(type: "decimal(18,4)", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ExchangeRatesCache", x => x.Id);
                });

            migrationBuilder.CreateIndex(
                name: "IX_ExchangeRatesCache_CurrencyCode_Date",
                table: "ExchangeRatesCache",
                columns: new[] { "CurrencyCode", "Date" },
                unique: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "ExchangeRatesCache");
        }
    }
}
