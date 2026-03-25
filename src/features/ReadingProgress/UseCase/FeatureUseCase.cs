using System;
using App.Features.ReadingProgress.Entity;
using App.Features.ReadingProgress.Interface;

namespace App.Features.ReadingProgress.UseCase
{
    public class ReadingProgressUseCase : IReadingProgressService
    {
        /// <summary>
        /// 総ページ数と現在の読了ページ数から、読書進捗率を計算します。
        /// </summary>
        /// <param name="totalPages">総ページ数</param>
        /// <param name="currentPage">現在の読了ページ数</param>
        /// <returns>読書進捗率（0.0〜100.0）</returns>
        public double CalculateProgressRate(int totalPages, int currentPage)
        {
            // ガード節: totalPages が 0 以下の場合は、計算不能として 0.0 を返す
            if (totalPages <= 0)
            {
                return 0.0;
            }

            // バリデーション: currentPage が負の値の場合は 0.0 として扱う
            if (currentPage < 0)
            {
                currentPage = 0;
            }
            // バリデーション: currentPage が totalPages を超える場合は 100.0 として扱う
            else if (currentPage > totalPages)
            {
                currentPage = totalPages;
            }

            // 計算: 小数点第2位まで（または精度を保った double）で進捗率を算出する
            double progressRate = (double)currentPage / totalPages * 100.0;

            return Math.Round(progressRate, 2);
        }
    }
}
