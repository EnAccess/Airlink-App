using SQLite;
using System;
using System.Collections.Generic;
using System.Text;

namespace Airlink.Models
{
   public class PropertyDataBank
    {
        [AutoIncrement, PrimaryKey]
        public int Id { get; set; }
        public string Guid { get; set; }

        public string Name { get; set; }
    }
}
