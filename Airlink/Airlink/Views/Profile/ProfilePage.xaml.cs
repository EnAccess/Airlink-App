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
using Airlink.Models;
using System.Diagnostics;
using Airlink.Models.ProvisionSpace;
using Airlink.Models.PUEAdvert;

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
                RequestPhonePermission();
            }

            GetProvisiondata();
        }

        public async void RequestPhonePermission()
        {
            PermissionStatus status = await Permissions.CheckStatusAsync<Permissions.Phone>();
            if (status != PermissionStatus.Granted)
            {
                var permissionResult = await Permissions.RequestAsync<Permissions.Phone>();
                if (permissionResult != PermissionStatus.Granted)
                {
                    UserDialogs.Instance.Toast("Please Permit Phone Access");
                }
            }
            try
            {
                PhoneSerialNumberLabel.Text = DependencyService.Get<IMobile>().DeviceType().Trim() + " IMEI: " + DependencyService.Get<IMobile>().GetIdentifier().Trim();
            }
            catch (Exception ex)
            {
                PhoneSerialNumberLabel.Text = "IMEI: Did-not-get-IMEI";
                Debug.WriteLine("IMEI error: " + ex.Message);
            }
        }

        public async void GetProvisiondata()
        {
            var urlGetTask = await SecureStorage.GetAsync("airlinkServer_url");
            emailEntry.Text = await SecureStorage.GetAsync("emailEntry");
            passwordEntry.Text = await SecureStorage.GetAsync("passwordEntry");
            deviceProfileId.Text = await SecureStorage.GetAsync("deviceProfileId");
            gatewayProfileId.Text = await SecureStorage.GetAsync("gatewayProfileId");
            if (urlGetTask != null) { urlEntry.Text = urlGetTask; } else { urlEntry.Text = "https://airlink.enaccess.org"; }
        }

        private void SaveCommand_Clicked(object sender, EventArgs e)
        {
            bool isUrlEmpty = string.IsNullOrEmpty(urlEntry.Text);
            bool isEmailEntryEmpty = string.IsNullOrEmpty(emailEntry.Text);
            bool isPasswordEntryEmpty = string.IsNullOrEmpty(passwordEntry.Text);
            bool isDeviceProfileIdEmpty = string.IsNullOrEmpty(deviceProfileId.Text);
            bool isGatewayProfileIdEmpty = string.IsNullOrEmpty(gatewayProfileId.Text);

            if (isUrlEmpty || isEmailEntryEmpty || isPasswordEntryEmpty || isDeviceProfileIdEmpty || isGatewayProfileIdEmpty)
            {
                DisplayAlert("Error", "Please fill all inputs", "Ok");
            }
            else
            {
                urlEntry.Text = urlEntry.Text.ToString();
                emailEntry.Text = emailEntry.Text.ToString();
                passwordEntry.Text = passwordEntry.Text.ToString();
                deviceProfileId.Text = deviceProfileId.Text.ToString();
                gatewayProfileId.Text = gatewayProfileId.Text.ToString();

                SecureStorage.SetAsync("airlinkServer_url", urlEntry.Text.ToString());
                SecureStorage.SetAsync("emailEntry", emailEntry.Text.ToString());
                SecureStorage.SetAsync("passwordEntry", passwordEntry.Text.ToString());
                SecureStorage.SetAsync("deviceProfileId", deviceProfileId.Text.ToString());
                SecureStorage.SetAsync("gatewayProfileId", gatewayProfileId.Text.ToString());
            }

        }
        public async void GatewayProvisionCommand_Clicked(Object sender, EventArgs e)
        {
            try
            {
                await UserLoginJWTRequest();

                bool isGatewayProfileIdEmpty = string.IsNullOrEmpty(gatewayProfileId.Text);
                if (isGatewayProfileIdEmpty)
                {
                    await DisplayAlert("Error", "Please fill gateway provisioning inputs", "Ok");
                }
                else if (PhoneSerialNumberLabel.Text.Length < 5)
                {
                    await DisplayAlert("Error", "Phone serial number not known, cannot provision", "Ok");
                }
                else
                {
                    PostResponse response = await AirLinkServer.ProvisionDevice(PhoneSerialNumberLabel.Text.ToString(), "Gateway");


                    if (string.IsNullOrEmpty(response.status))
                    {
                        UserDialogs.Instance.HideLoading();
                        UserDialogs.Instance.Alert("Gateway provisioned successfully!", "SUCCESS!");
                    }
                    else
                    {
                        UserDialogs.Instance.HideLoading();
                        UserDialogs.Instance.Alert(response.message, $"Error {response.status}");
                    }
                }
            }
            catch (Exception ex)
            {
                Debug.WriteLine(ex.Message);
            }
        }

        public async Task UserLoginJWTRequest()
        {
            bool isUrlEmpty = string.IsNullOrEmpty(urlEntry.Text);
            bool isEmailEntryEmpty = string.IsNullOrEmpty(emailEntry.Text);
            bool isPasswordEntryEmpty = string.IsNullOrEmpty(passwordEntry.Text);

            if (isUrlEmpty || isEmailEntryEmpty || isPasswordEntryEmpty)
            {
                await DisplayAlert("Error", "Please fill in all the required fields.", "Ok");
            }
            else
            {
                var airlinkURL = await SecureStorage.GetAsync("airlinkServer_url");
                var email = await SecureStorage.GetAsync("emailEntry");
                var password = await SecureStorage.GetAsync("passwordEntry");

                JWTResponse jwtResponse = await UserLoginRequest.LoginRequest(airlinkURL, email, password);
                await SecureStorage.SetAsync("JWT Token", jwtResponse.token.ToString());
                await SecureStorage.SetAsync("JWT Refresh Token", jwtResponse.refreshToken.ToString());
            }
        }
    }
}