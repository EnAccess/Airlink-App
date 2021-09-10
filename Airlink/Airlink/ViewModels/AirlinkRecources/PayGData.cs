using Airlink.Models.AirlinkPAYG;
using Airlink.Services;
using Newtonsoft.Json;
using PeterO.Cbor;
using SQLite;
using System;
using System.Collections.Generic;
using System.Text;
using System.Threading.Tasks;

namespace Airlink.ViewModels
{
   public class PayGData
    {
        /*
         * Decode Cbordata read from the Property
         */
        public static async Task<string> ReadDataFromBLEAysnc(string hex)
        {
            byte[] cbor = DataConverter.StringToByteArray(hex);
            TimeSpan t = DateTime.Now - new DateTime(1970, 1, 1);
            var jcbor = CBORObject.DecodeFromBytes(cbor);
            var ob = jcbor.ToString();

            string jsonString = jcbor.ToJSONString();
            var payg = JsonConvert.DeserializeObject<PUEPayGData>(jsonString);

            int secondsSinceEpoch = (int)t.TotalSeconds;
            PUEPayGData pUEPayGData = new PUEPayGData
            {
                Rv = "0123456789",
                Re = "10",
                Mo = "Leading",
                Tkn = "1234560789",
                Lcr = "40",
                Ts = "1631261161",
                Lts = "1631261161",
                Lt = secondsSinceEpoch.ToString()
            };
            
            return ob;
        }
        /*
         * Pass the PUEPAYG Data to write to the Bluetooth Property
         */
        public static async Task<string> SendDataToBLEAsync()
        {
            TimeSpan t = DateTime.Now - new DateTime(1970, 1, 1);
            int secondsSinceEpoch = (int)t.TotalSeconds;
            PUEPayGData pUEPayGData = new PUEPayGData
            {
                Rv = "0123456789",
                Re = "10",
                Mo = "Leading",
                Tkn = "1234560789",
                Lcr = "40",
                Ts = "1631261161",
                Lts = "1631261161",
                Lt = secondsSinceEpoch.ToString()
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
                            .Add("rv",data.Rv)
                            .Add("re",data.Re)
                            .Add("mo",data.Mo)
                            .Add("tkn",data.Tkn)
                            .Add("lcr",data.Lcr)
                            .Add("ts",data.Ts)
                            .Add("lts",data.Lts)
                            .Add("lt",data.Lt);

                    byte[] bytes = SendCbor.EncodeToBytes();
                    // PUEAd.Add(x);
                    var cborHexstring = DataConverter.BytesToHexString(bytes);
                    cborHexstring = cborHexstring.Replace("-", "");
                    SendCbor.Add("cbor", cborHexstring);
                    var contents = SendCbor.ToJSONString();
                    var result = SendCbor.ToString();
                    //post data to IoT Engine
                    if (await PostData.PostTelemetry(contents))
                    {
                        //Delete data from a local database
                        con.Delete<PUEPayGData>(data.Id);
                    }
                    return result;
                }
            }
            return null;
        }
    }
}
