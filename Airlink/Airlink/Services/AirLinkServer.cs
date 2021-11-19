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
using Airlink.Models;
using Airlink.Models.ProvisionSpace;

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
        public async static Task<PostResponse> ProvisionDevice(string deviceName, string option)
        {
            string provisionKey;
            string provisionSecret;
            PostResponse provisionResponse;
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
            var postTask = PostToAirLinkServer(contents, deviceName, "provision").Result;
            provisionResponse.value = postTask.value;
            provisionResponse.status = postTask.status;
            if (provisionResponse.status)
                Debug.WriteLine("Provisioned Device " + deviceName);
            return provisionResponse;
        }

        public async static Task<PostResponse> PostToAirLinkServer(string contents, string deviceName, string postType)
        {
            PostResponse postResponse;
            HttpClient postClient = new HttpClient();

            StringContent content = new StringContent(contents, Encoding.UTF8, "application/json");
            string url = HttpsEndpoint.ApiEndPoint(postType, deviceName);
            if (string.IsNullOrEmpty(url))
            {
                UserDialogs.Instance.Alert("Please make sure the Server Information is not Empty", "");
            }
            else
            {

                var response = await postClient.PostAsync(url, content);
                //_ = UserDialogs.Instance.Alert("Posted Data", "");

                if (response.IsSuccessStatusCode)
                {
                    Debug.WriteLine("Successfully Posted to Server at "+url);//FIXME leaks device secret token to debug console
                    ProfilePage.ServerOk = "Ok!";
                    switch (postType)
                    {
                        case "provision": //FIXME not great that text tokens for the same variable are being used in two places - here and in HttpsEndpoint. Hard to maintain. Convert to global string tokens? make a class for post types, urls and return values?
                            //FIXME CRITICAL the response from server is different format than ProvisionResponse class defines if there's a failure! How to detect this? Create another class for failure string?
                            postResponse.value = ProvisionResponse.FromJson(response.Content.ReadAsStringAsync().Result).AccessToken;
                            postResponse.status = ProvisionResponse.FromJson(response.Content.ReadAsStringAsync().Result).Status=="SUCCESS";
                            break;
                        default:
                            postResponse.value = "";
                            postResponse.status = response.IsSuccessStatusCode;
                            break;
                    }
                    return postResponse;
                }
                else
                {
                    Debug.WriteLine("Failed to Post to Server" + response.StatusCode.ToString(), "");
                    ProfilePage.ServerOk = "Not Ok!";
                    postResponse.value = "";
                    postResponse.status = response.IsSuccessStatusCode;
                    return postResponse;
                }
            }
            postResponse.value = "";
            postResponse.status = false;
            return postResponse;
        }
    }
}
