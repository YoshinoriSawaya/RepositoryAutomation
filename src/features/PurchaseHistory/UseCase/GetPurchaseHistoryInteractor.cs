using System;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace App.Features.PurchaseHistory.UseCase
{
    public class GetPurchaseHistoryInteractor : IPurchaseHistoryService
    {
        private readonly IPurchaseHistoryRepository _repository;

        public GetPurchaseHistoryInteractor(IPurchaseHistoryRepository repository)
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
    }
}
