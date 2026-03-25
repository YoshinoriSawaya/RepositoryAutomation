using System;

namespace App.Features.BookMemo.Entity
{
    public class BookMemoModel
    {
        public Guid Id { get; private set; }
        public string ISBN { get; private set; }
        public string Quote { get; private set; }
        public DateTime? ReadDate { get; private set; }
        public int Rating { get; private set; }

        public BookMemoModel(string isbn, string quote, DateTime? readDate = null, int rating = 0)
        {
            Id = Guid.NewGuid();
            ISBN = isbn;
            Quote = quote;
            ReadDate = readDate;
            Rating = rating;
        }
    }
}
