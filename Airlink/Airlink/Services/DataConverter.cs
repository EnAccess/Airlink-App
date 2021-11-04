using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Xamarin.Forms.Xaml;

namespace Airlink.Services
{
    //[XamlCompilation(XamlCompilationOptions.Compile)]

    public class DataConverter
    {
        /*
      * Byte array to   Hexstring convertor
      */
        public static string BytesToHexString(byte[] ba)
        {

            return BitConverter.ToString(ba);

            //Another way of converting Byre to Hex string
            /*StringBuilder stringHex = new StringBuilder(ba.Length * 2);
            foreach (byte b in ba)
            {
                stringHex.AppendFormat("{0:x2}", b);
            }
            return stringHex.ToString();*/
        }
        /*
         * Convert Hext to Integer
         */
        public static int HexToInt(string hex)
        {

            return Convert.ToInt32(hex, 16);
        }
        /*
        * Byte array to   ASCII convertor
        */
        public static string BytesToASCII(byte[] ba)
        {

            return Encoding.ASCII.GetString(ba);

        }
        /*
         * Hexstring to Byte Array converter
         */
        public static byte[] StringToByteArray(string hex)
        {
            return Enumerable.Range(0, hex.Length)
                             .Where(x => x % 2 == 0)
                             .Select(x => Convert.ToByte(hex.Substring(x, 2), 16))
                             .ToArray();
        }
    }
}
