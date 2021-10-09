using nexus.protocols.ble;
using Plugin.BLE.Abstractions;
using Plugin.BLE.Abstractions.Contracts;
using System;
using System.Collections.Generic;
using System.Text;

namespace Airlink.Models
{
    /*
     * BLE Device storage Model
     
     */
    public class BleDevice
    {
        public string Id { get; set; }
        public string Text { get; set; }

        public string DeviceId { get; set; }
        public string CreditRemaining { get; set; }
        public string PayGUnit { get; set; }

        public string LastDateUpdate { get; set; }
        public string Description { get; set; }
        public IDevice Device { get; set; }
        public IBleGattServerConnection Server { get; set; }


        public string AddressAndName { get; set; }
        public string RSSITx { get; set; }
        public string Flags { get; set; }

        public string Mfg { get; set; }

        public string CreditStatus { get; set; }

        public IList<AdvertisementRecord> MfgCBOR { get; set; }
    }
}
