using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using App.Features.PurchaseHistory.Entity;
using App.Features.PurchaseHistory.Interface;

namespace App.Features.PurchaseHistory.UseCase
{
    public class PurchaseHistoryUseCase : IPurchaseHistoryService
    {
        private readonly IPurchaseHistoryRepository _repository; // リポジトリの依存注入

        /// <summary>
        /// コンストラクタでリポジトリを受け取ります。
        /// </summary>
        /// <param name="repository">購入履歴リポジトリ</param>
        public PurchaseHistoryUseCase(IPurchaseHistoryRepository repository)
        {
            _repository = repository;
        }

        /// <summary>
        /// ユーザーが指定した書籍IDの購入状態を一括で判定します。
        /// </summary>
        /// <param name="userId">ユーザーID</param>
        /// <param name="bookIds">書籍IDリスト</param>
        /// <returns>BookIDをキーとした購入状態（true: 購入済み, false: 未購入）のDictionary</returns>
        public async Task<Dictionary<string, bool>> CheckPurchasedStatus(string userId, List<string> bookIds)
        {
            // 重複するbookIdsを一意にまとめる
            var uniqueBookIds = bookIds.Distinct().ToList();

            if (!uniqueBookIds.Any())
            {
                return new Dictionary<string, bool>();
            }

            // IN句を使用して一括でデータベースへ問い合わせる
            var purchasedStatuses = await _repository.GetPurchasedStatusesAsync(userId, uniqueBookIds);

            // 結果をDictionaryに変換する
            var result = uniqueBookIds.ToDictionary(id => id, id => purchasedStatuses.ContainsKey(id));

            return result;
        }
    }
}
