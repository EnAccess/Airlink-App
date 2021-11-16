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

                foreach (var data in pueAdvertdata)
                {
                    var DeviceCbor = CBORObject.NewMap()
                            .Add("rv", data.Rv)
                            .Add("ft", data.Ft)
                            .Add("did", data.Did)
                            .Add("gts", data.Gts)
                            .Add("pst", data.Pst)
                            .Add("fv", data.Fv)
                            .Add("cr", data.Cr)
                            .Add("pu", data.Pu)
                            .Add("la", data.La)
                            .Add("ssn", data.Ssn)
                            .Add("lt", data.Lt)
                            .Add("ln", data.Ln)
                            .Add("la", data.La)
                            .Add("gid", data.Gid);
                    var SendCbor = CBORObject.NewMap()
                            .Add("aDN", data.Did)
                            .Add("tms", DeviceCbor);
                    byte[] bytes = SendCbor.EncodeToBytes();
                    // PUEAd.Add(x);
                    var cborHexstring = DataConverter.BytesToHexString(bytes);
                    cborHexstring = cborHexstring.Replace("-", "");
                    SendCbor.Add("cbor", cborHexstring);
                    var contents = SendCbor.ToJSONString();

                    //post data to IoT Engine
                    if (await AirLinkServer.PostToAirLinkServer(contents, data.Did, "advtPost")) 
                    {
                        Debug.WriteLine("Posted Advt for "+data.Did);
                        //Delete data from a local database
                        con.Delete<PUEAdvertisedData>(data.Id);
                    }
                }
                // Clear the databse
                con.DeleteAll<PUEAdvertisedData>();
            }

        }
        public async Task DoUpdates()
        {
            await ExecuteLoadItemsCommand(); await DoPosts();
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
                        PermissionStatus status = await Permissions.CheckStatusAsync<Permissions.LocationAlways>();
                        if (status != PermissionStatus.Granted)
                        {
                            var permissionResult = await Permissions.RequestAsync<Permissions.LocationWhenInUse>();

                            if (permissionResult != PermissionStatus.Granted)
                            {
                                await _userDialogs.AlertAsync("Permission denied. Not scanning.");
                                UserDialogs.Instance.Toast("Please Permit Bluetooth & Location Access");
                                return;
                            }
                        }
                    }
                    //Get Location 
                    var request = new GeolocationRequest(GeolocationAccuracy.Medium, TimeSpan.FromSeconds(100));
                    cts = new CancellationTokenSource(1000);
                    var location = await Geolocation.GetLocationAsync(request, cts.Token);

                    //Add Test Device if enabled FIXME remove in production app!
                    if (ProfilePage.TestDevice)
                    {
                        Debug.WriteLine("Debug Devices Enabled ");
                        BleItem testDeviceItem = new BleItem
                        {

                            //Scantime
                            LastScanTime = DateTime.UtcNow,
                            //Device id
                            Id = "TestDeviceAirLinkApp",
                            DeviceId = "TestDeviceAirLinkApp",
                            //FIXME Tap response for Test Device
                            //Device = Plugin.BLE.Abstractions.Contracts.IDevice,
                            Device = null,
                            Text = "TestDeviceAirLinkApp",
                            //update credit remaining
                            CreditRemaining = "3",
                            //UPDATE Payg unit
                            PayGUnit = "d",

                            //Update credit status
                            CreditStatus = "#00FF00",

                            //update last update date
                            LastDateUpdate = DateTime.UtcNow.ToString("ddd, MMM dd yyyy"),
                            RSSITx = "1dBm",
                            Latitude = location.Latitude,
                            Longitude = location.Longitude,
                            LocationAccuracy = location.Accuracy
                        };
                        await SecureStorage.SetAsync("D_TestDeviceAirLinkApp", "easyAccessToken");
                        //Store data
                        Items.Add(testDeviceItem);
                        await DataStore.AddItemAsync(testDeviceItem);
                        PUEAdvertisedData pUEAdvertisedData = new PUEAdvertisedData()
                        {
                            Cr = testDeviceItem.CreditRemaining,
                            Pst = "",
                            Fv = "0.9",
                            Pu = "",
                            Ft = "",
                            Did = testDeviceItem.DeviceId,
                            Rv = "",
                            Gts = "",
                            Lt = testDeviceItem.Latitude.ToString(),
                            Ln = testDeviceItem.Longitude.ToString(),
                            La = testDeviceItem.LocationAccuracy.ToString(),
                            Gid = DependencyService.Get<IMobile>().GetIdentifier(),
                            Ssn = testDeviceItem.RSSITx
                        };
                        //Database connection

                        using (SQLiteConnection conn = new SQLiteConnection(App.DatabaseLocation))
                        {
                            //create table and insert into database!
                            conn.CreateTable<PUEAdvertisedData>();
                            int rows = conn.Insert(pUEAdvertisedData);

                            if (rows > 0)
                            {
                                Console.WriteLine("Success");
                            }
                            else
                            {
                                Console.WriteLine("Failed");
                            }

                        }

                    }

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
                            Text = itemDiscovered.Device.Name != null ? itemDiscovered.Device.Name : "Unknown",
                            Description = itemDiscovered.Device.Rssi.ToString() + " dBm",
                            Id = itemDiscovered.Device.Id.ToString(),
                            AddressAndName = itemDiscovered.Device.NativeDevice.ToString() + " / " + (itemDiscovered.Device.Name != null ? itemDiscovered.Device.Name : "Unknown"),
                            DeviceId = itemDiscovered.Device.NativeDevice.ToString(),
                            Device = itemDiscovered.Device,
                            RSSITx = itemDiscovered.Device.Rssi.ToString() + "dBm",
                            CreditRemaining = "0",
                            PayGUnit = char.ToString('H'),
                            LastDateUpdate = DateTime.Now.ToString("dd-MM-yy h:mm tt"),
                            Mfg = itemDiscovered.Device.AdvertisementRecords.Select(x => x.Type + "=0x" + x.Data?.ToArray()?.EncodeToBase16String()).Join(", "),
                            Flags = itemDiscovered.Device.Rssi.ToString() + "dBm",
                            MfgCBOR = itemDiscovered.Device.AdvertisementRecords,
                            KeyKnown = false //FIXME await SecureStorage.GetAsync("D_" + itemDiscovered.Device.NativeDevice.ToString()) != null
                        };


                        if (!Items.Any(x => x.Id == newListItem.Id) && itemDiscovered.Device.Name != null)
                        {
                            // Add discovered device to BleItem Model and Datastore Service
                            //FIXME REFACTOR USING THIS var advertData = newListItem.UpdateDeviceParamsFromAdvt(location);

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
                                    newListItem.Longitude =location.Longitude;
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
                                    //string locationText = location.Latitude.ToString() + " " + location.Longitude.ToString();
                                    //_ = _userDialogs.Alert(locationText);
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
                                        //create table and insert into database!
                                        conn.CreateTable<PUEAdvertisedData>();
                                        int rows = conn.Insert(pUEAdvertisedData);

                                        if (rows > 0)
                                        {
                                            Console.WriteLine("Success");
                                        }
                                        else
                                        {
                                            Console.WriteLine("Failed");
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
                            TimeSpan tSpanToRescan = (new DateTime(2021, 1, 1, 8, 5, 0)) - (new DateTime(2021, 1, 1, 8, 0, 0)); //FIXME make global constant or variable
                            if (updateListItem.LastScanTime - newListItem.LastScanTime > tSpanToRescan)
                            {
                                var advertData = newListItem.UpdateDeviceParamsFromAdvt(location);
                                updateListItem.Text = newListItem.Text;
                                updateListItem.Description = newListItem.Description;
                                updateListItem.AddressAndName = newListItem.AddressAndName;
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
                                updateListItem.KeyKnown = newListItem.KeyKnown;

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
                    // UserDialogs.Instance.Toast("Scanning Devices BLE Done");
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
                foreach(var item in formattedData)
                {
                    if(item.Contains('h'))
                    {
                        string cborData = item.Substring(3);
                        string fcborData = cborData.Substring(0, cborData.Length - 2);
                        return fcborData;
                    }
                }

            }catch (Exception)
            {
                _userDialogs.Alert("Process Failed","");
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
         *Takes the UUID/GUID as a refernce to ServerDeatailsPage
         */
        async void OnItemSelected(BleItem item)
        {

            if (item == null)
                return;
            try
            {
                var config = new ActionSheetConfig();

                /*config.Add("Connect", async () =>
                {*/
                    var adapter = CrossBluetoothLE.Current.Adapter;
                    Debug.WriteLine("Trying to connect to device..." + item.DeviceId);
                    await adapter.ConnectToDeviceAsync(item.Device);

                    Console.WriteLine(item.Id);
                    await Shell.Current.GoToAsync($"{nameof(ScannedDetailsPage)}?{nameof(BLEDeviceDetailsViewModel.ItemId)}={item.Id}");
                    
               /* });
                config.Cancel = new ActionSheetOption("Cancel");
                config.SetTitle("Device Options");
                UserDialogs.Instance.ActionSheet(config);*/

            }
            catch (Exception ex)
            {
                Debug.WriteLine(ex.ToString());
            }
        }
    }
}

/*
 * 
 * if (!Items.Any(x => x.Id == newListItem.Id) && itemDiscovered.Device.Name != null)
                        {
                            // Add discovered device to BleItem Model and Datastore Service
                            // if (!Items.Any(x => x.Id == newListItem.Id) && itemDiscovered.Device.Name != null)
                            //Formating advertised data and send to Cloud

                                var cbo = ManufacturedAdvertisedData(newListItem.Mfg);
                                byte[] cbor = DataConverter.StringToByteArray(cbo);
                                var jcbor = CBORObject.DecodeFromBytes(cbor);

                                newListItem.Flags = jcbor.ToString();
                               
                                //Sotre data
                                Items.Add(b);
                                await DataStore.AddItemAsync(b);

                                string customCborFormat = jcbor.ToString();
                                string cborRncode = CBORCustomdecode(customCborFormat);
                                //Advertised  data format
                                string adf_1 = cborRncode.Substring(0, 2);
                                string adf1_r = cborRncode.Remove(0, adf_1.Length);
                                string adf_2 = adf1_r.Substring(0, 2);
                                string adf2_r = adf1_r.Remove(0, adf_2.Length);
                                //int sample = DataConverter.HexToInt(adf_1);
                                //***********End of Advertised data*********************

                                // Resource Model Type
                                string rt = adf2_r.Substring(0, 2);
                                string rt_r = adf2_r.Remove(0, rt.Length);
                                // ************End of Resource Type**********************

                                // Device ID
                                string di = rt_r.Substring(0, 8);
                                string di_r = rt_r.Remove(0, di.Length);
                                // ************End of Device ID**********************

                                // Device Asset Status
                                string das = di_r.Substring(0, 2);
                                string das_r = di_r.Remove(0, das.Length);
                                // ************End of Device Asset Status**********************

                                //Device firmware Version
                                string dfv_1 = das_r.Substring(0, 2);
                                string dfv1_r = das_r.Remove(0, dfv_1.Length);
                                string dfv_2 = dfv1_r.Substring(0, 2);
                                string dvf2_r = dfv1_r.Remove(0, dfv_2.Length);
                                //***********End of Device firmware Version*********************

                                // Device Error Status
                                string des = dvf2_r.Substring(0, 2);
                                string des_r = dvf2_r.Remove(0, des.Length);
                                // ************End of Device Error Status**********************

                                //Timestamp of last PAYG Update to device
                                string tlp_1 = des_r.Substring(0, 8);
                                string tlp1_r = des_r.Remove(0, tlp_1.Length);
                                string tlp_2 = tlp1_r.Substring(0, 4);
                                string tlp2_r = tlp1_r.Remove(0, tlp_2.Length);
                                //***********End of Timestamp of last PAYG Update to device*********************

                                // Device PayG Credit Remaining
                                string dpc = tlp2_r.Substring(0, 4);
                                string dpc_r = tlp2_r.Remove(0, dpc.Length);
                                // ************End of Device PayG Credit Remaining**********************

                                // PayG Unit
                                string pu = dpc_r.Substring(0, 2);
                                string pu_r = dpc_r.Remove(0, pu.Length);
                                // ************End of PayG Unit**********************

                                //DateTime now = DateTime.Today;
                                //string currentYear = now.ToString("yyyy");
                                //string currentMSb = currentYear.Substring(2);
                                //PUEAd.Clear();
                                PUEAdvertisedData x = new PUEAdvertisedData
                                {
                                    Adf = DataConverter.HexToInt(adf_1).ToString() + "." + DataConverter.HexToInt(adf_2).ToString(),
                                    Rt = DataConverter.HexToInt(rt),
                                    Did = DataConverter.HexToInt(di),
                                    Ds = DataConverter.HexToInt(das),
                                    Fv = DataConverter.HexToInt(dfv_1).ToString() + "." + DataConverter.HexToInt(adf_2).ToString(),
                                    Er = DataConverter.HexToInt(des),
                                    Pts = DataConverter.HexToInt(tlp_1).ToString() + DataConverter.HexToInt(tlp_2).ToString(),
                                    Cr = DataConverter.HexToInt(dpc),
                                    Pu = DataConverter.BytesToASCII(DataConverter.StringToByteArray(pu)),
                                };

                                //Get Location 
                                    var request = new GeolocationRequest(GeolocationAccuracy.Medium, TimeSpan.FromSeconds(10));
                                    cts = new CancellationTokenSource(1000);
                                    var location = await Geolocation.GetLocationAsync(request, cts.Token);

                                    if (location != null)
                                    {
                                        var SendCbor = CBORObject.NewMap()
                                                    .Add("devName", x.Did)
                                                    .Add("adf", x.Adf)
                                                    .Add("rt", x.Rt)
                                                    .Add("did", x.Did)
                                                    .Add("ds", x.Ds)
                                                    .Add("er", x.Er)
                                                    .Add("pts", x.Pts)
                                                    .Add("cr", x.Cr)
                                                    .Add("pu", x.Pu)
                                                    .Add("fv", x.Fv)
                                                    .Add("lat", location.Latitude)
                                                    .Add("long", location.Longitude);
                                        byte[] bytes = SendCbor.EncodeToBytes();
                                        // PUEAd.Add(x);
                                        var cborHexstring = DataConverter.BytesToHexString(bytes);
                                        cborHexstring = cborHexstring.Replace("-", "");
                                        SendCbor.Add("cd", cborHexstring);
                                      /*  string url = "";
                                        HttpClient client = new HttpClient();

                                        var contents = SendCbor.ToJSONString();
                                        StringContent content = new StringContent(contents, Encoding.UTF8, "application/json");

                                        var response = await client.PostAsync(url, content);

                                        if (response.IsSuccessStatusCode)
                                        {
                                            Console.WriteLine(response);
                                        }
                                        //Console.WriteLine(response);
          }
      else
{
    _userDialogs.Alert("Turn On your Location Please");
}
   }
*/