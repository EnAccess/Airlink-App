using Acr.UserDialogs;
using System;
using System.Collections.Generic;
using System.Net.Http;
using System.Text;
using System.Threading.Tasks;
using Xamarin.Forms.Xaml;
using Airlink.Views.Profile;
using System.Diagnostics;
using Newtonsoft.Json;
using Xamarin.Essentials;
using Airlink.Models.ResourceModels;

namespace Airlink.Services
{
    /*
     * Special class to POST data into IoT Engine! thingsboard.io
     */
    [XamlCompilation(XamlCompilationOptions.Compile)]

    public class AirLinkServer
    {
        public async static Task<AirLinkDevice> GetFromAirLinkServer(string deviceName, string postType)
        {
            HttpClient getclient = new HttpClient();
            AirLinkDevice attributesFromServer;
            string url = HttpsEndpoint.ApiEndPoint(postType, deviceName);
            if (string.IsNullOrEmpty(url))
            {
                UserDialogs.Instance.Alert("Please make sure the Server Information is not Empty", "");
                return null;
            }
            else
            {
                getclient.DefaultRequestHeaders.Accept.Clear();
                var getTask = getclient.GetAsync(url);
                var response = getTask.Result;
                //Debug.WriteLine("GET response " + response.Content.ReadAsStringAsync().Result);
                if (response.IsSuccessStatusCode)
                {
                    Debug.WriteLine("Successfully got device attributes from Server");
                    ProfilePage.ServerOk = "Ok!"; //FIXME change to message? other? Doesn't seem to work
                    attributesFromServer = AirLinkDevice.FromJson(response.Content.ReadAsStringAsync().Result);
                    return attributesFromServer;  //FIXME add validations?
                }
                else
                {
                    Debug.WriteLine("Failed to Get from Server " + response.StatusCode.ToString(), "");
                    ProfilePage.ServerOk = "Not Ok!";
                    return null;
                }
            }
        }
        /*
         * Provision Gateway or Device
 1       */
        public async static Task<bool> ProvisionDevice(string deviceName, string option)
        {
            string provisionKey;
            string provisionSecret;
            if (option == "Device")
            {
                provisionKey = SecureStorage.GetAsync("deviceProvisionKey").Result;
                provisionSecret = SecureStorage.GetAsync("deviceProvisionSecret").Result;
            }
            else
            {
                provisionKey = SecureStorage.GetAsync("gatewayProvisionKey").Result;
                provisionSecret = SecureStorage.GetAsync("gatewayProvisionSecret").Result;
            }

            string contents = "{\"deviceName\": \"" + deviceName + "\", \"provisionDeviceKey\": \"" + provisionKey + "\", \"provisionDeviceSecret\": \"" + provisionSecret + "\"}";
            Debug.WriteLine("Provisioning " + contents); //FIXME will leak provisioning key and secret to Debug
            if (await AirLinkServer.PostToAirLinkServer(contents, deviceName, "provision"))
            {
                Debug.WriteLine("Provisioned Device " + deviceName);
                return true;
            }
            return false;
        }

        public async static Task<bool> PostToAirLinkServer(string contents, string deviceName, string postType)
        {
            HttpClient postclient = new HttpClient();

            StringContent content = new StringContent(contents, Encoding.UTF8, "application/json");
            string url = HttpsEndpoint.ApiEndPoint(postType, deviceName);
            if (string.IsNullOrEmpty(url))
            {
                UserDialogs.Instance.Alert("Please make sure the Server Information is not Empty", "");
            }
            else
            {

                var response = await postclient.PostAsync(url, content);
                //_ = UserDialogs.Instance.Alert("Posted Data", "");

                if (response.IsSuccessStatusCode)
                {
                    Debug.WriteLine("Successfully Posted to Server at "+url);//FIXME leaks device secret token to debug console
                    ProfilePage.ServerOk = "Ok!";
                    return true;
                }
                else
                {
                    Debug.WriteLine("Failed to Post to Server" + response.StatusCode.ToString(), "");
                    ProfilePage.ServerOk = "Not Ok!";
                    return false;
                }
            }
            return false;
        }
    }
}
