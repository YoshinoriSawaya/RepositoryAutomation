using System;
using App.Features.BookMemo.Entity;
using App.Features.BookMemo.Interface;

namespace App.Features.BookMemo.UseCase
{
    public class BookMemoUseCase : IBookMemoService
    {
        public void Execute(string isbn, string quote, DateTime? readDate = null, int rating = 0)
        {
            var model = new BookMemoModel(isbn, quote, readDate, rating);

            Console.WriteLine($"[BookMemo] UseCase Executed. Model ID: {model.Id}, ISBN: {model.ISBN}, Quote: {model.Quote}, Read Date: {model.ReadDate}, Rating: {model.Rating}");
        }
    }
}
