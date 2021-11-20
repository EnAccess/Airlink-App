using System;
using Acr.UserDialogs;
using Airlink.Models;
using Airlink.Services;
using Airlink.ViewModels;
using Xamarin.Essentials;
using Xamarin.Forms;
using Xamarin.Forms.Xaml;

namespace Airlink.Views.Profile
{
    [XamlCompilation(XamlCompilationOptions.Compile)]
    public partial class ProfilePage : ContentPage //FIXME should a lot of the logic in the initialize and button commands on this page be in the profile page view model class?
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
            //ServerOKLabel.BindingContext = ServerOk; //FIXME Server status functionality is incomplete
            //ServerOKLabel.SetBinding(Label.TextProperty, ServerOk);
            PhoneSerialNumberLabel.Text = DependencyService.Get<IMobile>().DeviceType().Trim() + " IMEI: " + DependencyService.Get<IMobile>().GetIdentifier().Trim();

            var urlGetTask = SecureStorage.GetAsync("airlinkServer_url");
            deviceProvisioningKeyEntry.Text = SecureStorage.GetAsync("deviceProvisionKey").Result;
            deviceProvisioningSecretEntry.Text = SecureStorage.GetAsync("deviceProvisionSecret").Result;
            gatewayProvisioningKeyEntry.Text = SecureStorage.GetAsync("gatewayProvisionKey").Result;
            gatewayProvisioningSecretEntry.Text = SecureStorage.GetAsync("gatewayProvisionSecret").Result;
            var gAuthGetTask = SecureStorage.GetAsync("gateway_auth");
            if (urlGetTask.Result != null) { urlEntry.Text = urlGetTask.Result; } else { urlEntry.Text = "https://airlink.enaccess.org/api/v1/integrations/http/"; }
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
            bool isGAuthEmpty = string.IsNullOrEmpty(gAuthEntry.Text);

            if (isUrlEmpty || isDpkEmpty || isDpsEmpty || isGpkEmpty || isGpsEmpty || isGAuthEmpty)
            {
                DisplayAlert("Error", "Please fill all inputs", "Ok");
            }
            else
            {
                SecureStorage.SetAsync("airlinkServer_url", urlEntry.Text.ToString());
                SecureStorage.SetAsync("deviceProvisionKey", deviceProvisioningKeyEntry.Text.ToString());
                SecureStorage.SetAsync("deviceProvisionSecret", deviceProvisioningSecretEntry.Text.ToString());
                SecureStorage.SetAsync("gatewayProvisionKey", gatewayProvisioningKeyEntry.Text.ToString());
                SecureStorage.SetAsync("gatewayProvisionSecret", gatewayProvisioningSecretEntry.Text.ToString());
                SecureStorage.SetAsync("gateway_auth", gAuthEntry.Text.ToString());
                ServerOk = "..."; //FIXME Server status functionality is incomplete
            }

        }
        void GatewayProvisionCommand_Clicked(System.Object sender, System.EventArgs e)
        {
            bool isGpkEmpty = string.IsNullOrEmpty(gatewayProvisioningKeyEntry.Text);
            bool isGpsEmpty = string.IsNullOrEmpty(gatewayProvisioningSecretEntry.Text);
            if (isGpkEmpty || isGpsEmpty)
            {
                DisplayAlert("Error", "Please fill gateway provisioning inputs", "Ok");
            }
            else if (PhoneSerialNumberLabel.Text.Length < 5)
            {
                DisplayAlert("Error", "Phone serial number not known, cannot provision", "Ok");
            }
            else
            {
                PostResponse postResponse = AirLinkServer.ProvisionDevice(PhoneSerialNumberLabel.Text.ToString(), "Gateway").Result;
                SecureStorage.SetAsync("gateway_auth", postResponse.value);
                gAuthEntry.Text = postResponse.value;
            }
        }
    }
}