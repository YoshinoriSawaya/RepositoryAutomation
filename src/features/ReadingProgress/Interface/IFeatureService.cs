namespace App.Features.ReadingProgress.Interface
{
    /// <summary>
    /// 読書進捗率の計算を行うサービスインターフェース。
    /// </summary>
    public interface IReadingProgressService
    {
        /// <summary>
        /// 総ページ数と現在の読了ページ数から、読書進捗率を計算します。
        /// </summary>
        /// <param name="totalPages">総ページ数</param>
        /// <param name="currentPage">現在の読了ページ数</param>
        /// <returns>読書進捗率（0.0〜100.0）</returns>
        double CalculateProgressRate(int totalPages, int currentPage);
    }
}
