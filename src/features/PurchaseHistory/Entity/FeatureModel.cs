using System;

namespace App.Features.PurchaseHistory.Entity
{
    public class PurchaseHistoryModel
    {
        public Guid Id { get; private set; }

        public PurchaseHistoryModel()
        {
            Id = Guid.NewGuid();
        }

        // TODO: PurchaseHistory に関する固有のドメインロジックとプロパティを追加
    }
}