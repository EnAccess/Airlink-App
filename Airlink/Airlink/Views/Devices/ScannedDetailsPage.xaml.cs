using Airlink.ViewModels;
using Airlink.Services;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using Xamarin.Forms;
using Xamarin.Forms.Xaml;
using Xamarin.Essentials;
using System.Windows.Input;
using System.Diagnostics;
using Airlink.Models;
using Acr.UserDialogs;
using Airlink.Models.PUEAdvert;
using PeterO.Cbor;
using Plugin.BLE;
using nexus.core.text;
using nexus.core;
using Newtonsoft.Json.Linq;
using System.Collections.ObjectModel;
using SQLite;
using ZXing;
using ZXing.Mobile;
using Plugin.BLE.Abstractions.Exceptions;

namespace Airlink.Views
{
    [XamlCompilation(XamlCompilationOptions.Compile)]

    public partial class ScannedDetailsPage : ContentPage
    {
        BLEDeviceDetailsViewModel _detailModel;

        //public ICommand saveKey { get; } 
        public ScannedDetailsPage()
        {
            InitializeComponent();
            SecureStorage.SetAsync("defaultSAT", "92WwT5ZYXtKuUtZrJZAs");
            //saveKey = new Command(SyncCommand_Clicked);
            BindingContext = _detailModel = new BLEDeviceDetailsViewModel();
            _detailModel.IsGridVisible = true;

            MessagingCenter.Subscribe<App, string>((App)Application.Current, "UpdateDevID", (sender, arg) =>
            {
                DeviceTitle.Text = arg;
                var keyTask = SecureStorage.GetAsync("D_" + arg);
                SecureStorage.SetAsync("Device Id", arg.ToString());
                if (keyTask.Result != null)
                {
                    accTokenEntry.Text = keyTask.Result;
                }
                //else
                //{
                //    accTokenEntry.Text = SecureStorage.GetAsync("defaultSAT").ToString();
                //}
            });
        }
        public void InitializeScanning()
        {
            _detailModel.StartScanning();
        }

        protected override void OnDisappearing()
        {
            _detailModel.OnDisappearingAsync();
            _detailModel.StopScanning();
        }
        public static async Task<int> GetProvisionStatusAsync()
        {
            var deviceId = await SecureStorage.GetAsync("Device Id");
            int provisionStatus = 0;
            Console.WriteLine("Reading data........");
            using (SQLiteConnection conn = new SQLiteConnection(App.DatabaseLocation))
            {
                //Get data from local database where device Id (Did - from local db) = connected device Id (deviceId)
                var ConnectedDeviceIdData = conn.Query<PUEAdvertisedData>("SELECT * FROM PUEAdvertisedData WHERE Did = ?", deviceId);
                if (!ConnectedDeviceIdData.Any())
                {
                    //no data available associated with that device Id
                    Console.WriteLine("No data available in the database");
                }
                else
                {
                    foreach (var s in ConnectedDeviceIdData)
                    {
                        provisionStatus = Convert.ToInt32(s.Pst);
                    }
                }

            }
            return provisionStatus;
        }

        public async void SyncCommand_Clicked(object sender, EventArgs e)
        {
            int provisionStatus = await GetProvisionStatusAsync();

            if (provisionStatus < 3)
            {
                bool answer = await DisplayAlert("Error!", "Device not provisioned. Provision device to sync data.", "Provision Device", "Cancel");
                if (answer)
                {
                    //Method to provision device 
                    DeviceProvisionCommand_Clicked(sender, e);
                }
                else
                {
                    Debug.WriteLine("Cancel");
                }
            }
            else
            {
                _detailModel.GetServerAttributes();
            }

        }
        public async void DeviceProvisionCommand_Clicked(object sender, EventArgs e)
        {
            try
            {
                //JWT login request to create auth token
                var airlinkURL = await SecureStorage.GetAsync("airlinkServer_url");
                var email = await SecureStorage.GetAsync("emailEntry");
                var password = await SecureStorage.GetAsync("passwordEntry");

                JWTResponse jwtResponse = await UserLoginRequest.LoginRequest(airlinkURL, email, password);
                Debug.WriteLine(jwtResponse.ToString());
                await SecureStorage.SetAsync("JWT Token", jwtResponse.token.ToString());

                //Get provision status from DB
                int provisionStatus = await GetProvisionStatusAsync();

                /* The status of the device according to manufacturer definition. It can be 
                    1-unserialized,
                    2-unprovisioned,
                    3-disabled, 
                    4-recall, 
                    5-stolen, 
                    6-Cash, 
                    7-Loan. 
                */

                //Check if the device is already provisioned
                if (provisionStatus >= 3)
                {
                    //Device is already provisioned
                    UserDialogs.Instance.Alert("Already provisioned.", "INFO!");
                }
                else
                {
                    //Not provisioned. Check if serialized
                    if (provisionStatus == 1)
                    {
                        //not serialized. Pop up a form to enter serial number or scan barcode
                        string action = await DisplayActionSheet("Device not serialized. Select your choice for serialization", "Cancel", null, "Scan barcode", "Type serial number");

                        if (action == "Scan barcode")
                        {
                            InitializeScanning();
                        }
                        else if (action == "Type serial number")
                        {
                            string result = await DisplayPromptAsync("Serial Number", "Enter Device Serial Number", accept: "Enter", maxLength: 10, placeholder: "Eg.800021", keyboard: Keyboard.Numeric);
                            DoProvisioning(result);
                        }
                        else
                        {
                            Debug.WriteLine("Nothing was selected.");
                            return;
                        }
                    }
                    else if (provisionStatus == 2)
                    {
                        //serialized but not provisioned. Provision device and write Access Token to device
                        string DeviceId = DeviceTitle.Text;
                        DoProvisioning(DeviceId);
                    }
                }
            }
            catch (Exception ex)
            {
                Debug.WriteLine(ex.Message);
            }

        }

        public async void DoProvisioning(string result)
        {
            string DeviceId = result.Trim().Replace(" ", "");
            if (DeviceId != null && DeviceId.Length > 3)
            {
                try
                {
                    // provision device
                    PostResponse postResponse = await AirLinkServer.ProvisionDevice(DeviceId, "Device");

                    if (string.IsNullOrEmpty(postResponse.status))
                    {
                        string serverAuthTkn = await SecureStorage.GetAsync("deviceAccessToken");

                        DeviceTitle.Text = DeviceId;
                        accTokenEntry.Text = serverAuthTkn;
                        SaveCommand_Clicked();

                        // write Access Token to device
                        string jsonData = "{\"" + "DCFG_did" + "\" : " + DeviceId + ", \"" + "DCFG_sat" + "\" : \"" + serverAuthTkn + "\"}";

                        JObject jsonObj = JObject.Parse(jsonData);
                        bool postToServer = false;

                        await _detailModel.ReadWritePostResource(jsonObj, postToServer);

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

                        await _detailModel.WriteBytesToDevice("DCFG_dsc", device_secret);

                        //post server secret and message ID to server shared attributes
                        string contents = "{\"" + "device_secret" + "\" : \"" + server_secret.ToUpper() + "\", \"" + "msg_id" + "\" : " + 0 + "}";

                        PostResponse response = await AirLinkServer.PostToAirLinkServer(contents, DeviceId, "serverScope");

                        if (string.IsNullOrEmpty(response.status))
                        {
                            UserDialogs.Instance.HideLoading();
                            UserDialogs.Instance.Alert("Device provisioned successfully!", "SUCCESS!");
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
                        UserDialogs.Instance.Alert(postResponse.message, $"Error! {postResponse.status}");
                    }
                }
                catch (Exception ex)
                {
                    Debug.WriteLine("Secure storage Error: " + ex.Message);
                }
            }
            else
            {
                UserDialogs.Instance.Alert("The input is either empty or contains less than four characters.", "Error!");
                return;
            }

        }

        public async void SaveCommand_Clicked()
        {
            bool isKeyEmpty = string.IsNullOrEmpty(accTokenEntry.Text);

            if (isKeyEmpty)
            {
                await DisplayAlert("Error", "Please input key", "Ok");
            }
            else
            {
                _ = SecureStorage.SetAsync("D_" + DeviceTitle.Text, accTokenEntry.Text.ToString());
                //DisplayAlert("Key", keyEntry.Text.ToString(), "Ok");
            }
        }

        public void DeleteDBBtn(object sender, EventArgs e)
        {
            using (SQLiteConnection conn = new SQLiteConnection(App.DatabaseLocation))
            {
                // Clear the database
                int rows = conn.DeleteAll<PUEAdvertisedData>();
                if (rows > 0)
                {
                    Console.WriteLine("Database cleared successfully!");
                }
            }
        }

        public void EnterTokenBtn(object sender, EventArgs e)
        {
            EnterToken();
        }

        /* Function to prompt a dialog to user to enter payG token and save 
        it to a secure storage */
        public async void EnterToken()
        {
            string result = await DisplayPromptAsync("Token", "Enter your token:", accept: "Enter", placeholder: "*59979149319443#");
            if (result != null)
            {
                try
                {
                    string payGtoken = result.Trim().Replace(" ", "");
                    await SecureStorage.SetAsync("PayG Token", payGtoken);

                    //Current time in Unix timestamp
                    DateTime foo = DateTime.Now;
                    long unixTime = ((DateTimeOffset)foo).ToUnixTimeSeconds();

                    var token = await SecureStorage.GetAsync("PayG Token");
                    string jsonData = "{\"" + "PC_tkn" + "\" : \"" + token + "\", \"" + "PC_lt" + "\" : " + unixTime + "}";

                    JObject jsonObj = JObject.Parse(jsonData);
                    bool postToServer = false;

                    await _detailModel.ReadWritePostResource(jsonObj, postToServer);
                }
                catch (Exception ex)
                {
                    Debug.WriteLine("Secure storage Error: " + ex.Message);
                }
            }
            else
            {
                Debug.WriteLine("Nothing was entered.");
                return;
            }

        }

        public async void AuthorizeCommand_Clicked(object sender, EventArgs e)
        {
            int provisionStatus = await GetProvisionStatusAsync();

            UserDialogs.Instance.ShowLoading("Authorizing, please wait..");

            string SAT = await SecureStorage.GetAsync("defaultSAT");

            byte[] ba;
            if (provisionStatus > 2)   //If already provisioned use SAT from secure storage, otherwise use default SAT
            {
                ba = Encoding.Default.GetBytes(accTokenEntry.Text);
            }
            else
            {
                ba = Encoding.Default.GetBytes(SAT);
            }
            var hexString = BitConverter.ToString(ba).Replace("-", "").ToLower();
            byte[] defaultSAT = DataConverter.StringToByteArray(hexString);

            try
            {
                await _detailModel.WriteBytesToDevice("DFU_sat", defaultSAT);
                UserDialogs.Instance.HideLoading();
                UserDialogs.Instance.Alert($"Device Authorized.");
            }
            catch (Exception ex)
            {
                UserDialogs.Instance.Alert($"{ex.Message}", "ERROR!");
            }
        }

        public void ZXingScannerView_OnScanResult(ZXing.Result result)
        {
            Device.BeginInvokeOnMainThread(async () =>
            {
                if (!string.IsNullOrEmpty(result.Text))
                {
                    //stop scanning once the camera captures a barcode
                    _detailModel.StopScanning();

                    string initialValue = result.Text;

                    string initialValueData = await DisplayPromptAsync("Serial Number", "Confirm device serial number", accept: "Ok", cancel: "Rescan", initialValue: initialValue, maxLength: 10, placeholder: "Eg.800021", keyboard: Keyboard.Numeric);
                    if(!string.IsNullOrEmpty(initialValueData))
                    {
                        DoProvisioning(initialValueData);
                    }
                    else
                    {
                        _detailModel.StartScanning();
                    }
                }
            });
        }
    }
}