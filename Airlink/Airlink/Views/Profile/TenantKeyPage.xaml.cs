
using Acr.UserDialogs;
using Airlink.Models.ProfileModel;
using Airlink.ViewModels.ProfileViewModel;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using Xamarin.Forms;
using Xamarin.Forms.Xaml;
using Xamarin.Essentials;

namespace Airlink.Views.Profile
{
    [XamlCompilation(XamlCompilationOptions.Compile)]
    public partial class APIsPage : ContentPage
    {
        TenantkeyViewModel tenantkeyViewModel { get; set; }
        public APIsPage()
        {
            InitializeComponent();
            BindingContext = new TenantkeyViewModel();
            var urlGetTask = SecureStorage.GetAsync("airlinkServer_url");
            var tokenGetTask = SecureStorage.GetAsync("timeSeries_token");
            if (urlGetTask.Result != null) { urlEntry.Text = urlGetTask.Result; } else { urlEntry.Text = "https://airlink.enaccess.org/api/v1/integrations/http/"; }
            if (tokenGetTask.Result != null) { tokenEntry.Text = tokenGetTask.Result; } else { tokenEntry.Text = "13fdd7a5-8ca8-8896-d489-62e808de6802"; } //FIXME Default, change to Test Tenant in future 

        }

        /*
         * Update End point APi with Tenant Key
         */
        private void SaveCommand_Clicked(object sender, EventArgs e)
        {
            bool isUrlEmpty = string.IsNullOrEmpty(urlEntry.Text);
            bool isTokenEmpty = string.IsNullOrEmpty(tokenEntry.Text);

            if(isUrlEmpty || isTokenEmpty)
            {
                DisplayAlert("Error", "Please fill all inputs", "Ok");
            }
            else
            {
                SecureStorage.SetAsync("timeSeries_token", tokenEntry.Text.ToString());
                SecureStorage.SetAsync("airlinkServer_url", urlEntry.Text.ToString());
                //DisplayAlert("Token", tokenEntry.Text.ToString(), "Ok");
                //DisplayAlert("URL", urlEntry.Text.ToString(), "Ok");
            }

        }
    }
}