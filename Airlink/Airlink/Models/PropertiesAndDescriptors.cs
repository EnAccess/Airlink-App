using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Text;

namespace Airlink.Models
{
    public class PropertiesAndDescriptors
    {

        public string DescriptorId { get; set; }
        public string DescriptorName { get; set; }
        public string DescriptorValue { get; set; }
        public ObservableCollection<Descriptor> DescriptorList { get; set; }
    }
}
