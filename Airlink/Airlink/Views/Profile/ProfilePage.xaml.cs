using Airlink.ViewModels;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Input;
using Xamarin.Essentials;
using Xamarin.Forms;
using Xamarin.Forms.Xaml;

namespace Airlink.Views.Profile
{
    [XamlCompilation(XamlCompilationOptions.Compile)]
    public partial class ProfilePage : ContentPage
    {

        public ProfilePage()
        {
            InitializeComponent();
            BindingContext = new ProfilePageViewModel();
            //ServerOKLabel.BindingContext = ServerOk;
            //ServerOKLabel.SetBinding(Label.TextProperty, ServerOk);
            var urlGetTask = SecureStorage.GetAsync("airlinkServer_url");
            var tokenGetTask = SecureStorage.GetAsync("timeSeries_token");
            var gAuthGetTask = SecureStorage.GetAsync("gateway_auth");
            if (urlGetTask.Result != null) { urlEntry.Text = urlGetTask.Result; } else { urlEntry.Text = "https://airlink.enaccess.org/api/v1/integrations/http/"; }
            if (tokenGetTask.Result != null) { tokenEntry.Text = tokenGetTask.Result; } else { tokenEntry.Text = "13fdd7a5-8ca8-8896-d489-62e808de6802"; } //FIXME Default, change to Test Tenant in future 
            if (gAuthGetTask.Result != null) { gAuthEntry.Text = gAuthGetTask.Result; } else { gAuthEntry.Text = "123456"; } //FIXME 
        }
        public static string ServerOk = "...";
        private void SaveCommand_Clicked(object sender, EventArgs e)
        {
            bool isUrlEmpty = string.IsNullOrEmpty(urlEntry.Text);
            bool isTokenEmpty = string.IsNullOrEmpty(tokenEntry.Text);
            bool isGAuthEmpty = string.IsNullOrEmpty(gAuthEntry.Text);

            if (isUrlEmpty || isTokenEmpty || isGAuthEmpty)
            {
                DisplayAlert("Error", "Please fill all inputs", "Ok");
            }
            else
            {
                SecureStorage.SetAsync("timeSeries_token", tokenEntry.Text.ToString());
                SecureStorage.SetAsync("airlinkServer_url", urlEntry.Text.ToString());
                SecureStorage.SetAsync("gateway_auth", gAuthEntry.Text.ToString());
                ServerOk = "...";
                //DisplayAlert("Token", tokenEntry.Text.ToString(), "Ok");
                //DisplayAlert("URL", urlEntry.Text.ToString(), "Ok");
            }

        }

    }
}