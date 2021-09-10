using Plugin.BLE.Abstractions.Contracts;
using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Text;

namespace Airlink.Models
{
    /*
    * OCF Recource property Model

    */
    public class Property
    {
        public string Id { get; set; }
        public bool Read { get; set; }
        public bool Write { get; set; }
        public bool Update { get; set; }

        public string Name { get; set; }

        public string ServiceID { get; set; }
        public string Servicename { get; set; }

        public ICharacteristic IProperty { get; set; }
    }
/*
 * Property ID
 */
 public class PropertyID
    {
        public string PropertyUUID { get; set; }

    }
}
