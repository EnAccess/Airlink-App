using Airlink.ViewModels;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using Xamarin.Forms;
using Xamarin.Forms.Xaml;

namespace Airlink.Views
{
    [XamlCompilation(XamlCompilationOptions.Compile)]
    public partial class ScannedDetailsPage : ContentPage
    {
        ServerDetailsViewModel _detailModel;
        public ScannedDetailsPage()
        {
            InitializeComponent();
            BindingContext = _detailModel = new ServerDetailsViewModel();
        }

        protected override void OnDisappearing()
        {
            base.OnDisappearing();
            _detailModel.OnDisappearingAsync();
        }
    }
}