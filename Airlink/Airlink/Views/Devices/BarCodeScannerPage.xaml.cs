using Acr.UserDialogs;
using Airlink.Models;
using Airlink.Services;
using Airlink.ViewModels;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Xamarin.Essentials;
using Xamarin.Forms;
using Xamarin.Forms.Xaml;

namespace Airlink.Views.Devices
{
    [XamlCompilation(XamlCompilationOptions.Compile)]
    public partial class BarcodeScannerPage : ContentPage
    {
        BarcodeScannerViewModel _scannerModel = new BarcodeScannerViewModel();
        BLEDeviceDetailsViewModel _detailModel = new BLEDeviceDetailsViewModel();
        public BarcodeScannerPage()
        {
            InitializeComponent();
            BindingContext = _scannerModel;

            //Initialize Barcode Scanning
            InitializeScanning();
        }

        protected override void OnDisappearing()
        {
            _scannerModel.OnDisappearingAsync();
        }

        //Start scanning
        public void InitializeScanning()
        {
            _scannerModel.StartScanning();
        }

        public void ZXingScannerView_OnScanResult(ZXing.Result result)
        {
            Device.BeginInvokeOnMainThread(async () =>
            {
                if (!string.IsNullOrEmpty(result.Text))
                {
                    //Stop scanning once there is a result present
                    _scannerModel.StopScanning();

                    bool answer = await DisplayAlert("Confirm Device", $"{result.Text}", "OK", "Rescan");
                    if (answer)
                    {
                        //Provision the device with result(Device ID) gathered from scanning after the user opts "OK"
                        string DeviceId = result.Text;

                        // provision device
                        PostResponse postResponse = await AirLinkServer.ProvisionDevice(DeviceId, "Device");

                        if (string.IsNullOrEmpty(postResponse.status))
                        {
                            string serverAuthTkn = await SecureStorage.GetAsync("deviceAccessToken");

                            ScannedDetailsPage sc = new ScannedDetailsPage();

                            //sc.DeviceTitle.Text = DeviceId;
                            //sc.Text = serverAuthTkn;
                            sc.SaveCommand_Clicked();

                            // write Access Token to device
                            string jsonData = "{\"" + "DCFG_did" + "\" : " + DeviceId + ", \"" + "DCFG_sat" + "\" : \"" + serverAuthTkn + "\"}";

                            JObject jsonObj = JObject.Parse(jsonData);
                            bool postToServer = false;

                            //await _detailModel.ReadWritePostResource(jsonObj, postToServer);

                            //Generate server secret
                            string server_secret = "";
                            var device_secret = new byte[16];
                            Random rnd = new Random();
                            for (int i = 0; i < device_secret.Length; i++)
                            {
                                device_secret[i] = (byte)rnd.Next(0, 255);
                                server_secret += device_secret[i].ToString("x2");
                            }

                            //write the device secret to BLE device
                            device_secret = DataConverter.StringToByteArray(server_secret);

                            //await _detailModel.WriteBytesToDevice("DCFG_dsc", device_secret);


                            //post server secret and message ID to server shared attributes
                            string contents = "{\"" + "device_secret" + "\" : \"" + server_secret.ToUpper() + "\", \"" + "msg_id" + "\" : " + 0 + "}";

                            PostResponse response = await AirLinkServer.PostToAirLinkServer(contents, DeviceId, "serverScope");

                            if (string.IsNullOrEmpty(response.status))
                            {
                                UserDialogs.Instance.HideLoading();
                                bool decision = await DisplayAlert("SUCCESS!", "Device provisioned successfully!", "", "OK");
                                if (!decision)
                                {
                                    await Navigation.PopAsync();
                                }
                            }
                            else
                            {
                                UserDialogs.Instance.HideLoading();
                                UserDialogs.Instance.Alert(response.message, $"Error! {response.status}");
                            }

                        }
                        else
                        {
                            UserDialogs.Instance.HideLoading();

                            bool decision = await DisplayAlert($"Error {postResponse.status}", postResponse.message, "", "OK");
                            if (!decision)
                            {
                                await Navigation.PopAsync();
                            }

                        }

                    }
                    else
                    {
                        //Scan again if the user opts to "Rescan"
                        _scannerModel.StartScanning();
                    }
                }
            });
        }
    }
}