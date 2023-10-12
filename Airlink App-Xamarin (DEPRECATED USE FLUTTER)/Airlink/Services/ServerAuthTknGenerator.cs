using System;
using System.Collections.Generic;
using System.Text;
using Xamarin.Essentials;

namespace Airlink.Services
{
    public class ServerAuthTknGenerator
    {
		//Generate Server Auth Token of 20 characters long and save it to SecureStorage
        public static void GenerateSAT(string provisionType)
        {
			var chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
			var stringChars = new char[20];
			var random = new Random();
			for (int i = 0; i < stringChars.Length; i++)
			{
				stringChars[i] = chars[random.Next(chars.Length)];
			}

			var finalString = new string(stringChars);

			if(provisionType == "device")
            {
				SecureStorage.SetAsync("deviceAccessToken", finalString);
			}
			else
            {
				SecureStorage.SetAsync("gatewayAccessToken", finalString);
			}
			
		}
    }
}
