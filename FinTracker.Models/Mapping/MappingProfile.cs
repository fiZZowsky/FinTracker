using AutoMapper;
using System.Text;

namespace FinTracker.Models
{
    public class MappingProfile : Profile
    {
        public MappingProfile()
        {
            CreateMap<Receipt, ReceiptDTO>()
                .ForMember(dest => dest.CategoryName, opt => opt.MapFrom(src => src.Category != null ? src.Category.Name : null))
                .ReverseMap();

            CreateMap<Store, StoreDTO>()
                .ForMember(
                    dest => dest.Logo,
                    opt => opt.MapFrom(src => LoadLogoBytes(src.LogoUrl))
                );

            CreateMap<StoreDTO, Store>()
                .ForMember(
                    dest => dest.LogoUrl,
                    opt => opt.MapFrom(src => SaveLogoBytes(src.Logo, src.Name))
                );

            CreateMap<Category, CategoryDTO>().ReverseMap();
        }

        private static byte[]? LoadLogoBytes(string? logoFileName)
        {
            if (string.IsNullOrEmpty(logoFileName))
                return null;

            try
            {
                string basePath = AppDomain.CurrentDomain.BaseDirectory;
                string logoPath = Path.Combine(basePath, "Logos", logoFileName);

                if (File.Exists(logoPath))
                {
                    return File.ReadAllBytes(logoPath);
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Błąd odczytu pliku logo '{logoFileName}': {ex.Message}");
            }

            return null;
        }

        private static string? SaveLogoBytes(byte[]? logoBytes, string storeName)
        {
            if (logoBytes == null || logoBytes.Length == 0 || string.IsNullOrWhiteSpace(storeName))
                return null;

            try
            {
                string normalized = storeName.ToLower();
                
                normalized = normalized
                    .Replace("ą", "a")
                    .Replace("ć", "c")
                    .Replace("ę", "e")
                    .Replace("ł", "l")
                    .Replace("ń", "n")
                    .Replace("ó", "o")
                    .Replace("ś", "s")
                    .Replace("ź", "z")
                    .Replace("ż", "z");
                
                var sb = new StringBuilder();
                foreach (char c in normalized)
                {
                    if (char.IsLetterOrDigit(c) || c == '-')
                    {
                        sb.Append(c);
                    }
                    else if (char.IsWhiteSpace(c))
                    {
                        sb.Append('-');
                    }
                }
                string safeName = sb.ToString();
                
                string extension = ".png";
                string fileName = $"{safeName}{extension}";

                string basePath = AppDomain.CurrentDomain.BaseDirectory;
                string logosDir = Path.Combine(basePath, "Logos");

                if (!Directory.Exists(logosDir))
                {
                    Directory.CreateDirectory(logosDir);
                }

                string fullPath = Path.Combine(logosDir, fileName);
                File.WriteAllBytes(fullPath, logoBytes);

                return fileName;
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Błąd zapisu pliku logo dla '{storeName}': {ex.Message}");
                return null;
            }
        }
    }
}
