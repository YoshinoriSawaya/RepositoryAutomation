using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace App.Features.PurchaseHistory.UseCase
{
    public class PurchaseHistoryUseCase : IPurchaseHistoryService
    {
        private readonly IPurchaseHistoryRepository _repository;

        public PurchaseHistoryUseCase(IPurchaseHistoryRepository repository)
        {
            _repository = repository;
        }

        /// <summary>
        /// ユーザーの購入履歴を取得します。
        /// </summary>
        /// <param name="userId">ユーザーID</param>
        /// <param name="options">検索オプション</param>
        /// <returns>購入履歴リスト</returns>
        public async Task<List<PurchaseHistoryModel>> GetPurchaseHistoryByUserId(string userId, PurchaseHistoryQueryOptions options)
        {
            return await _repository.GetPurchaseHistoryByUserIdAsync(userId, options);
        }

        /// <summary>
        /// ユーザーが指定した書籍IDの購入状態を確認します。
        /// </summary>
        /// <param name="userId">ユーザーID</param>
        /// <param name="bookIds">書籍IDリスト</param>
        /// <returns>BookIDをキーとした購入状態（true: 購入済み, false: 未購入）の辞書</returns>
        public async Task<Dictionary<string, bool>> CheckPurchasedStatus(string userId, List<string> bookIds)
        {
            if (string.IsNullOrEmpty(userId) || !bookIds.Any())
                return new Dictionary<string, bool>();

            var purchasedBookIds = await _repository.GetPurchasedBookIdsAsync(userId, bookIds);

            return bookIds.ToDictionary(bookId => bookId, bookId => purchasedBookIds.Contains(bookId));
        }
    }
}
