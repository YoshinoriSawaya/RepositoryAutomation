using System;

namespace App.Features.BookMemo.Entity
{
    public class BookMemoModel
    {
        public Guid Id { get; private set; }
        public string ISBN { get; private set; }
        public string Quote { get; private set; }

        public BookMemoModel(string isbn, string quote)
        {
            Id = Guid.NewGuid();
            ISBN = isbn;
            Quote = quote;
        }
    }
}
