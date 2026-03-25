using System;

namespace App.Features.QuoteFormatter.Entity
{
    public class QuoteFormatterModel
    {
        public Guid Id { get; private set; }

        public QuoteFormatterModel()
        {
            Id = Guid.NewGuid();
        }

        // TODO: QuoteFormatter 縺ｫ髢｢縺吶ｋ蝗ｺ譛峨・繝峨Γ繧､繝ｳ繝ｭ繧ｸ繝・け縺ｨ繝励Ο繝代ユ繧｣繧定ｿｽ蜉
    }
}