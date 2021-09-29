﻿
using Android.App;
using Android.Content.PM;
using Android.Runtime;
using Android.OS;
using nexus.protocols.ble;
using Acr.UserDialogs;
using System.Drawing;
using Xamarin.Forms;
using Android.Content;
using Airlink.Services;
using Xamarin.Essentials;
using Color = Xamarin.Forms.Color;
using System.IO;

namespace Airlink.Droid
{
    [Activity(Label = "Airlink", Icon = "@mipmap/icon", Theme = "@style/MainTheme", MainLauncher = true, ConfigurationChanges = ConfigChanges.ScreenSize | ConfigChanges.Orientation | ConfigChanges.UiMode | ConfigChanges.ScreenLayout | ConfigChanges.SmallestScreenSize )]
    public class MainActivity : global::Xamarin.Forms.Platform.Android.FormsAppCompatActivity
    {
        private BleServer _bleServer;
        protected override void OnCreate(Bundle savedInstanceState)
        {
            TabLayoutResource = Resource.Layout.Tabbar;
            ToolbarResource = Resource.Layout.Toolbar;

            base.OnCreate(savedInstanceState);

            Forms.SetFlags("Expander_Experimental");
            Platform.Init(this, savedInstanceState);
            Forms.Init(this, savedInstanceState);
            Rg.Plugins.Popup.Popup.Init(this);
            UserDialogs.Init(this);

            // Android Bluetooth GATT
            _bleServer = new BleServer(this.ApplicationContext);

            // use ble.net-android nuget package to load application context 
            var bluetooth = BluetoothLowEnergyAdapter.ObtainDefaultAdapter(ApplicationContext);

            string dbName = "airlink_db.sqlite";
            string folderPath = System.Environment.GetFolderPath(System.Environment.SpecialFolder.Personal);
            string fullPath = Path.Combine(folderPath, dbName);

            LoadApplication(new App(bluetooth, UserDialogs.Instance,fullPath));

       /* 
       *status Bar Color
       */
            var e = DependencyService.Get<IEnvironment>();

            e?.SetStautsBarColor(Color.FromHex("#660099"), true);
            /* 
             *End of status bar color
             */

            //starting the Background service
            StartService();
        }

        private void StartService()
        {
            // Load BackgroundService 
            var intent = new Intent(this, typeof(BackgroundService));

            StartForegroundService(intent);
        }
        public override void OnRequestPermissionsResult(int requestCode, string[] permissions, [GeneratedEnum] Android.Content.PM.Permission[] grantResults)
        {
            Xamarin.Essentials.Platform.OnRequestPermissionsResult(requestCode, permissions, grantResults);

            base.OnRequestPermissionsResult(requestCode, permissions, grantResults);
        }
    }
    public class Environment : IEnvironment
    {
        [System.Obsolete]
        public void SetStautsBarColor(System.Drawing.Color color, bool darkStatusBarTint)
        {
            if (Build.VERSION.SdkInt < BuildVersionCodes.Lollipop)
                return;
            var activity = Platform.CurrentActivity;
            var window = activity.Window;

            window.AddFlags(Android.Views.WindowManagerFlags.DrawsSystemBarBackgrounds);
            window.ClearFlags(Android.Views.WindowManagerFlags.TranslucentStatus);
            window.SetStatusBarColor(color.ToPlatformColor());

            if (Build.VERSION.SdkInt >= BuildVersionCodes.M)
            {
                var flag = (Android.Views.StatusBarVisibility)Android.Views.SystemUiFlags.LightStatusBar;
                window.DecorView.SystemUiVisibility = darkStatusBarTint ? flag : 0;
            }
        }
    }
}