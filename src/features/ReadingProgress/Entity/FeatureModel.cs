using System;

namespace App.Features.ReadingProgress.Entity
{
    public class ReadingProgressModel
    {
        public Guid Id { get; private set; }

        public ReadingProgressModel()
        {
            Id = Guid.NewGuid();
        }
    }
}
