using SQLite;
using System;
using System.Collections.Generic;
using System.Text;

namespace Airlink.Models.AirlinkPAYG
{
   public class PUEPayGData
    {
        [PrimaryKey, AutoIncrement]
        public int Id { get; set; }
        //Airlink PAYG resource Version
        public string Rv { get; set; }
        //Device Credit remaining 
        public string Re { get; set; }
        //Mode
        public string Mo { get; set; }
        //PayG Token
        public string Tkn { get; set; }
        //Last Added PayG Credit
        public string Lcr { get; set; }
        //Timestamp at which PayG Remaining was calculated
        public string Ts { get; set; }
        //Timestamp of last PAYG update to device 
        public string Lts { get; set; }
        //Current Local Time
        public string Lt { get; set; }
    }
}
