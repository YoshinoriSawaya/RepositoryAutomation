using System;
using App.Features.MemoExport.Entity;
using App.Features.MemoExport.Interface;

namespace App.Features.MemoExport.UseCase
{
    public class MemoExportUseCase : IMemoExportService
    {
        public MemoExportUseCase()
        {
            // TODO: 繝ｪ繝昴ず繝医Μ縺ｪ縺ｩ縺ｮ螟夜Κ萓晏ｭ假ｼ・hared/Core・峨ｒ繧ｳ繝ｳ繧ｹ繝医Λ繧ｯ繧ｿ繧､繝ｳ繧ｸ繧ｧ繧ｯ繧ｷ繝ｧ繝ｳ縺ｧ蜿励￠蜿悶ｋ
        }

        public void Execute()
        {
            var model = new MemoExportModel();

            // TODO: MemoExport 縺ｮ蜈ｷ菴鍋噪縺ｪ繝ｦ繝ｼ繧ｹ繧ｱ繝ｼ繧ｹ蜃ｦ逅・ｒ螳溯｣・
            Console.WriteLine($"[MemoExport] UseCase Executed. Model ID: {model.Id}");
        }
    }
}