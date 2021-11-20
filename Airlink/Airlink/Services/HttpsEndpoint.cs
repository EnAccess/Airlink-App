using Xamarin.Essentials;
using Xamarin.Forms.Xaml;

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
                    tokenGetTask = SecureStorage.GetAsync(deviceTokenKey); 
                    urlPostModifier = "/attributes/";
                    break;
                case "advtPost": //Advertising should be posted whether gateway owns device or not, to enable lost device recovery
                    urlPreModifier = "/api/v1/"; 
                    tokenGetTask = SecureStorage.GetAsync("gateway_auth");
                    urlPostModifier = "/telemetry/";
                    break;
                case "telemetry": //Telemetry only posted for gateway itself or the devices owned by the gateway, individually
                    urlPreModifier = "/api/v1/"; 
                    tokenGetTask = SecureStorage.GetAsync(deviceTokenKey); 
                    urlPostModifier = "/telemetry/";
                    break;
                case "provision": //Provisioning could be done by an agent of the company, so this function may be masked for clients
                    urlPreModifier = "/api/v1/";
                    tokenGetTask = null; // SecureStorage.GetAsync("dummykey");
                    urlPostModifier = "provision";
                    break;
                case "getAttributes":
                    urlPreModifier = "/api/v1/";
                    tokenGetTask = SecureStorage.GetAsync(deviceTokenKey);
                    urlPostModifier = "/attributes";
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
