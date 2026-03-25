namespace App.Features.MemoStats.Interface
{
    public interface IMemoStatsService
    {
        Dictionary<string, int> GetCountByIsbn(IEnumerable<BookMemoModel> memos);
    }
}
