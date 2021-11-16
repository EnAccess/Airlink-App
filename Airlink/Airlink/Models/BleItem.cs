using nexus.protocols.ble;
using Plugin.BLE.Abstractions;
using Plugin.BLE.Abstractions.Contracts;
using System;
using System.Collections.Generic;
using System.Text;
using System.Diagnostics;
using Airlink.Services;
using Airlink.Models.ResourceModels;
using PeterO.Cbor;
using Xamarin.Essentials;
using System.Linq;


namespace Airlink.Models
{
    /*
     * BLE Device storage Model
     */
    public class BleItem
    {
        public string Id { get; set; }
        public string Text { get; set; } //FIXME rename or remove
        public bool   KeyKnown { get; set; } //FIXME check if needed

        public AirLinkDevice ServerSharedAttributeKVP { get; set; }

        public string DeviceId { get; set; }
        public string CreditRemaining { get; set; }
        public string PayGUnit { get; set; }

        public string LastDateUpdate { get; set; }
        public string Description { get; set; }
        public IDevice Device { get; set; }
        public IBleGattServerConnection Server { get; set; }

        public DateTime LastScanTime { get; set; }

        public double Latitude { get; set; }
        public double Longitude { get; set; }
        public double? LocationAccuracy { get; set; } //nullable double
        public string AddressAndName { get; set; }
        public string RSSITx { get; set; }
        public string Flags { get; set; }

        public string Mfg { get; set; }

        public string CreditStatus { get; set; }

        public IList<AdvertisementRecord> MfgCBOR { get; set; }

        public string[] UpdateDeviceParamsFromAdvt(Location location)
        {
            try
            {
                //Formatting advertised data per AirLink 1.0 spec
                byte[] cbor = DataConverter.StringToByteArray(ManufacturedAdvertisedData(Mfg));
                var ob = CBORObject.DecodeFromBytes(cbor, new CBOREncodeOptions("resolvereferences=true")).ToString();
                //var ob = jcbor.ToString();
                ob = ob.Replace("\t", "").Replace("\n", "").Replace("\r", "").Replace("[", "").Replace("]", "").Replace("\"", "").Trim();
                string[] advertData = ob.Split(',');
                this.Flags = ob;

                //Scantime
                LastScanTime = DateTime.UtcNow;
                //Device id
                DeviceId = advertData[2].Trim();
                //update credit remaining
                CreditRemaining = advertData[6].Trim();
                //UPDATE Payg unit
                PayGUnit = advertData[7].Trim();

                //Update credit status
                int creditStatus = Int32.Parse(advertData[6].Trim());
                if (creditStatus > 0)
                {
                    CreditStatus = "#00FF00";
                }
                else
                {
                    CreditStatus = "#EA7979";
                }
                //update last update date
                long dateLast = long.Parse(advertData[3].Trim());
                DateTimeOffset dateTimeOffset = DateTimeOffset.FromUnixTimeSeconds(dateLast);
                LastDateUpdate = dateTimeOffset.Date.ToString("ddd, MMM dd yyyy");

                if (location != null)
                {
                    Latitude = location.Latitude;
                    Longitude = location.Longitude;
                    LocationAccuracy = location.Accuracy.Value;
                }
                return advertData;
            }
            catch (Exception ex)
            {
                Debug.WriteLine(ex.Message);
                return null;
            }
        }

        /*Get Manufacture advertised data
        * 
        */
        public string ManufacturedAdvertisedData(string manafactureData)
        {
            try
            {
                string[] dataArray = manafactureData.Split(',');
                foreach (var dString in dataArray)
                {
                    if (dString.Contains("Manufacturer"))
                    {
                        string[] manufacture = dString.Split('=');
                        foreach (var item in manufacture)
                        {
                            if (item.Contains("0x"))
                            {

                                string data = item.Substring(6);
                                return data;
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                Debug.WriteLine(ex.Message);
            }

            return null;
        }
        /*
         * Custom CBOR convertor
         */
        public string CBORCustomdecode(string data)
        {
            try
            {
                string[] formattedData = data.Split(',');
                foreach (var item in formattedData)
                {
                    if (item.Contains('h'))
                    {
                        string cborData = item.Substring(3);
                        string fcborData = cborData.Substring(0, cborData.Length - 2);
                        return fcborData;
                    }
                }

            }
            catch (Exception)
            {
                Debug.WriteLine("Process Failed", "");
            }
            return null;
        }


    }
}
