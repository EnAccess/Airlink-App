using Acr.UserDialogs;
using System;
using System.Collections.Generic;
using System.Net.Http;
using System.Text;
using System.Threading.Tasks;
using Xamarin.Forms.Xaml;
using Airlink.Views.Profile;
using System.Diagnostics;

namespace Airlink.Services
{
    /*
     * Special class to POST data into IoT Engine! thingsboard.io
     */
    [XamlCompilation(XamlCompilationOptions.Compile)]

    public class PostData
    {
       
        public async static Task<bool> PostToIoTServer(string contents, string deviceName, string postType)
        {
            HttpClient client = new HttpClient();

            StringContent content = new StringContent(contents, Encoding.UTF8, "application/json");
            string url = HttpsEndpoint.ApiEndPoint(postType, deviceName);
            if (string.IsNullOrEmpty(url))
            {
                UserDialogs.Instance.Alert("Please make sure the Server Information is not Empty", "");
            }
            else
            {

                var response = await client.PostAsync(url, content);
                //_ = UserDialogs.Instance.Alert("Posted Data", "");

                if (response.IsSuccessStatusCode)
                {
                    Debug.WriteLine("Successfully Posted to Server");
                    ProfilePage.ServerOk = "Ok!";
                    return true;
                }
                else
                {
                    Debug.WriteLine("Failed to Post to Server" + response.StatusCode, "");
                    ProfilePage.ServerOk = "Not Ok!";
                    return false;
                }
            }
            return false;
        }
    }
}
