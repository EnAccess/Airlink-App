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
            //saveKey = new Command(SyncCommand_Clicked);
            BindingContext = _detailModel = new BLEDeviceDetailsViewModel();
            MessagingCenter.Subscribe<App, string>((App)Application.Current, "UpdateDevID", (sender, arg) =>
            {
                DeviceTitle.Text = arg;
                var keyTask = SecureStorage.GetAsync("D_" + arg);
                SecureStorage.SetAsync("Device Id", arg.ToString());
                if (keyTask.Result != null) { accTokenEntry.Text = keyTask.Result; }
            });

        }

        protected override void OnDisappearing()
        {
            _detailModel.OnDisappearingAsync();
        }

        public void SyncCommand_Clicked(object sender, EventArgs e)
        {
            _detailModel.GetServerAttributes();
        }
        public async void DeviceProvisionCommand_Clicked(object sender, EventArgs e)
        {
            try
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
                Console.WriteLine($"Provision status for device {deviceId}:  {provisionStatus}");

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
                        Debug.WriteLine($"Device: {deviceId} not serialized.");

                        string action = await DisplayActionSheet("Device not serialized. Select your choice for serialization", "Cancel", null, "Scan barcode", "Type serial number");
                        Debug.WriteLine("Action: " + action);

                        if(action == "Scan barcode")
                        {
                            Debug.WriteLine("Action: " + action);
                        }
                        else if(action == "Type serial number")
                        {
                            string result = await DisplayPromptAsync("Serial Number", "Enter Device Serial Number", accept: "Enter", maxLength: 5, placeholder: "Eg.80021", keyboard: Keyboard.Numeric);
                            if (result != null)
                            {
                                try
                                {
                                    string DeviceId = result.Trim().Replace(" ", "");

                                    // provision device
                                    PostResponse provisionResponse = await AirLinkServer.ProvisionDevice(DeviceId, "Device");
                                    if (provisionResponse.status)
                                    {
                                        DeviceTitle.Text = DeviceId;

                                        await SecureStorage.SetAsync("D_" + DeviceTitle.Text, provisionResponse.value);
                                        accTokenEntry.Text = provisionResponse.value;

                                        // write Access Token to device
                                        string jsonData = "{\"" + "DCFG_sat" + "\" : \"" + provisionResponse.value + "\", \"" + "DCFG_did" + "\" : " + DeviceId + "}";

                                        JObject jsonObj = JObject.Parse(jsonData);
                                        bool ReadResource = false;
                                        bool postToServer = false;

                                        _detailModel.ReadWritePostResource(jsonObj, ReadResource, postToServer);
                                    }


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
                        else
                        {
                            Debug.WriteLine("Nothing was selected.");
                            return;
                        }
                    }
                    else if (provisionStatus == 2)
                    {
                        //serialized but not provisioned. Provision device and write Access Token to device
                        PostResponse provisionResponse = await AirLinkServer.ProvisionDevice(DeviceTitle.Text, "Device");
                        if (provisionResponse.status)
                        {
                            await SecureStorage.SetAsync("D_" + DeviceTitle.Text, provisionResponse.value);
                            accTokenEntry.Text = provisionResponse.value;

                            string AccessTokenPair = "{\"" + "DCFG_sat" + "\" : \"" + provisionResponse.value + "\"}";

                            JObject ATPjsonObj = JObject.Parse(AccessTokenPair);
                            bool ATReadResource = false;
                            bool ATpostToServer = false;

                            _detailModel.ReadWritePostResource(ATPjsonObj, ATReadResource, ATpostToServer);
                        }
                    }
                }


            }
            catch (Exception ex)
            {
                Debug.WriteLine(ex.Message);
            }

        }
        public async void SaveCommand_Clicked(object sender, EventArgs e)
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
                    //string jsonData = "{\"" + "DCFG_pst" + "\" : " + 1 + "}";

                    JObject jsonObj = JObject.Parse(jsonData);
                    bool ReadResource = false;
                    bool postToServer = false;

                    _detailModel.ReadWritePostResource(jsonObj, ReadResource, postToServer);

                    //FIXME: call a function to write this data to a particular resource
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
    }
}