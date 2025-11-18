using AutoMapper;

namespace FinTracker.Models
{
    public class MappingProfile : Profile
    {
        public MappingProfile()
        {
            CreateMap<Receipt, ReceiptDTO>().ReverseMap();
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
            if (logoBytes == null || logoBytes.Length == 0)
                return null;

            try
            {
                string safeName = storeName.ToLower().Replace(" ", "-");

                // TODO: Poprawić detekcję rozszerzenia (np. sprawdzając "magic bytes" pliku)
                string extension = ".png";
                string fileName = $"{safeName}-{Guid.NewGuid().ToString().Substring(0, 8)}{extension}";

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
