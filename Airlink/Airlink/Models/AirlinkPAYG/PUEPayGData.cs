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
        //Rtr
        public UInt32 Rtr { get; set; }
        //Airlink PAYG resource Version
        public UInt32 Rv { get; set; }
        //Device Credit remaining 
        public UInt32 Re { get; set; }
        //Mode
        public UInt16 Mo { get; set; }
        //PayG Token
        public UInt32 Tkn { get; set; }
        //Last Added PayG Credit
        public UInt32 Lcr { get; set; }
        //Timestamp at which PayG Remaining was calculated
        public UInt32 Ts { get; set; }
        //Timestamp of last PAYG update to device 
        public UInt32 Lts { get; set; }
        //Current Local Time
        public UInt32 Lt { get; set; }
    }
}
