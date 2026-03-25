using System;

namespace App.Features.FeatureTemplate.Entity
{
    public class FeatureTemplateModel
    {
        public Guid Id { get; private set; }

        public FeatureTemplateModel()
        {
            Id = Guid.NewGuid();
        }

        // TODO: FeatureTemplate に関する固有のドメインロジックとプロパティを追加
    }
}