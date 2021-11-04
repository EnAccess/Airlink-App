using Airlink.Models.ProfileModel;
using System;
using System.Collections.Generic;
using System.Text;
using Airlink.ViewModels.ProfileViewModel;
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
        public static string ApiEndPoint()
        {
            var urlGetTask = SecureStorage.GetAsync("airlinkServer_url");
            var tokenGetTask = SecureStorage.GetAsync("timeSeries_token");
            string _endPointApi = urlGetTask.Result + tokenGetTask.Result;
            return _endPointApi;
        }
    }
}
