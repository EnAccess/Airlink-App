using Airlink.Models.ProfileModel;
using System;
using System.Collections.Generic;
using System.Text;
using Airlink.ViewModels.ProfileViewModel;
using Xamarin.Essentials;
using Xamarin.Forms.Xaml;
using System.Diagnostics;

namespace Airlink.Services
{
    /*
     * Special class to get Tenant Token and Endpoint API for communication
     */
    [XamlCompilation(XamlCompilationOptions.Compile)]

    public class HttpsEndpoint
    {
        public static string ApiEndPoint(string urlType, string deviceName)
        {
            System.Threading.Tasks.Task<string> urlGetTask = SecureStorage.GetAsync("airlinkServer_url");
            System.Threading.Tasks.Task<string> tokenGetTask = null;
            string urlPreModifier;
            string urlPostModifier;
            string deviceTokenKey = "D_" + deviceName;
            switch (urlType)
            {
                case "attributes": //Attributes are not telemetry! They're telemetry without time-series history so 'configuration'
                    urlPreModifier = "/api/v1/"; 
                    tokenGetTask = SecureStorage.GetAsync("deviceAccessToken");
                    urlPostModifier = "/attributes/";
                    break;
                case "advtPost": //Advertising should be posted whether gateway owns device or not, to enable lost device recovery
                    urlPreModifier = "/api/v1/";
                    tokenGetTask = SecureStorage.GetAsync("gatewayAccessToken");
                    urlPostModifier = "/telemetry/";
                    break;
                case "telemetry": //Telemetry only posted for gateway itself or the devices owned by the gateway, individually
                    urlPreModifier = "/api/v1/"; 
                    tokenGetTask = SecureStorage.GetAsync("deviceAccessToken");
                    urlPostModifier = "/telemetry/";
                    break;
                case "provisionDevice": //Provisioning could be done by an agent of the company, so this function may be masked for clients
                    urlPreModifier = "/api/device?accessToken=";
                    tokenGetTask = SecureStorage.GetAsync("deviceAccessToken");
                    urlPostModifier = null;
                    break;
                case "provisionGateway": //Provisioning could be done by an agent of the company, so this function may be masked for clients
                    urlPreModifier = "/api/device?accessToken=";
                    tokenGetTask = SecureStorage.GetAsync("gatewayAccessToken");
                    urlPostModifier = null;
                    break;
                case "getAttributes":
                    urlPreModifier = "/api/v1/";
                    tokenGetTask = SecureStorage.GetAsync(deviceTokenKey);
                    urlPostModifier = "/attributes";
                    break;
                case "serverScope":
                    urlPreModifier = "/api/plugins/telemetry/DEVICE/";
                    tokenGetTask = SecureStorage.GetAsync("deviceUUID");
                    urlPostModifier = "/SERVER_SCOPE";
                    break;
                default:
                    urlPreModifier = "";
                    urlPostModifier = "";
                    break;
            }
            string token = (tokenGetTask == null) ? "" : tokenGetTask.Result;
            string _endPointApi = urlGetTask.Result + urlPreModifier + token + urlPostModifier;
            return _endPointApi;
        }
    }
}
