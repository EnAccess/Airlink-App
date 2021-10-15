using Acr.UserDialogs;
using System;
using System.Collections.Generic;
using System.Net.Http;
using System.Text;
using System.Threading.Tasks;

namespace Airlink.Services
{
    /*
     * Special class to POST data into IoT Engine! thingsboard.io
     */
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
               

                if (response.IsSuccessStatusCode)
                {
                    return true;
                }
                else
                {
                    return false;
                }
            }
            return false;
        }
    }
}
