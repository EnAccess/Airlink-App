using Airlink.ViewModels;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Rg.Plugins.Popup;
using Xamarin.Forms;
using Xamarin.Forms.Xaml;

namespace Airlink.Views
{
    [XamlCompilation(XamlCompilationOptions.Compile)]
    public partial class WritetoPropertPopup : Rg.Plugins.Popup.Pages.PopupPage
    {
        public WritetoPropertPopup()
        {
            InitializeComponent();
            BindingContext = new BLEDeviceDetailsViewModel();
        }
        protected override bool OnBackButtonPressed()
        {
            return base.OnBackButtonPressed();
        }
        protected override void OnDisappearing()
        {
           
            base.OnDisappearing();
        }
    }
}