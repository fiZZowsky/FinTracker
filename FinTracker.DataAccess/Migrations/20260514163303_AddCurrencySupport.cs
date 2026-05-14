using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace FinTracker.DataAccess.Migrations
{
    /// <inheritdoc />
    public partial class AddCurrencySupport : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "CurrencyCode",
                table: "Receipts",
                type: "nvarchar(3)",
                maxLength: 3,
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<decimal>(
                name: "ExchangeRate",
                table: "Receipts",
                type: "decimal(18,4)",
                nullable: false,
                defaultValue: 0m);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "CurrencyCode",
                table: "Receipts");

            migrationBuilder.DropColumn(
                name: "ExchangeRate",
                table: "Receipts");
        }
    }
}
