using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Text;

namespace Airlink.Models
{
    public class PaygUnitAccepted
    {
        public string none { get; set; }
        public string name { get; set; }
    }

    public class PaygUpdate
    {
        public string Deviceid { get; set; }
        public int PaygCreditRemaing { get; set; }
        public DateTime LastCalculatedTime { get; set; }
        public DateTime CurrentTime { get; set; }
        public string PaygUnit { get; set; }
        public int LastPaygCredit { get; set; }
        public string LastPaygUnit { get; set; }
        public DateTime LastUpdateTime { get; set; }
        public ObservableCollection<PaygUnitAccepted> PaygUnitAccepted { get; set; }
    }
}
