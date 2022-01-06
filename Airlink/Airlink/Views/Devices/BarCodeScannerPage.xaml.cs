using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using Xamarin.Forms;
using Xamarin.Forms.Xaml;

namespace Airlink.Views.Devices
{
    [XamlCompilation(XamlCompilationOptions.Compile)]
    public partial class BarCodeScannerPage : ContentView
    {
        public BarCodeScannerPage()
        {
            InitializeComponent();
        }

        public void ZXingScannerView_OnScanResult(ZXing.Result result)
        {
            Device.BeginInvokeOnMainThread(() =>
            {
                Debug.WriteLine("Scanner view result: ", result.Text);
            });
        }
    }
}