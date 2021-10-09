using SQLite;
using System;
using System.Collections.Generic;
using System.Text;

namespace Airlink.Models.PUEAdvert
{
    public class PUEAdvertisedData
    {
        [PrimaryKey,AutoIncrement]
        public int Id { get; set; }
        //BLE Advert resource version
        public string Rv { get; set; }
        //Device Fault Status CBOR encoded
        public string Ft { get; set; }
        //Device PayG Credit Remaining
        public string Cr { get; set; }
        //Device FW 
        public string Fv { get; set; }
        //PayG Unit
        public string Pu { get; set; }
        //Device ID
        public string Did { get; set; }
        //Timestamp last pulled from gateway or network
        public string Gts { get; set; }
        //Device provisioning status
        public string Pst { get; set; }
        //Reporting Location Latitude
        public string Lt { get; set; }
        //Reporting Location Longtude
        public string Ln { get; set; }

        //Location Accuracy
        public string La { get; set; }

        //Signal strength
        public string Ssn { get; set; }
}
}

//Device Error Status
//public string Err { get; set; }

//Device asset status
//public string Ds { get; set; }

//BLE Advt data format version
//public string Adf { get; set; }