namespace App.Features.PurchaseHistory.Interface
{
    public interface IPurchaseHistoryService
    {
        /// <summary>
        /// ユーザーが指定した書籍IDの購入状態を一括で判定します。
        /// </summary>
        /// <param name="userId">ユーザーID</param>
        /// <param name="bookIds">書籍IDリスト</param>
        /// <returns>BookIDをキーとした購入状態（true: 購入済み, false: 未購入）のDictionary</returns>
        Task<Dictionary<string, bool>> CheckPurchasedStatus(string userId, List<string> bookIds);
    }
}
