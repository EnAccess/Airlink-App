using Acr.UserDialogs;
using System;
using System.Collections.Generic;
using System.Net.Http;
using System.Text;
using System.Threading.Tasks;
using Xamarin.Forms.Xaml;
using Airlink.Views.Profile;

namespace Airlink.Services
{
    /*
     * Special class to POST data into IoT Engine! thingsboard.io
     */
    [XamlCompilation(XamlCompilationOptions.Compile)]

    public class PostData
    {
       
        public async static Task<bool> PostTelemetry(string contents)
        {
            HttpClient client = new HttpClient();

            StringContent content = new StringContent(contents, Encoding.UTF8, "application/json");
            string url = HttpsEndpoint.ApiEndPoint();
            if (string.IsNullOrEmpty(url))
            {
                UserDialogs.Instance.Alert("Please make sure the Tenant Token is not Empty", "");
            }
            else
            {

                var response = await client.PostAsync(url, content);
                //_ = UserDialogs.Instance.Alert("Posted Data", "");

                if (response.IsSuccessStatusCode)
                {
                    _ = UserDialogs.Instance.Toast("Successfully Posted Data");
                    ProfilePage.ServerOk = "Ok!";
                    return true;
                }
                else
                {
                    _ = UserDialogs.Instance.Alert("Failed to Post Data" + response.StatusCode, "");
                    ProfilePage.ServerOk = "Not Ok!";
                    return false;
                }
            }
            return false;
        }
    }
}
