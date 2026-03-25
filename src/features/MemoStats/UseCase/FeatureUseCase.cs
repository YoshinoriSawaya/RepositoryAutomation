using System;
using System.Collections.Generic;
using System.Linq;
using App.Features.BookMemo.Entity;
using App.Features.MemoStats.Entity;
using App.Features.MemoStats.Interface;

namespace App.Features.MemoStats.UseCase
{
    public class MemoStatsUseCase : IMemoStatsService
    {
        public Dictionary<string, int> GetCountByIsbn(IEnumerable<BookMemoModel> memos)
        {
            if (memos == null || !memos.Any())
            {
                return new Dictionary<string, int>();
            }

            var countByIsbn = memos
                .GroupBy(memo => memo.Isbn)
                .ToDictionary(group => group.Key, group => group.Count());

            return countByIsbn;
        }
    }
}
