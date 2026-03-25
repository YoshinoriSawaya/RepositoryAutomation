using System;

namespace App.Features.IsbnValidator.Entity
{
    public class IsbnValidatorModel
    {
        public Guid Id { get; private set; }

        public IsbnValidatorModel()
        {
            Id = Guid.NewGuid();
        }

        // TODO: IsbnValidator 縺ｫ髢｢縺吶ｋ蝗ｺ譛峨・繝峨Γ繧､繝ｳ繝ｭ繧ｸ繝・け縺ｨ繝励Ο繝代ユ繧｣繧定ｿｽ蜉
    }
}