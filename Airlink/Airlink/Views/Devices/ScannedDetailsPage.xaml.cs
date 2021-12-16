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

    }
}