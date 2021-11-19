using Airlink.Models.AirlinkPAYG;
using Airlink.Services;
using Newtonsoft.Json;
using PeterO.Cbor;
using SQLite;
using System;
using System.Collections.Generic;
using System.Text;
using System.Threading.Tasks;
using Xamarin.Forms.Xaml;

namespace Airlink.ViewModels
{
    [XamlCompilation(XamlCompilationOptions.Compile)]
    public class PayGData
    {
        /*
         * Decode Cbordata read from the Property
         */
        public static async Task<string> ReadDataFromBLEAysnc(string hex)
        {
            hex = hex.Replace("-", "");
            byte[] cbor = DataConverter.StringToByteArray(hex);
            TimeSpan t = DateTime.Now - new DateTime(1970, 1, 1);
            var jcbor = CBORObject.DecodeFromBytes(cbor);
            var ob = jcbor.ToString();

            string jsonString = jcbor.ToJSONString();
            var payg = JsonConvert.DeserializeObject<PUEPayGData>(jsonString);

            UInt32 secondsSinceEpoch = (UInt32)t.TotalSeconds;
            PUEPayGData pUEPayGData = new PUEPayGData
            {
                Rtr = 65001,
                Rv = 0123456789,
                Re = 10,
                Mo = 1,
                Tkn = 1234560789,
                Lcr = 40,
                Ts = 1631261161,
                Lts = 1631261161,
                Lt = secondsSinceEpoch
            };
            
            return ob;
        }
        /*
         * Pass the PUEPAYG Data to write to the Bluetooth Property
         */
        public static async Task<string> SendDataToBLEAsync()
        {
            TimeSpan t = DateTime.Now - new DateTime(1970, 1, 1);
            UInt32 secondsSinceEpoch = (UInt32)t.TotalSeconds;
            PUEPayGData pUEPayGData = new PUEPayGData
            {
                Rtr = 65001,
                Rv = 0123456789,
                Re = 10,
                Mo = 1,
                Tkn = 1234560789,
                Lcr = 40,
                Ts = 1631261161,
                Lts = 1631261161,
                Lt = secondsSinceEpoch
            };
            //Database connection

            using (SQLiteConnection conn = new SQLiteConnection(App.DatabaseLocation))
            {
                //create table and insert into database!
                conn.CreateTable<PUEPayGData>();

                //Instert data in a database
                int rows = conn.Insert(pUEPayGData);

                if (rows > 0)
                {
                    Console.WriteLine("Success");
                }
                else
                {
                    Console.WriteLine("Failed");
                }

            }
            using (SQLiteConnection con = new SQLiteConnection(App.DatabaseLocation))
            {
                con.CreateTable<PUEPayGData>();
                var puePayGdata = con.Table<PUEPayGData>().ToList();

                foreach (var data in puePayGdata)
                {
                    var SendCbor = CBORObject.NewMap()
                            .Add("rtr",data.Rtr)
                            .Add("rv",data.Rv)
                            .Add("re",data.Re)
                            //.Add("mo",data.Mo)
                            .Add("tkn",data.Tkn)
                            .Add("lcr",data.Lcr)
                            .Add("ts",data.Ts)
                            .Add("lts",data.Lts)
                            .Add("lt",data.Lt);

                    byte[] bytes = SendCbor.EncodeToBytes();
                    // PUEAd.Add(x);
                    var cborHexstring = DataConverter.BytesToHexString(bytes);
                    cborHexstring = cborHexstring.Replace("-", "");
                    var result = SendCbor.ToString();
                    SendCbor.Add("cbor", cborHexstring);
                    var contents = SendCbor.ToJSONString();
                    //post data to IoT Engine thingsboard.io
                    var postTask = await AirLinkServer.PostToAirLinkServer(contents, "", "telemetry"); //FIXME CRITICAL Add devicename
                    if (postTask.status) 
                    {
                        //Delete data from a local database
                        con.Delete<PUEPayGData>(data.Id);
                    }
                    con.DeleteAll<PUEPayGData>();
                    return result;
                }
            }
            return null;
        }
    }
}
