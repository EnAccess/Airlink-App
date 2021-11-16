using Acr.UserDialogs;
using Airlink.Services;
using nexus.protocols.ble;
using System;
using Xamarin.Forms;
using Xamarin.Forms.Xaml;

namespace Airlink
{
    [XamlCompilation(XamlCompilationOptions.Compile)]
    public partial class App : Application
    {
        public static string DatabaseLocation = string.Empty;
        public App(IBluetoothLowEnergyAdapter adapter, IUserDialogs dialogs, string databaseLocation)
        {
            InitializeComponent();
            Device.SetFlags(new string[] { "Shapes_Experimental" });
            //Database Connection
            DatabaseLocation = databaseLocation;
            //Register ItemStore service , It stores all the scanned BLE devices temporary
            DependencyService.Register<ItemStore>();

            //Register MockPropertyDataStore Property Id , It stores Property ID only temporary
            DependencyService.Register<MockPropertyDataStore>();

            //Register MockAllPropertyDataStore Property , It stores Property only temporary
            DependencyService.Register<MockAllPropertyDataStore>();

            // Navigate to App shell
            MainPage = new AppShell();

            //Subscribes to the data send from the BluetoothlowEnergy adapter
            MessagingCenter.Subscribe<App, string>((App)global::Xamarin.Forms.Application.Current, "IBluetoothLowEnergyAdapterX", async (sender, arg) =>
            {
                MessagingCenter.Send<Airlink.App, IBluetoothLowEnergyAdapter>((Airlink.App)Xamarin.Forms.Application.Current, "SendAdapter", adapter);
            });
        }

        protected override void OnStart()
        {
        }

        protected override void OnSleep()
        {
        }

        protected override void OnResume()
        {
        }
    }
}
