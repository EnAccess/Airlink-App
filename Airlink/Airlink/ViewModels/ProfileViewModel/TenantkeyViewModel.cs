using Acr.UserDialogs;
using Airlink.Models.ProfileModel;
using SQLite;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Text;

namespace Airlink.ViewModels.ProfileViewModel
{
   public class TenantkeyViewModel : INotifyPropertyChanged
    {
        string _url, _tenantKeyToken;
        public string Url 
        { get 
            { 
                return _url; 
            }
            set
            {
                if(_url != value)
                {
                    _url = value;
                    OnPropertyChanged("Url");
                }
            } 
        }

        public string TenantKeyToken 
        {
            get { return _tenantKeyToken; }

            set
            {
                if(_tenantKeyToken != value)
                {
                    _tenantKeyToken = value;
                    OnPropertyChanged("TenantKeyToken");
                }
            }
        }

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
            using (SQLiteConnection conn = new SQLiteConnection(App.DatabaseLocation))
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
            }
        }

    }
}
