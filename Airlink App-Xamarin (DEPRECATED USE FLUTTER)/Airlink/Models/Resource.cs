using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Text;

namespace Airlink.Models
{
    /*
 * OCF Recource Model

 */
    public class Resource
    {
        public string Name { get; set; }
        public string Id { get; set; }
        public ObservableCollection<Property> PropertiesList { get; set; }
    }
}
