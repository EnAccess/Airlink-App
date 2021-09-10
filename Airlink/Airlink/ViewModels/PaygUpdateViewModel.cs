using Acr.UserDialogs;
using Airlink.Models;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.ComponentModel;
using System.Linq;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Text;
using System.Threading.Tasks;

namespace Airlink.ViewModels
{
    public class PaygUpdateViewModel : INotifyPropertyChanged
    {
        private static string _url = "https://private-177633-ziliczilic.apiary-mock.com/pu";

        private IUserDialogs _userDialogs;

        public event PropertyChangedEventHandler PropertyChanged;

        private ObservableCollection<PaygUpdate> _payUpdate;
        public ObservableCollection<PaygUpdate> PayUpdate
        {
            get { return _payUpdate; }
            set { _payUpdate = value; PropertyChanged?.Invoke(this, new PropertyChangedEventArgs("PayUpdate")); }
        }

        public PaygUpdateViewModel()
        {
           
        }

        public async Task<ObservableCollection<PaygUpdate>> GetUpdate()
        {
            try
            {
                HttpClient client = new HttpClient();

                HttpResponseMessage response = await client.GetAsync(_url);

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
        public async Task<ObservableCollection<PaygUpdate>> PostUpdate()
        {
            try
            {
                HttpClient client = new HttpClient();

                StringContent content = new StringContent(JsonConvert.SerializeObject(PayUpdate), Encoding.UTF8, "application/json");

                var response = await client.PostAsync(_url,content);
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
        public async void OnAppering()
        {
         
           var result = await GetUpdate();

            if(result != null)
            {
                PayUpdate = result;
              
            }
            var status = await PostUpdate();

            if (status != null)
            {
                UserDialogs.Instance.Alert($"Done {status}");
            }
        }
    }
}
