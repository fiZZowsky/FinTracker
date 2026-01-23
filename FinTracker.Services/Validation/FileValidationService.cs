using Microsoft.AspNetCore.Http;

namespace FinTracker.Services
{
    public class FileValidationService : IFileValidationService
    {
        private const long MaxFileSize = 50 * 1024 * 1024; // 50MB

        private static readonly Dictionary<string, List<byte[]>> _fileSignatures = new()
        {
            { ".jpeg", new List<byte[]>
                {
                    new byte[] { 0xFF, 0xD8, 0xFF, 0xE0 },
                    new byte[] { 0xFF, 0xD8, 0xFF, 0xE2 },
                    new byte[] { 0xFF, 0xD8, 0xFF, 0xE3 },
                    new byte[] { 0xFF, 0xD8, 0xFF, 0xDB },
                    new byte[] { 0xFF, 0xD8, 0xFF, 0xEE }
                }
            },
            { ".jpg", new List<byte[]>
                {
                    new byte[] { 0xFF, 0xD8, 0xFF, 0xE0 },
                    new byte[] { 0xFF, 0xD8, 0xFF, 0xE1 },
                    new byte[] { 0xFF, 0xD8, 0xFF, 0xE8 },
                    new byte[] { 0xFF, 0xD8, 0xFF, 0xDB }
                }
            },
            { ".png", new List<byte[]>
                {
                    new byte[] { 0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A }
                }
            },
            { ".bmp", new List<byte[]>
                {
                    new byte[] { 0x42, 0x4D }
                }
            },
             { ".webp", new List<byte[]>
                {
                    new byte[] { 0x52, 0x49, 0x46, 0x46 }
                }
            }
        };

        public (bool IsValid, string ErrorMessage) ValidateImage(IFormFile file)
        {
            if (file == null || file.Length == 0)
            {
                return (false, "Plik jest pusty.");
            }

            if (file.Length > MaxFileSize)
            {
                return (false, $"Plik przekracza maksymalny rozmiar {MaxFileSize / 1024 / 1024}MB.");
            }

            var ext = Path.GetExtension(file.FileName).ToLowerInvariant();
            if (string.IsNullOrEmpty(ext) || !_fileSignatures.ContainsKey(ext))
            {
                return (false, "Niedozwolony format pliku. Dozwolone: JPG, JPEG, PNG, BMP.");
            }

            using (var reader = new BinaryReader(file.OpenReadStream()))
            {
                var signatures = _fileSignatures[ext];
                var headerBytes = reader.ReadBytes(signatures.Max(m => m.Length));

                bool isSignatureValid = signatures.Any(signature =>
                    headerBytes.Take(signature.Length).SequenceEqual(signature)
                );

                if (!isSignatureValid)
                {
                    return (false, "Zawartość pliku nie zgadza się z jego rozszerzeniem. Wykryto próbę fałszerstwa.");
                }

                file.OpenReadStream().Position = 0;
            }

            return (true, string.Empty);
        }
    }
}