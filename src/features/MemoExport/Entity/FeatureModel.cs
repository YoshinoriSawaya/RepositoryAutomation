using System;

namespace App.Features.MemoExport.Entity
{
    public class MemoExportModel
    {
        public Guid Id { get; private set; }

        public MemoExportModel()
        {
            Id = Guid.NewGuid();
        }

        // TODO: MemoExport 縺ｫ髢｢縺吶ｋ蝗ｺ譛峨・繝峨Γ繧､繝ｳ繝ｭ繧ｸ繝・け縺ｨ繝励Ο繝代ユ繧｣繧定ｿｽ蜉
    }
}