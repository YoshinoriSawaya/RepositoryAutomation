using System;

namespace App.Features.MemoStats.Entity
{
    public class MemoStatsModel
    {
        public Guid Id { get; private set; }

        public MemoStatsModel()
        {
            Id = Guid.NewGuid();
        }

        // TODO: MemoStats 縺ｫ髢｢縺吶ｋ蝗ｺ譛峨・繝峨Γ繧､繝ｳ繝ｭ繧ｸ繝・け縺ｨ繝励Ο繝代ユ繧｣繧定ｿｽ蜉
    }
}