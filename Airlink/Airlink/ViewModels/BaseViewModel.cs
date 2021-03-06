using Airlink.Models;
using Airlink.Services;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Runtime.CompilerServices;
using System.Text;
using Xamarin.Forms;
using Xamarin.Forms.Xaml;

namespace Airlink.ViewModels
{
    [XamlCompilation(XamlCompilationOptions.Compile)]
    public class BaseViewModel : INotifyPropertyChanged
    {
        // DataStore Interface recall to use BleItem Model
        public IItemStore<BleItem> DataStore => DependencyService.Get<IItemStore<BleItem>>();

        // DataStore Interface recall to use PropertyID Model
        public IPropertyStore<PropertyID> PropertyDataStore => DependencyService.Get<IPropertyStore<PropertyID>>();

        // DataStore Interface recall to use Property Model

        public IPropertyDataStore<Property> AllPropertyDataStore => DependencyService.Get<IPropertyDataStore<Property>>();
        bool isBusy = false;
        public bool IsBusy
        {
            get { return isBusy; }
            set { SetProperty(ref isBusy, value); }
        }

        string title = string.Empty;
        public string Title
        {
            get { return title; }
            set { SetProperty(ref title, value); }
        }

        protected bool SetProperty<T>(ref T backingStore, T value,
            [CallerMemberName] string propertyName = "",
            Action onChanged = null)
        {
            if (EqualityComparer<T>.Default.Equals(backingStore, value))
                return false;

            backingStore = value;
            onChanged?.Invoke();
            OnPropertyChanged(propertyName);
            return true;
        }

        //INotify Changed used for data Binding between the View and ViewModel
        #region INotifyPropertyChanged
        public event PropertyChangedEventHandler PropertyChanged;
        protected void OnPropertyChanged([CallerMemberName] string propertyName = "")
        {
            var changed = PropertyChanged;
            if (changed == null)
                return;

            changed.Invoke(this, new PropertyChangedEventArgs(propertyName));
        }
        #endregion
    }
}
