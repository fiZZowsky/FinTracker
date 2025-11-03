namespace FinTracker.Models
{
    public class BaseQuery
    {
        private int _pageSize = 100;

        public int PageSize
        {
            get => _pageSize;
            set => _pageSize = (value > 0 && value <= 10000) ? value : 100;
        }

        private int _page = 1;
        public int Page
        {
            get => _page;
            set => _page = (value <= 0) ? 1 : value;
        }
    }
}
