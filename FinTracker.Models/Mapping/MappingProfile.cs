using AutoMapper;

namespace FinTracker.Models
{
    public class MappingProfile : Profile
    {
        public MappingProfile()
        {
            CreateMap<Receipt, ReceiptDTO>().ReverseMap();
        }
    }
}
