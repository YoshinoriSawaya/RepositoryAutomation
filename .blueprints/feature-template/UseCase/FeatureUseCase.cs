using System;
using App.Features.FeatureTemplate.Entity;
using App.Features.FeatureTemplate.Interface;

namespace App.Features.FeatureTemplate.UseCase
{
    public class FeatureTemplateUseCase : IFeatureTemplateService
    {
        public FeatureTemplateUseCase()
        {
            // TODO: リポジトリなどの外部依存（Shared/Core）をコンストラクタインジェクションで受け取る
        }

        public void Execute()
        {
            var model = new FeatureTemplateModel();

            // TODO: FeatureTemplate の具体的なユースケース処理を実装
            Console.WriteLine($"[FeatureTemplate] UseCase Executed. Model ID: {model.Id}");
        }
    }
}