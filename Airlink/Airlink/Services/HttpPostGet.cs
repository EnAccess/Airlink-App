using Airlink.Models;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Net.Http;
using System.Text;
using System.Threading.Tasks;

namespace Airlink.Services
{
   public class HttpPostGet
    {
        
        public async Task<ObservableCollection<PaygUpdate>> GetUpdate(string url)
        {
            try
            {
                HttpClient client = new HttpClient();

                HttpResponseMessage response = await client.GetAsync(url);

                if (response.StatusCode == System.Net.HttpStatusCode.OK)
                {
                    var result = await response.Content.ReadAsStringAsync();

                    var json = JsonConvert.DeserializeObject<ObservableCollection<PaygUpdate>>(result);

                    return json;
                }
            }
            catch (Exception)
            {


                return null;
            }


            return null;
        }
        public async Task<ObservableCollection<PaygUpdate>> PostUpdate(string url, string data)
        {
            try
            {
                HttpClient client = new HttpClient();

                StringContent content = new StringContent(JsonConvert.SerializeObject(data), Encoding.UTF8, "application/json");

                var response = await client.PostAsync(url, content);
                if (response.IsSuccessStatusCode)
                {
                    var result = JsonConvert.DeserializeObject<ObservableCollection<PaygUpdate>>(await response.Content.ReadAsStringAsync());
                    return result;
                }
            }
            catch (Exception)
            {


                return null;
            }


            return null;
        }
    }
}
