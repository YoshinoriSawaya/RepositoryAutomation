using System;

namespace App.Features.MemoSearch.Entity
{
    public class MemoSearchModel
    {
        public Guid Id { get; private set; }

        public MemoSearchModel()
        {
            Id = Guid.NewGuid();
        }

        // TODO: MemoSearch 縺ｫ髢｢縺吶ｋ蝗ｺ譛峨・繝峨Γ繧､繝ｳ繝ｭ繧ｸ繝・け縺ｨ繝励Ο繝代ユ繧｣繧定ｿｽ蜉
    }
}