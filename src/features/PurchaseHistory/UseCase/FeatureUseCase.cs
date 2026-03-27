using System;
using App.Features.PurchaseHistory.Entity;
using App.Features.PurchaseHistory.Interface;

namespace App.Features.PurchaseHistory.UseCase
{
    public class PurchaseHistoryUseCase : IPurchaseHistoryService
    {
        public PurchaseHistoryUseCase()
        {
            // TODO: リポジトリなどの外部依存（Shared/Core）をコンストラクタインジェクションで受け取る
        }

        public void Execute()
        {
            var model = new PurchaseHistoryModel();

            // TODO: PurchaseHistory の具体的なユースケース処理を実装
            Console.WriteLine($"[PurchaseHistory] UseCase Executed. Model ID: {model.Id}");
        }
    }
}