using Airlink.Services;
using UniqueId.Droid;
using Xamarin.Forms;
using Android.Telephony;
using System.Diagnostics;

[assembly: Xamarin.Forms.Dependency(typeof(UniqueIdAndroid))]
namespace UniqueId.Droid
{
    public class UniqueIdAndroid : IMobile
    {
        [System.Obsolete] //FIXME for Forms.Context - add a local context instead if possible
        public string GetIdentifier()
        {
            try
            {
                TelephonyManager manager = (TelephonyManager)Forms.Context.GetSystemService(Android.Content.Context.TelephonyService);
                return manager.Imei.Equals(null) ? manager.Meid : manager.Imei;
            }
            catch
            {
                Debug.WriteLine("IMEI permission not enabled for app");
                return null;
            }
        }
    }
}