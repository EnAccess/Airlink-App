using System;
using System.Collections.Generic;
using System.Text;
using TestApplication_4.Droid;
using static Android.Provider.Settings;

[assembly: Xamarin.Forms.Dependency(typeof(GetInfoImplement))]
public interface IGetDeviceInfo
{
    string GetDeviceID();
}

namespace TestApplication_4.Droid
{
    public class GetInfoImplement : IGetDeviceInfo
    {
        string IGetDeviceInfo.GetDeviceID()
        {
            var context = Android.App.Application.Context;
            string id = Android.Provider.Settings.Secure.GetString(context.ContentResolver, Secure.AndroidId);
            return id;
        }
    }
}
