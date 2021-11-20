using Airlink.Views;
using Xamarin.Forms;

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
            //Routing.RegisterRoute(nameof(APIsPage), typeof(APIsPage));
            //Routing.RegisterRoute(nameof(SettingPage), typeof(SettingPage));
        }
    }
}