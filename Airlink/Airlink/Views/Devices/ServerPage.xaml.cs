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
    public partial class ServerPage : ContentPage
    {
        ServersViewModel _viewModel;
        public ServerPage()
        {
            InitializeComponent();

            // Binding the server View Model
            BindingContext = _viewModel = new ServersViewModel();
        }

        /*
         * Overriding the onAppearing of a Page
         */
        protected override void OnAppearing()
        {
            base.OnAppearing();
            _viewModel.OnAppearing();
        }
        private void ListView_OnItemSelected(Object sender, SelectedItemChangedEventArgs e)
        {
            if (e.SelectedItem != null)
            {
                //((BlePeripheralViewModel)e.SelectedItem).IsExpanded = !((BlePeripheralViewModel)e.SelectedItem).IsExpanded;
                ((ListView)sender).SelectedItem = null;
            }
        }

        private void ListView_OnItemTapped(Object sender, ItemTappedEventArgs e)
        {
        }
    }
}