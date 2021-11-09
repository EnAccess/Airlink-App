using Airlink.ViewModels;
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
            //saveKey = new Command(SaveCommand_Clicked);
            BindingContext = _detailModel = new BLEDeviceDetailsViewModel();
            MessagingCenter.Subscribe<App, string>((App)Application.Current, "UpdateDevID", (sender, arg) =>
            {
                //Debug.WriteLine("DEVICE TITLE: "+arg);
                DeviceTitle.Text = arg;
                var keyTask = SecureStorage.GetAsync("D_" + arg);
                Debug.WriteLine(arg + " is the title");
                if (keyTask.Result != null) { keyEntry.Text = keyTask.Result; }
            });

        }
        protected override void OnDisappearing()
        {
            base.OnDisappearing();
            _detailModel.OnDisappearingAsync();
        }
        public async void SaveCommand_Clicked(object sender, EventArgs e)
        {
            bool isKeyEmpty = string.IsNullOrEmpty(keyEntry.Text);

            if (isKeyEmpty)
            {
                await DisplayAlert("Error", "Please input key", "Ok");
            }
            else
            {
                _ = SecureStorage.SetAsync("D_" + DeviceTitle.Text, keyEntry.Text.ToString());
                //DisplayAlert("Key", keyEntry.Text.ToString(), "Ok");
            }
        }

    }
}