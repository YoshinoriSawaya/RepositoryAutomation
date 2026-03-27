using System;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace App.Features.PurchaseHistory.Interface
{
    public interface IPurchaseHistoryRepository
    {
        /// <summary>
        /// ユーザーの購入履歴を取得します。
        /// </summary>
        /// <param name="userId">ユーザーID</param>
        /// <param name="options">検索オプション</param>
        /// <returns>購入履歴リスト</returns>
        Task<List<PurchaseHistoryModel>> GetPurchaseHistoryByUserIdAsync(string userId, PurchaseHistoryQueryOptions options);
    }
}
