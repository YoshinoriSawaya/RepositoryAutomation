using System;
using App.Features.QuoteFormatter.Entity;
using App.Features.QuoteFormatter.Interface;

namespace App.Features.QuoteFormatter.UseCase
{
    public class QuoteFormatterUseCase : IQuoteFormatterService
    {
        public QuoteFormatterUseCase()
        {
            // TODO: 繝ｪ繝昴ず繝医Μ縺ｪ縺ｩ縺ｮ螟夜Κ萓晏ｭ假ｼ・hared/Core・峨ｒ繧ｳ繝ｳ繧ｹ繝医Λ繧ｯ繧ｿ繧､繝ｳ繧ｸ繧ｧ繧ｯ繧ｷ繝ｧ繝ｳ縺ｧ蜿励￠蜿悶ｋ
        }

        public void Execute()
        {
            var model = new QuoteFormatterModel();

            // TODO: QuoteFormatter 縺ｮ蜈ｷ菴鍋噪縺ｪ繝ｦ繝ｼ繧ｹ繧ｱ繝ｼ繧ｹ蜃ｦ逅・ｒ螳溯｣・
            Console.WriteLine($"[QuoteFormatter] UseCase Executed. Model ID: {model.Id}");
        }
    }
}