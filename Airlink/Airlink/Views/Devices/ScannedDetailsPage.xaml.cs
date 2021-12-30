using Airlink.ViewModels;
using Airlink.Services;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using Xamarin.Forms;
using Xamarin.Forms.Xaml;
using Xamarin.Essentials;
using System.Windows.Input;
using System.Diagnostics;
using Airlink.Models;
using Acr.UserDialogs;
using Airlink.Models.PUEAdvert;
using PeterO.Cbor;
using Plugin.BLE;
using nexus.core.text;
using nexus.core;

namespace Airlink.Views
{
    [XamlCompilation(XamlCompilationOptions.Compile)]
    public partial class ScannedDetailsPage : ContentPage
    {
        BLEDeviceDetailsViewModel _detailModel;
        //public ICommand saveKey { get; } 
        public ScannedDetailsPage()
        {
            InitializeComponent();
            //saveKey = new Command(SyncCommand_Clicked);
            BindingContext = _detailModel = new BLEDeviceDetailsViewModel();
            MessagingCenter.Subscribe<App, string>((App)Application.Current, "UpdateDevID", (sender, arg) =>
            {
                //Debug.WriteLine("DEVICE TITLE: "+arg);
                DeviceTitle.Text = arg;
                var keyTask = SecureStorage.GetAsync("D_" + arg);
                if (keyTask.Result != null) { accTokenEntry.Text = keyTask.Result; }
            });

        }


        protected override void OnDisappearing()
        {
            _detailModel.OnDisappearingAsync();
        }

        public void SyncCommand_Clicked(object sender, EventArgs e)
        {
            _detailModel.GetServerAttributes();
        }
        public async void DeviceProvisionCommand_Clicked(object sender, EventArgs e)
        {
            try
            {
                PostResponse provisionResponse = await AirLinkServer.ProvisionDevice(DeviceTitle.Text, "Device");
                if (provisionResponse.status)
                    await SecureStorage.SetAsync("D_" + DeviceTitle.Text, provisionResponse.value);
                accTokenEntry.Text = provisionResponse.value;

            }
            catch (Exception ex)
            {
                Debug.WriteLine(ex.Message);
            }

        }
        public async void SaveCommand_Clicked(object sender, EventArgs e)
        {
            bool isKeyEmpty = string.IsNullOrEmpty(accTokenEntry.Text);

            if (isKeyEmpty)
            {
                await DisplayAlert("Error", "Please input key", "Ok");
            }
            else
            {
                _ = SecureStorage.SetAsync("D_" + DeviceTitle.Text, accTokenEntry.Text.ToString());
                //DisplayAlert("Key", keyEntry.Text.ToString(), "Ok");
            }
        }

        public void EnterTokenBtn(object sender, EventArgs e)
        {
            EnterToken();
        }

        /* Function to prompt a dialog to user to enter payG token and save 
        it to a secure storage */
        public async void EnterToken()
        {
            string result = await DisplayPromptAsync("Token", "Enter your token:", accept: "Enter", placeholder: "*59979149319443#");
            if (result != null)
            {
                try
                {
                    string payGtoken = result.Trim().Replace(" ", "");
                    await SecureStorage.SetAsync("PayG Token", payGtoken);

                    //Current time in Unix timestamp
                    DateTime foo = DateTime.Now;
                    long unixTime = ((DateTimeOffset)foo).ToUnixTimeSeconds();

                    var token = await SecureStorage.GetAsync("PayG Token");
                    string jsonData = "{\"" + "PC_tkn" + "\" : \"" + token + "\", \"" + "PC_lt" + "\" : " + unixTime + "}";
                    _detailModel.WriteToResource(jsonData); 

                    //FIXME: call a function to write this data to a particular resource
                }
                catch (Exception ex)
                {
                    Debug.WriteLine("Secure storage Error: " + ex.Message);
                }
            }
            else
            {
                Debug.WriteLine("Nothing was entered.");
                return;
            }

        }
    }
}