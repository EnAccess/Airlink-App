using Airlink.Models.AirlinkPAYG;
using Airlink.Services;
using Newtonsoft.Json;
using PeterO.Cbor;
using System;
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

            //UNUSED PIECE OF CODE
           //string jsonString = jcbor.ToJSONString();
           //var payg = JsonConvert.DeserializeObject<PUEPayGData>(jsonString);
           //
           //uint secondsSinceEpoch = (UInt32)t.TotalSeconds;
           //PUEPayGData pUEPayGData = new PUEPayGData
           //{
           //    UnsignedInt32 = 0,
           //    Str = "",
           //    UnsignedInt16 = 0,
           //    Arr = new byte[0]
           //
           //
           //};
            
            return ob;
        }
        
    }
}
