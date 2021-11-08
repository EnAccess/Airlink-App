using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Text;

namespace Airlink.Models
{
    /*
    * OCF Recource and Resource property  Model

    */
    public class ResourceAndProperties
    {
        public string Name { get; set; }
        public string Guid { get; set; }

        public string Id { get; set; }

        public ObservableCollection<Property> PropertiesList { get; set; }
    }
}
