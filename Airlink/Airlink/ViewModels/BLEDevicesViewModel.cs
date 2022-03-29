using Acr.UserDialogs;
using Airlink.Models;
using Airlink.Views;
using Airlink.Views.Profile;
using nexus.core;
using nexus.core.text;
using nexus.protocols.ble;
using PeterO.Cbor;
using Plugin.BLE;
using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Diagnostics;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Xamarin.Essentials;
using Xamarin.Forms;
using Airlink.Services;
using Airlink.Models.PUEAdvert;
using System.Globalization;
using System.Threading;
using System.Net.Http;
using Newtonsoft.Json;
using SQLite;
using Xamarin.Forms.Xaml;
using Xamarin.Forms.PlatformConfiguration;
using Android.Bluetooth;

namespace Airlink.ViewModels
{
    [XamlCompilation(XamlCompilationOptions.Compile)]
    public class BLEDevicesViewModel : BaseViewModel
    {
        private BleItem _selectedItem;
        private IUserDialogs _userDialogs;

        CancellationTokenSource cts;
        public ObservableCollection<BleItem> Items { get; }
        public ObservableCollection<PUEAdvertisedData> PUEAd { get; }
        public Command LoadItemsCommand { get; }
        public Command AddItemCommand { get; }
        public Command<BleItem> ItemTapped { get; }
        public IBluetoothLowEnergyAdapter Ta { get; set; }

        public BLEDevicesViewModel()
        {

            PUEAd = new ObservableCollection<PUEAdvertisedData>();

            Title = "Scanned Devices";

            MessagingCenter.Subscribe<App, IBluetoothLowEnergyAdapter>((App)Application.Current, "SendAdapter", (sender, arg) =>
            {
                Ta = arg;
            });

            Items = new ObservableCollection<BleItem>();
            LoadItemsCommand = new Command(async () => { await ExecuteLoadItemsCommand(); });
            ItemTapped = new Command<BleItem>(OnItemSelected);

            MessagingCenter.Send((App)Application.Current, "IBluetoothLowEnergyAdapterX", "");
        }
        public async Task DoPosts()
        {
            using (SQLiteConnection con = new SQLiteConnection(App.DatabaseLocation))
            {
                con.CreateTable<PUEAdvertisedData>();
                var pueAdvertdata = con.Table<PUEAdvertisedData>().ToList();
                bool DeviceKnown;
                string contents;

                foreach (var data in pueAdvertdata)
                {
                    var DeviceSAT = await SecureStorage.GetAsync("D_" + data.Did);
                    var DeviceCbor = CBORObject.NewMap()
                            .Add("ADVT_rv", data.Rv)
                            .Add("ADVT_ft", data.Ft)
                            .Add("ADVT_did", data.Did)
                            .Add("ADVT_gts", data.Gts)
                            .Add("ADVT_pst", data.Pst)
                            .Add("ADVT_fv", data.Fv)
                            .Add("ADVT_cr", data.Cr)
                            .Add("ADVT_pu", data.Pu)
                            .Add("ADVT_ssn", data.Ssn)
                            .Add("ADVT_lt", data.Lt)
                            .Add("ADVT_ln", data.Ln)
                            .Add("ADVT_la", data.La)
                            .Add("ADVT_gid", data.Gid);
                    var SendCbor = CBORObject.NewMap()
                            .Add("ADVT_aDN", data.Did)
                            .Add("ADVT_tms", DeviceCbor);


                    if (DeviceSAT != null)
                    {
                        DeviceKnown = true;
                    }
                    else
                    {
                        DeviceKnown = false;
                    }
                    byte[] bytes = DeviceKnown ? DeviceCbor.EncodeToBytes() : SendCbor.EncodeToBytes();
                    var cborHexstring = DataConverter.BytesToHexString(bytes);
                    cborHexstring = cborHexstring.Replace("-", "");
                    SendCbor.Add("ADVT_cbor", cborHexstring);
                    contents = DeviceKnown ? DeviceCbor.ToJSONString() : SendCbor.ToJSONString();

                    //post data to IoT Engine
                    PostResponse response = await AirLinkServer.PostToAirLinkServer(contents, data.Did, DeviceKnown ? "telemetry" : "advtPost");

                    if (string.IsNullOrEmpty(response.message))
                    {
                        Debug.WriteLine("Posted Advt for " + data.Did);
                        //Delete data from a local database
                        con.Delete<PUEAdvertisedData>(data.Did);
                    }
                }

            }

        }
        public async Task DoUpdates()
        {
            await ExecuteLoadItemsCommand();
            await DoPosts();
        }

        /* 
         * The method is used to scan and discover all BluetoothLE available within the area
         * Checks if the Location and bluetooth permission are granted
         * Discover devices by getting the device name, UUID, RSSI, Advertised data
         * Add scanned devices to BleItem Model
         *
         */
        private async Task ExecuteLoadItemsCommand()
        {

            IsBusy = true;
            Debug.WriteLine("Looking for AirLink Devices...");
            if (Ta != null)
            {
                try
                {
                    Items.Clear();
                    // Bluetooth and Location Permission
                    if (Device.RuntimePlatform == Device.Android)
                    {
                        //check if bluetooth is enabled, if not - enable it.

                        if (Android.OS.Build.VERSION.SdkInt == Android.OS.BuildVersionCodes.R)
                        {
                            BluetoothAdapter bluetoothAdapter = BluetoothAdapter.DefaultAdapter;
                            if (!bluetoothAdapter.IsEnabled)
                            {
                                Debug.WriteLine("Bluetooth is not enabled.");
                                UserDialogs.Instance.ShowLoading("Turning on bluetooth, please wait...");
                                BluetoothService bs = new BluetoothService();
                                bs.OpenBluetooth();
                                UserDialogs.Instance.HideLoading();
                            }
                            else
                            {
                                Debug.WriteLine("Bluetooth is enabled.");
                            }
                        }

                        //request location permission
                        PermissionStatus status = await Permissions.CheckStatusAsync<Permissions.LocationWhenInUse>();
                        if (status != PermissionStatus.Granted)
                        {
                            var permissionResult = await Permissions.RequestAsync<Permissions.LocationWhenInUse>();

                            if (permissionResult != PermissionStatus.Granted)
                            {
                                await _userDialogs.AlertAsync("Permission denied. Not scanning.");
                                Debug.WriteLine("Permission denied. Not scanning.");
                                UserDialogs.Instance.Toast("Please Permit Bluetooth & Location Access");
                                return;
                            }
                        }
                    }
                    //Get Location 
                    var request = new GeolocationRequest(GeolocationAccuracy.Medium, TimeSpan.FromSeconds(100));
                    cts = new CancellationTokenSource(1000);
                    var location = await Geolocation.GetLocationAsync(request, cts.Token);


                    // Initialize bluetooth device connection
                    var ble = CrossBluetoothLE.Current;
                    var adapter = CrossBluetoothLE.Current.Adapter;
                    var state = ble.State;
                    // List<object> deviceList = new List<object>();
                    // Discover available connection
                    adapter.DeviceDiscovered += async (s, itemDiscovered) =>
                    {
                        BleItem newListItem = new BleItem
                        {
                            Description = itemDiscovered.Device.Rssi.ToString() + " dBm",
                            Id = itemDiscovered.Device.Id.ToString(),
                            Address = itemDiscovered.Device.NativeDevice.ToString(),
                            Name = itemDiscovered.Device.Name != null ? itemDiscovered.Device.Name : "Unknown",
                            DeviceId = itemDiscovered.Device.NativeDevice.ToString(),
                            Device = itemDiscovered.Device,
                            RSSITx = itemDiscovered.Device.Rssi.ToString() + "dBm",
                            CreditRemaining = "0",
                            PayGUnit = char.ToString('H'),
                            LastDateUpdate = DateTime.Now.ToString("dd-MM-yy h:mm tt"),
                            Mfg = itemDiscovered.Device.AdvertisementRecords.Select(x => x.Type + "=0x" + x.Data?.ToArray()?.EncodeToBase16String()).Join(", "),
                            Flags = itemDiscovered.Device.Rssi.ToString() + "dBm",
                            MfgCBOR = itemDiscovered.Device.AdvertisementRecords

                        };

                        if (!Items.Any(x => x.Id == newListItem.Id) && itemDiscovered.Device.Name != null)
                        {
                            // Add discovered device to BleItem Model and Datastore Service

                            try
                            {
                                //Formatting advertised data 
                                var cbo = ManufacturedAdvertisedData(newListItem.Mfg);
                                byte[] cbor = DataConverter.StringToByteArray(cbo);
                                var jcbor = CBORObject.DecodeFromBytes(cbor, new CBOREncodeOptions("resolvereferences=true"));
                                var ob = jcbor.ToString();
                                ob = ob.Replace("\t", "").Replace("\n", "").Replace("\r", "").Replace("[", "").Replace("]", "").Replace("\"", "").Trim();
                                string[] advertData = ob.Split(',');
                                newListItem.Flags = ob;

                                //Scantime
                                newListItem.LastScanTime = DateTime.UtcNow;
                                //Device id
                                newListItem.DeviceId = advertData[2].Trim();
                                //update credit remaining
                                newListItem.CreditRemaining = advertData[6].Trim();
                                //UPDATE Payg unit
                                newListItem.PayGUnit = advertData[7].Trim();

                                //Update credit status
                                int creditStatus = Int32.Parse(advertData[6].Trim());
                                if (creditStatus > 0)
                                {
                                    newListItem.CreditStatus = "#00FF00";
                                }
                                else
                                {
                                    newListItem.CreditStatus = "#EA7979";
                                }
                                //update last update date
                                long dateLast = long.Parse(advertData[3].Trim());
                                DateTimeOffset dateTimeOffset = DateTimeOffset.FromUnixTimeSeconds(dateLast);
                                newListItem.LastDateUpdate = dateTimeOffset.Date.ToString("ddd, MMM dd yyyy");

                                if (location != null)
                                {
                                    newListItem.Latitude = location.Latitude;
                                    newListItem.Longitude = location.Longitude;
                                    newListItem.LocationAccuracy = location.Accuracy;
                                }

                                //Store data
                                Items.Add(newListItem);
                                await DataStore.AddItemAsync(newListItem);

                                if (location == null)
                                {
                                    _userDialogs.Alert("Turn On your Location Please");
                                }
                                else
                                {
                                    PUEAdvertisedData pUEAdvertisedData = new PUEAdvertisedData()
                                    {
                                        Cr = advertData[6].Trim(),
                                        Pst = advertData[4].Trim(),
                                        Fv = advertData[5].Trim(),
                                        Pu = advertData[7].Trim(),
                                        Ft = advertData[1].Trim(),
                                        Did = advertData[2].Trim(),
                                        Rv = advertData[0].Trim(),
                                        Gts = advertData[3].Trim(),
                                        Lt = $"{location.Latitude}",
                                        Ln = $"{location.Longitude}",
                                        La = $"{location.Accuracy}",
                                        Gid = DependencyService.Get<IMobile>().GetIdentifier(),
                                        Ssn = newListItem.RSSITx
                                    };

                                    //Database connection

                                    using (SQLiteConnection conn = new SQLiteConnection(App.DatabaseLocation))
                                    {

                                        string deviceId = advertData[2].Trim().ToString();
                                        var dataQuery = conn.Query<PUEAdvertisedData>("SELECT * FROM PUEAdvertisedData WHERE Did = ?", deviceId);
                                        int count = dataQuery.Count();

                                        if (count > 0)
                                        {
                                            Console.WriteLine($"Device {deviceId} exists. Updating data...");
                                            var query = conn.Table<PUEAdvertisedData>().Where(k => k.Did == deviceId);
                                            int rows = conn.Update(pUEAdvertisedData);

                                            if (rows > 0)
                                            {
                                                Console.WriteLine($"Success! Device ID {deviceId}: Data updated successfully.");
                                            }
                                            else
                                            {
                                                Console.WriteLine($"Error!  Device ID {deviceId}: Data update failed.");
                                            }
                                        }
                                        else
                                        {
                                            Console.WriteLine($"Device {deviceId} doesn't exist. Inserting data...");
                                            //create table and insert into database!
                                            conn.CreateTable<PUEAdvertisedData>();
                                            int rows = conn.Insert(pUEAdvertisedData);

                                            if (rows > 0)
                                            {
                                                Console.WriteLine($"Success! Device ID {deviceId}: Data inserted successfully.");
                                            }
                                            else
                                            {
                                                Console.WriteLine($"Error! Device ID {deviceId}: Data entry failed.");
                                            }
                                        }


                                    }
                                }



                            }
                            catch (Exception ex)
                            {
                                Debug.WriteLine(ex.Message);
                            }

                        }
                        else if (itemDiscovered.Device.Name != null)
                        {
                            BleItem updateListItem = await DataStore.GetItemAsync(newListItem.Id);
                            TimeSpan tSpanToRescan = (new DateTime(2021, 1, 1, 8, 5, 0)) - (new DateTime(2021, 1, 1, 8, 0, 0));
                            if (updateListItem.LastScanTime - newListItem.LastScanTime > tSpanToRescan)
                            {
                                var advertData = newListItem.UpdateDeviceParamsFromAdvt(location);
                                updateListItem.Description = newListItem.Description;
                                updateListItem.Address = newListItem.Address;
                                updateListItem.Name = newListItem.Name;
                                updateListItem.Device = newListItem.Device;
                                updateListItem.RSSITx = newListItem.RSSITx;
                                updateListItem.DeviceId = newListItem.DeviceId;
                                updateListItem.CreditRemaining = newListItem.CreditRemaining;
                                updateListItem.PayGUnit = newListItem.PayGUnit;
                                updateListItem.LastDateUpdate = newListItem.LastDateUpdate;
                                updateListItem.Mfg = newListItem.Mfg;
                                updateListItem.Flags = newListItem.Flags;
                                updateListItem.MfgCBOR = newListItem.MfgCBOR;
                                updateListItem.CreditStatus = newListItem.CreditStatus;
                                updateListItem.Latitude = newListItem.Latitude;
                                updateListItem.Longitude = newListItem.Longitude;
                                updateListItem.LocationAccuracy = newListItem.LocationAccuracy;

                                await DataStore.UpdateItemAsync(updateListItem);
                            }
                        }
                    };

                    adapter.ScanTimeout = 3000;
                    adapter.ScanMode = Plugin.BLE.Abstractions.Contracts.ScanMode.LowLatency;

                    // Start scanning an Event
                    await adapter.StartScanningForDevicesAsync();

                }
                catch (Exception ex)
                {
                    Debug.WriteLine(ex);
                }
                finally
                {
                    IsBusy = false;
                }
            }


        }

        /*Get Manufacture advertised data
        * 
        */
        public string ManufacturedAdvertisedData(string manafactureData)
        {
            try
            {
                string[] dataArray = manafactureData.Split(',');
                foreach (var dString in dataArray)
                {
                    if (dString.Contains("Manufacturer"))
                    {
                        string[] manufacture = dString.Split('=');
                        foreach (var item in manufacture)
                        {
                            if (item.Contains("0x"))
                            {

                                string data = item.Substring(6);
                                return data;
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                Debug.WriteLine(ex.Message);
            }

            return null;
        }
        /*
         * Custom CBOR convertor
         */
        public string CBORCustomdecode(string data)
        {
            try
            {
                string[] formattedData = data.Split(',');
                foreach (var item in formattedData)
                {
                    if (item.Contains('h'))
                    {
                        string cborData = item.Substring(3);
                        string fcborData = cborData.Substring(0, cborData.Length - 2);
                        return fcborData;
                    }
                }

            }
            catch (Exception)
            {
                _userDialogs.Alert("Process Failed", "");
            }
            return null;
        }
        /* 
         * Used to excute once the class is called
         */
        public void OnAppearing()
        {
            IsBusy = true;
            SelectedItem = null;
        }

        public BleItem SelectedItem
        {
            get => _selectedItem;
            set
            {
                SetProperty(ref _selectedItem, value);
                OnItemSelected(value);
            }
        }

        /* 
         *Connects selected BLE devices
         *It loads to ServerDetailsPage 
         *Takes the UUID/GUID as a reference to ServerDetailsPage
         */

        async void OnItemSelected(BleItem item)
        {

            if (item == null)
                return;
            try
            {
                var config = new ActionSheetConfig();

                var adapter = CrossBluetoothLE.Current.Adapter;
                Debug.WriteLine("Trying to connect to device..." + item.Device);
                await adapter.ConnectToDeviceAsync(item.Device);

                await Shell.Current.GoToAsync($"{nameof(ScannedDetailsPage)}?{nameof(BLEDeviceDetailsViewModel.ItemId)}={item.Id}");

            }
            catch (Exception ex)
            {
                Debug.WriteLine(ex.ToString());
            }


        }

    }
}