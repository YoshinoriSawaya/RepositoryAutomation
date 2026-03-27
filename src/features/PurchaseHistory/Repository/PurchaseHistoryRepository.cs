using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace App.Features.PurchaseHistory.Repository
{
    public class PurchaseHistoryRepository : IPurchaseHistoryRepository
    {
        private readonly List<PurchaseRecord> _purchaseRecords;

        public PurchaseHistoryRepository()
        {
            _purchaseRecords = new List<PurchaseRecord>
            {
                // テスト用データ
                new PurchaseRecord { Id = Guid.NewGuid(), BookId = "1", UserId = "user1", Price = 100, PurchasedAt = DateTime.Now },
                new PurchaseRecord { Id = Guid.NewGuid(), BookId = "2", UserId = "user1", Price = 200, PurchasedAt = DateTime.Now.AddDays(-1) }
            };
        }

        public async Task<List<PurchaseHistoryModel>> GetPurchaseHistoryByUserIdAsync(string userId, PurchaseHistoryQueryOptions options)
        {
            if (string.IsNullOrEmpty(userId))
                return new List<PurchaseHistoryModel>();

            var query = _purchaseRecords
                .Where(record => record.UserId == userId && !record.IsDeleted)
                .OrderByDescending(record => record.PurchasedAt);

            if (options.Limit.HasValue)
                query = query.Take(options.Limit.Value);

            if (options.Offset.HasValue)
                query = query.Skip(options.Offset.Value);

            return await Task.FromResult(query.Select(record => new PurchaseHistoryModel
            {
                Id = record.Id,
                BookId = record.BookId,
                Price = record.Price,
                PurchasedAt = record.PurchasedAt
            }).ToList());
        }
    }

    public class PurchaseRecord
    {
        public Guid Id { get; set; }
        public string BookId { get; set; }
        public string UserId { get; set; }
        public decimal Price { get; set; }
        public DateTime PurchasedAt { get; set; }
        public bool IsDeleted { get; set; }
    }
}
