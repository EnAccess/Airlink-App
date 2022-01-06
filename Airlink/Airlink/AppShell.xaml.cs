using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Xamarin.Forms;
using Xamarin.Forms.Xaml;
using Airlink.Views;
using Airlink.Views.Profile;
using Xamarin.Essentials;
using Acr.UserDialogs;
using Airlink.Views.Devices;

namespace Airlink
{
    public partial class AppShell : Xamarin.Forms.Shell
    {
        public AppShell()
        {
            InitializeComponent();

            //Register page for Navigation
            Routing.RegisterRoute(nameof(ScannedDetailsPage), typeof(ScannedDetailsPage));
            Routing.RegisterRoute(nameof(DevicePage), typeof(DevicePage));
            Routing.RegisterRoute(nameof(BarCodeScannerPage), typeof(BarCodeScannerPage));
            //Routing.RegisterRoute(nameof(APIsPage), typeof(APIsPage));
            //Routing.RegisterRoute(nameof(SettingPage), typeof(SettingPage));
        }
    }
}