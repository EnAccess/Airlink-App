using System;
using System.Collections.Generic;
using System.Net.Http;
using System.Text;
using System.Threading.Tasks;

namespace Airlink.Services
{
  public  class PostData
    {
        //Method to post data to Cloud 
        public static string Baseurl = "https://airlink.enaccess.org/api/v1/integrations/http";
        public async static Task<bool> PostTelemetry(string contents)
        {
            HttpClient client = new HttpClient();

            StringContent content = new StringContent(contents, Encoding.UTF8, "application/json");

            var response = await client.PostAsync(Baseurl, content);

            if (response.IsSuccessStatusCode)
            {
                return true;
            }else
            {
                return false;
            }
        }
    }
}
