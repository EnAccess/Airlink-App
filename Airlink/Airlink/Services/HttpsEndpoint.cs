using Airlink.Models.ProfileModel;
using SQLite;
using System;
using System.Collections.Generic;
using System.Text;
using Airlink.ViewModels.ProfileViewModel;
using Xamarin.Essentials;

namespace Airlink.Services
{
    /*
     * Special class to get Tenant Token and Endpoint API for communication
     */
    public class HttpsEndpoint
    {
        public static string ApiEndPoint()
        {
            var urlGetTask = SecureStorage.GetAsync("airlinkServer_url");
            var tokenGetTask = SecureStorage.GetAsync("timeSeries_token");
            string _endPointApi = urlGetTask.Result + tokenGetTask.Result;
            /*using (SQLiteConnection conn = new SQLiteConnection(App.DatabaseLocation))
            {
                var results =  conn.Table<TenantKeyModel>().ToList();
                foreach(var result in results)
                {
                    string api = result.BaseUrl;
                    string tkn = result.getTenantKeyToken();
                    _endPointApi = api + tkn;
                }
            }*/

            return _endPointApi;
        }
    }
}
