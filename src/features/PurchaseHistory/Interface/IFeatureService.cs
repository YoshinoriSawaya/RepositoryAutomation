namespace App.Features.PurchaseHistory.Interface
{
    public interface IPurchaseHistoryService
    {
        /// <summary>
        /// ユーザーの購入履歴を取得します。
        /// </summary>
        /// <param name="userId">ユーザーID</param>
        /// <param name="options">検索オプション</param>
        /// <returns>購入履歴リスト</returns>
        Task<List<PurchaseHistoryModel>> GetPurchaseHistoryByUserId(string userId, PurchaseHistoryQueryOptions options);

        /// <summary>
        /// ユーザーが指定した書籍IDの購入状態を確認します。
        /// </summary>
        /// <param name="userId">ユーザーID</param>
        /// <param name="bookIds">書籍IDリスト</param>
        /// <returns>BookIDをキーとした購入状態（true: 購入済み, false: 未購入）の辞書</returns>
        Task<Dictionary<string, bool>> CheckPurchasedStatus(string userId, List<string> bookIds);
    }
}
