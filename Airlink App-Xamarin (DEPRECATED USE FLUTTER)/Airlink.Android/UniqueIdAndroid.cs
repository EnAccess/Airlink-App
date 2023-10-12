using Airlink.Services;
using UniqueId.Droid;
using Xamarin.Forms;
using Xamarin.Essentials;
using Android.Telephony;
using System.Diagnostics;

[assembly: Xamarin.Forms.Dependency(typeof(UniqueIdAndroid))]
namespace UniqueId.Droid
{
    public class UniqueIdAndroid : IMobile
    {
        public string GetIdentifier()
        {
            try
            {
                TelephonyManager manager = (TelephonyManager)Android.App.Application.Context.GetSystemService(Android.Content.Context.TelephonyService);
                return manager.Imei.Equals(null) ? manager.Meid : manager.Imei;
            }
            catch
            {
                return null;
            }
        }
        public string DeviceType()
        {
            return DeviceInfo.Idiom.ToString();
        }
    }
}