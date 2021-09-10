using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using Xamarin.Forms;
using Xamarin.Forms.Xaml;
using Airlink.ViewModels;
namespace Airlink.Views
{
    [XamlCompilation(XamlCompilationOptions.Compile)]
    public partial class PayGUpdatePage : ContentPage
    {
       PaygUpdateViewModel _puviewModel;

        public PayGUpdatePage()
        {
            
            InitializeComponent();
            BindingContext = _puviewModel = new PaygUpdateViewModel();
        }
        protected override void OnAppearing()
        {
            base.OnAppearing();
            _puviewModel.OnAppering();
        }
    }
}