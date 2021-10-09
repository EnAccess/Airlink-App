using Airlink.Models.ProfileModel;
using SQLite;
using System;
using System.Collections.Generic;
using System.Text;

namespace Airlink.Services
{
    /*
     * Special class to get Tenant Token and Endpoint API for communication
     */
    public class HttpsEndpoint
    {
        public static string ApiEndPoint()
        {
            string _endPointApi = "";
            using (SQLiteConnection conn = new SQLiteConnection(App.DatabaseLocation))
            {
                var results =  conn.Table<TenantKeyModel>().ToList();
                foreach(var result in results)
                {
                    string api = result.BaseUrl;
                    string tkn = result.TenantToken;
                    _endPointApi = api + tkn;
                }
            }
            
            return _endPointApi;
        }
    }
}
