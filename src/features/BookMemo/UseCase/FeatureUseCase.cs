using System;
using App.Features.BookMemo.Entity;
using App.Features.BookMemo.Interface;

namespace App.Features.BookMemo.UseCase
{
    public class BookMemoUseCase : IBookMemoService
    {
        public void Execute(string isbn, string quote)
        {
            var model = new BookMemoModel(isbn, quote);

            Console.WriteLine($"[BookMemo] UseCase Executed. Model ID: {model.Id}, ISBN: {model.ISBN}, Quote: {model.Quote}");
        }
    }
}
