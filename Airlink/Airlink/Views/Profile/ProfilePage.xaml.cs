using Airlink.ViewModels;
using Airlink.Services;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Input;
using Xamarin.Essentials;
using Xamarin.Forms;
using Xamarin.Forms.Xaml;
using Acr.UserDialogs;

namespace Airlink.Views.Profile
{
    [XamlCompilation(XamlCompilationOptions.Compile)]
    public partial class ProfilePage : ContentPage
    {

        public ProfilePage()
        {
            InitializeComponent();
            BindingContext = new ProfilePageViewModel();
            // IMEI Permission
            if (Device.RuntimePlatform == Device.Android)
            {
                PermissionStatus status = Permissions.CheckStatusAsync<Permissions.Phone>().Result;
                if (status != PermissionStatus.Granted)
                {
                    var permissionResult = Permissions.RequestAsync<Permissions.Phone>().Result;
                    if (permissionResult != PermissionStatus.Granted)
                    {
                        UserDialogs.Instance.Toast("Please Permit Phone Access");
                    }
                }
            }
            //ServerOKLabel.BindingContext = ServerOk;
            //ServerOKLabel.SetBinding(Label.TextProperty, ServerOk);
            PhoneSerialNumberLabel.Text = "Phone IMEI: " + DependencyService.Get<IMobile>().GetIdentifier().Trim();

            var urlGetTask = SecureStorage.GetAsync("airlinkServer_url");
            deviceProvisioningKeyEntry.Text = SecureStorage.GetAsync("deviceProvisionKey").Result;
            deviceProvisioningSecretEntry.Text = SecureStorage.GetAsync("deviceProvisionSecret").Result;
            gatewayProvisioningKeyEntry.Text = SecureStorage.GetAsync("gatewayProvisionKey").Result;
            gatewayProvisioningSecretEntry.Text = SecureStorage.GetAsync("gatewayProvisionSecret").Result;
            //var tokenGetTask = SecureStorage.GetAsync("appServerChannel_token");
            var gAuthGetTask = SecureStorage.GetAsync("gateway_auth");
            if (urlGetTask.Result != null) { urlEntry.Text = urlGetTask.Result; } else { urlEntry.Text = "https://airlink.enaccess.org/api/v1/integrations/http/"; }
            //if (tokenGetTask.Result != null) { tokenEntry.Text = tokenGetTask.Result; } else { tokenEntry.Text = "13fdd7a5-8ca8-8896-d489-62e808de6802"; } //FIXME Default, change to Test Tenant in future 
            if (gAuthGetTask.Result != null) { gAuthEntry.Text = gAuthGetTask.Result; } else { gAuthEntry.Text = "123456"; } //FIXME 
        }
        public static string ServerOk = "...";
        public static bool TestDevice = false;
        private void InsertTestDevice(object sender, EventArgs e)
        {
            if (TestDeviceInsert.IsToggled) TestDevice = true;
            else TestDevice = false;
        }
        private void SaveCommand_Clicked(object sender, EventArgs e)
        {
            bool isUrlEmpty = string.IsNullOrEmpty(urlEntry.Text);
            bool isDpkEmpty = string.IsNullOrEmpty(deviceProvisioningKeyEntry.Text);
            bool isDpsEmpty = string.IsNullOrEmpty(deviceProvisioningSecretEntry.Text);
            bool isGpkEmpty = string.IsNullOrEmpty(gatewayProvisioningKeyEntry.Text);
            bool isGpsEmpty = string.IsNullOrEmpty(gatewayProvisioningSecretEntry.Text);
            //bool isTokenEmpty = string.IsNullOrEmpty(tokenEntry.Text);
            bool isGAuthEmpty = string.IsNullOrEmpty(gAuthEntry.Text);

            if (isUrlEmpty || isDpkEmpty || isDpsEmpty || isGpkEmpty || isGpsEmpty || isGAuthEmpty)
            {
                DisplayAlert("Error", "Please fill all inputs", "Ok");
            }
            else
            {
                //SecureStorage.SetAsync("appServerChannel_token", tokenEntry.Text.ToString());
                SecureStorage.SetAsync("airlinkServer_url", urlEntry.Text.ToString());
                SecureStorage.SetAsync("deviceProvisionKey", deviceProvisioningKeyEntry.Text.ToString());
                SecureStorage.SetAsync("deviceProvisionSecret", deviceProvisioningSecretEntry.Text.ToString());
                SecureStorage.SetAsync("gatewayProvisionKey", gatewayProvisioningKeyEntry.Text.ToString());
                SecureStorage.SetAsync("gatewayProvisionSecret", gatewayProvisioningSecretEntry.Text.ToString());
                SecureStorage.SetAsync("gateway_auth", gAuthEntry.Text.ToString());
                ServerOk = "...";
                //DisplayAlert("Token", tokenEntry.Text.ToString(), "Ok");
                //DisplayAlert("URL", urlEntry.Text.ToString(), "Ok");
            }

        }

    }
}