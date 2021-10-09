using SQLite;
using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Text;

namespace Airlink.Models
{
    public class ResourceDataBank
    {
        [AutoIncrement,PrimaryKey]
        public int Id { get; set; }
        public string Guid { get; set; }

        public string Name { get; set; }

        public ObservableCollection<PropertyDataBank> Properties { get; set; }
    }
}
