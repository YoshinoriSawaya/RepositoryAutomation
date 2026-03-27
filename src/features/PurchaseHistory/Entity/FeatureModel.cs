using System;

namespace App.Features.PurchaseHistory.Entity
{
    public class PurchaseHistoryModel
    {
        public Guid Id { get; private set; }

        public string UserId { get; private set; }

        public string BookId { get; private set; }

        public DateTime PurchaseDate { get; private set; }

        public PurchaseHistoryModel(string userId, string bookId)
        {
            Id = Guid.NewGuid();
            UserId = userId;
            BookId = bookId;
            PurchaseDate = DateTime.Now;
        }
    }
}
