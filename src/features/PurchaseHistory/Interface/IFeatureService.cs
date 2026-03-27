namespace App.Features.PurchaseHistory.Interface
{
    public interface IPurchaseHistoryService
    {


      // TODO: PurchaseHistory の主要な操作を定義
        void Execute();
  
        /// <summary>
        /// ユーザーの購入履歴を取得します。
        /// </summary>
        /// <param name="userId">ユーザーID</param>
        /// <param name="options">検索オプション</param>
        /// <returns>購入履歴リスト</returns>
        Task<List<PurchaseHistoryModel>> GetPurchaseHistoryByUserId(string userId, PurchaseHistoryQueryOptions options);
    }
}