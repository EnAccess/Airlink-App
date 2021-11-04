using Acr.UserDialogs;
using Airlink.Models.ProfileModel;
using SQLite;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Text;
using Xamarin.Essentials;
using Xamarin.Forms.Xaml;

namespace Airlink.ViewModels.ProfileViewModel
{
    //[XamlCompilation(XamlCompilationOptions.Compile)]
    public class TenantkeyViewModel : INotifyPropertyChanged
    {

        public event PropertyChangedEventHandler PropertyChanged;
        protected virtual void OnPropertyChanged(string propertyName)
        {
            var changed = PropertyChanged;
            if(changed != null)
            {
                PropertyChanged(this, new PropertyChangedEventArgs(propertyName));
            }
        }
        public TenantkeyViewModel()
        {
            GetApiCredntials();
           
        }
        /*
         * Retrieve End point api and token from local database of the App
         */
        public void GetApiCredntials()
        {         
            /*using (SQLiteConnection conn = new SQLiteConnection(App.DatabaseLocation))
            {
                //Select the End point from a database
                conn.CreateTable<TenantKeyModel>();
                //conn.DeleteAll<TenantKeyModel>();
                var results = conn.Table<TenantKeyModel>().ToList();

                if (results.Count == 0)
                {
                    TenantKeyModel tenantKey = new TenantKeyModel
                    {
                        BaseUrl = "https://airlink.enaccess.org/api/v1/integrations/http/",
                        TenantToken = "Unknown"
                    };
                    conn.Insert(tenantKey);
                    Url = tenantKey.BaseUrl;
                    TenantKeyToken = tenantKey.TenantToken;
                }
                else
                {
                    foreach (var kev in results)
                    {
                        Url = kev.BaseUrl;
                        TenantKeyToken = kev.TenantToken;
                    }
                }
            }*/
        }

    }
}
