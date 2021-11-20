using System.Windows.Input;
using Airlink.Views;
using Xamarin.Forms;
using Xamarin.Forms.Xaml;

namespace Airlink.ViewModels
{
    [XamlCompilation(XamlCompilationOptions.Compile)]
    public class ProfilePageViewModel : ContentPage
    {
        public ICommand DevicesCommand { get; }
        public ICommand APIsCommand { get; }
        public ICommand SettingCommand { get; }

        public Command<string> LogoutCommand { get; }

        public Command<string> ProfileCommand { get; }
        public ProfilePageViewModel()
        {
            DevicesCommand = new Command(DevicesPageCommand);
        }

        public async void DevicesPageCommand()
        {
            var route = $"{nameof(DevicePage)}";
            await Shell.Current.GoToAsync(route);
        }
    }
}
