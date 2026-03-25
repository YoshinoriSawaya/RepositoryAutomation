using System;
using App.Features.IsbnValidator.Entity;
using App.Features.IsbnValidator.Interface;

namespace App.Features.IsbnValidator.UseCase
{
    public class IsbnValidatorUseCase : IIsbnValidatorService
    {
        public IsbnValidatorUseCase()
        {
            // TODO: 繝ｪ繝昴ず繝医Μ縺ｪ縺ｩ縺ｮ螟夜Κ萓晏ｭ假ｼ・hared/Core・峨ｒ繧ｳ繝ｳ繧ｹ繝医Λ繧ｯ繧ｿ繧､繝ｳ繧ｸ繧ｧ繧ｯ繧ｷ繝ｧ繝ｳ縺ｧ蜿励￠蜿悶ｋ
        }

        public void Execute()
        {
            var model = new IsbnValidatorModel();

            // TODO: IsbnValidator 縺ｮ蜈ｷ菴鍋噪縺ｪ繝ｦ繝ｼ繧ｹ繧ｱ繝ｼ繧ｹ蜃ｦ逅・ｒ螳溯｣・
            Console.WriteLine($"[IsbnValidator] UseCase Executed. Model ID: {model.Id}");
        }
    }
}