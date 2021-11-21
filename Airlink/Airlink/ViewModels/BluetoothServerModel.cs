using System;
using System.ComponentModel;
using System.Runtime.CompilerServices;
using System.Windows.Input;
using Xamarin.Forms;
using Xamarin.Forms.Xaml;

namespace Airlink.ViewModels
{
    [XamlCompilation(XamlCompilationOptions.Compile)]
    public class BluetoothServerModel : INotifyPropertyChanged
    {
        private void OnPropertyChanged([CallerMemberName] string propertyName = null)
        {
            var handler = PropertyChanged;
            if (handler != null)
            {
                handler(this, new PropertyChangedEventArgs(propertyName));
            }
        }
        public event PropertyChangedEventHandler PropertyChanged;
        private string buttonstr;
        public string ButtonStr
        {
            get { return buttonstr; }
            set
            {
                buttonstr = value;
                OnPropertyChanged();
            }
        }
        private Boolean m_isBusy;
        public Boolean IsBusy
        {
            get { return m_isBusy; }
            set
            {
                m_isBusy = value;
                OnPropertyChanged();
            }
        }

        private string m_connectionState;
        public string Connection
        {
            get { return m_connectionState; }
            set
            {
                m_connectionState = value;
                OnPropertyChanged();
            }
        }

        private string logstr;
        public string LogStr
        {
            get { return logstr; }
            set
            {
                logstr = value;
                OnPropertyChanged();
            }
        }
        private string messagex;
        public string Messagex
        {
            get { return messagex; }
            set
            {
                messagex = value;
                OnPropertyChanged();
            }
        }
        public BluetoothServerModel()
        {
            //Title = "Server BLE";
            MessagingCenter.Subscribe<App, string>((App)global::Xamarin.Forms.Application.Current, "Hi", async (sender, arg) => {
                LogStr += arg.ToString() + "\r\n";
            });
            ButtonStr = "Send Message";
            OpenWebCommand = new Command(async () =>
            {

                if (Messagex != null)
                    MessagingCenter.Send<Airlink.App, string>((Airlink.App)Xamarin.Forms.Application.Current, "GetValuex", Messagex);
                else LogStr += "[Write] Please Input Message \r\n";

            });
         
            MessagingCenter.Subscribe<string>(this, "eventName", (label) => {
                // Do something whenever the message is sent
                Device.BeginInvokeOnMainThread(() => {
                    LogStr += label;
                });
            });

        }

        public ICommand OpenWebCommand { get; }

    }
}
