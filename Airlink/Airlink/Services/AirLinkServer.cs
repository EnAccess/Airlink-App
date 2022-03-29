using Acr.UserDialogs;
using System.Net.Http;
using System.Text;
using System.Threading.Tasks;
using Xamarin.Forms.Xaml;
using Airlink.Views.Profile;
using System.Diagnostics;
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

        
        //Provision Gateway or Device
        public async static Task<PostResponse> ProvisionDevice(string deviceName, string option)
        {
            UserDialogs.Instance.ShowLoading("Provisioning, please wait...");
            string profileId;
            string profileType;
            string postType;
            
            if (option == "Device")
            {
                ServerAuthTknGenerator.GenerateSAT("device");
                postType = "provisionDevice";
                profileId = await SecureStorage.GetAsync("deviceProfileId");
                profileType = "Devices Profile";
            }
            else
            {
                ServerAuthTknGenerator.GenerateSAT("gateway");
                postType = "provisionGateway";
                profileId = await SecureStorage.GetAsync("gatewayProfileId");
                profileType = "Gateways Profile";
            }

            string contents = "{\"name\" : \"" + deviceName + "\", \"type\" : \"" + profileType + "\", \"deviceProfileId\" : {\"id\": \"" + profileId + "\", \"entityType\": " + "\"" + "DEVICE_PROFILE" + "\"}}";

            PostResponse postResponse = await PostToAirLinkServer(contents, deviceName, postType);

            postResponse.status = postResponse.status.ToString();
            postResponse.message = postResponse.message.ToString();

            if (option == "Device")
            {
                postResponse.deviceUUID = postResponse.deviceUUID.ToString();
                await SecureStorage.SetAsync("deviceUUID", postResponse.deviceUUID);
            }
                
            return postResponse;

        }

        public async static Task<PostResponse> PostToAirLinkServer(string contents, string deviceName, string postType)
        {
            PostResponse postResponse;

            HttpClient postClient = new HttpClient();

            string JWTToken = await SecureStorage.GetAsync("JWT Token");

            postClient.DefaultRequestHeaders.Add("X-Authorization", $"Bearer {JWTToken}");

            StringContent content = new StringContent(contents, Encoding.UTF8, "application/json");
            string url = HttpsEndpoint.ApiEndPoint(postType, deviceName);
            Debug.WriteLine(url);

            if (string.IsNullOrEmpty(url))
            {
                UserDialogs.Instance.Alert("Please make sure the Server Information is not Empty", "");
            }
            else
            {
                var response = await postClient.PostAsync(url, content);

                if (response.IsSuccessStatusCode)
                {
                    if(postType == "telemetry")
                    {
                        postResponse.status = "";
                        postResponse.message = "";
                        postResponse.deviceUUID = "";

                        return postResponse;
                    }
                    if (postType == "serverScope")
                    {
                        postResponse.status = "";
                        postResponse.message = "";
                        postResponse.deviceUUID = "";

                        return postResponse;
                    }

                    postResponse.status = "";
                    postResponse.message = "";
                    postResponse.deviceUUID = ProvisionResponse.FromJson(await response.Content.ReadAsStringAsync()).Id.Id.ToString();
                    
                    return postResponse;
                }
                else
                {
                    postResponse.status = ProvisionResponse.FromJson(await response.Content.ReadAsStringAsync()).Status;
                    postResponse.message = ProvisionResponse.FromJson(await response.Content.ReadAsStringAsync()).Message;
                    postResponse.deviceUUID = "";
                    return postResponse; 
                }
            }
            postResponse.status = "";
            postResponse.message = "";
            postResponse.deviceUUID = "";
            return postResponse;
        }
    }
}
