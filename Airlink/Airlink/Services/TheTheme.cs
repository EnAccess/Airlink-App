using System;
using System.Collections.Generic;
using System.Text;
using Xamarin.Forms;

namespace Airlink.Services
{
  public  class TheTheme
    {
        public static void SetTheme()
        {
            /*  switch (Settings.Theme)
              {
                  case 0:
                      App.Current.UserAppTheme = OSAppTheme.Unspecified;
                      break;
                  case 1:
                      App.Current.UserAppTheme = OSAppTheme.Light;
                      break;
                  case 2:
                      App.Current.UserAppTheme = OSAppTheme.Dark;
                      break;
              } */

            var e = DependencyService.Get<IEnvironment>();

            if (App.Current.RequestedTheme == OSAppTheme.Dark)
            {
                // e?.SetStautsBarColor(Color.FromHex("#52307C"), false);
                e?.SetStautsBarColor(Color.FromHex("#52307C"), false);
            }
            else
            {
                e?.SetStautsBarColor(Color.FromHex("#EBECF0"), true);
            }

        }
    }
}
