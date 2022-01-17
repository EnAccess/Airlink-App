using System;
using System.Collections.Generic;
using System.Text;
using Xamarin.Forms;

namespace Airlink.ViewModels
{
    public class BarcodeScannerViewModel : ContentPage
    {
        public bool _isScanning;
        public bool IsScanning
        {
            get { return _isScanning; }
            set { _isScanning = value; OnPropertyChanged(); }
        }

        public bool _isAnalyzing;
        public bool IsAnalyzing
        {
            get { return _isAnalyzing; }
            set { _isAnalyzing = value; OnPropertyChanged(); }
        }

        private string _scannedResult;
        public string ScannedResult
        {
            get { return _scannedResult; }
            set { _scannedResult = value; OnPropertyChanged(); }
        }

        public void OnDisappearingAsync()
        {
            IsScanning = false;
            IsAnalyzing = false;
        }

        public void StartScanning()
        {
            IsScanning = true;
            IsAnalyzing = true;
        }
        public void StopScanning()
        {
            IsScanning = false;
            IsAnalyzing = false;
        }

    }
}
