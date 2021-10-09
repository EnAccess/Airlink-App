using Acr.UserDialogs;
using Airlink.Models;
using Airlink.Views;
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

namespace Airlink.ViewModels 
{
    public class ServersViewModel : BaseViewModel
    {
        private BleDevice _selectedItem;
        private IUserDialogs _userDialogs;

        CancellationTokenSource cts;
        public ObservableCollection<BleDevice> Items { get; }
        public ObservableCollection<PUEAdvertisedData> PUEAd { get; }
        public Command LoadItemsCommand { get; }
        public Command AddItemCommand { get; }
        public Command<BleDevice> ItemTapped { get; }
        public IBluetoothLowEnergyAdapter Ta { get; set; }

        public ServersViewModel()
        {

            Title = "Scanned Devices";

            MessagingCenter.Subscribe<App, IBluetoothLowEnergyAdapter>((App)Application.Current, "SendAdppter", (sender, arg) =>
            {
                Ta = arg;
            });

            Items = new ObservableCollection<BleDevice>();
            LoadItemsCommand = new Command(async () => await ExecuteLoadItemsCommand());
            ItemTapped = new Command<BleDevice>(OnItemSelected);

            MessagingCenter.Send((App)Application.Current, "IBluetoothLowEnergyAdapterX", "");
        }

        /* 
         * The method is used to scan and discover all BluetoothLE available within the area
         * Checks if the Location and bluetooth permission are granted
         * Discover devices by getting the device name, UUID, RSSI, Advertised data
         * Add scanned devices to BleDevice Model
         *
         */
        private async Task ExecuteLoadItemsCommand()
        {
            
            IsBusy = true;
            _ = UserDialogs.Instance.Toast("Looking for AirLink Devices...");
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
                                UserDialogs.Instance.Toast("Please Permit Bluetooth Access");
                                return;
                            }
                        }
                    }

                   
                    // Initialize bluetooth device conncetion
                    var ble = CrossBluetoothLE.Current;
                    var adapter = CrossBluetoothLE.Current.Adapter;
                    var state = ble.State;
                   // List<object> deviceList = new List<object>();

                    // Discover available connection
                    adapter.DeviceDiscovered += async (s, a) =>
                    {


                        BleDevice b = new BleDevice
                        {
                            Text = a.Device.Name != null ? a.Device.Name : "Unknown",
                            Description = a.Device.Rssi.ToString() + " dBm",
                            Id = a.Device.Id.ToString(),
                            AddressAndName = a.Device.NativeDevice.ToString() + " / " + (a.Device.Name != null ? a.Device.Name : "Unknown"),
                            DeviceId = a.Device.NativeDevice.ToString(),
                            Device = a.Device,
                            RSSITx = a.Device.Rssi.ToString() + "dBm",
                            CreditRemaining = "0",
                            PayGUnit = char.ToString('H'),
                            LastDateUpdate = DateTime.Now.ToString("dd-MM-yy h:mm tt"),
                            Mfg = a.Device.AdvertisementRecords.Select(x => x.Type + "=0x" + x.Data?.ToArray()?.EncodeToBase16String()).Join(", "),
                            Flags = a.Device.Rssi.ToString() + "dBm",
                            MfgCBOR = a.Device.AdvertisementRecords,
                        };

                        if (!Items.Any(x => x.Id == b.Id) && a.Device.Name != null)
                        {
                            // Add discovered device to BleDevice Model and Datastore Service

                            
                            try
                            {
                                //Formating advertised data and send to Cloud
                                var cbo = ManufacturedAdvertisedData(b.Mfg);
                                byte[] cbor = DataConverter.StringToByteArray(cbo);
                                var jcbor = CBORObject.DecodeFromBytes(cbor);
                                var ob = jcbor.ToString();

                                b.Flags = ob;

                                ob = ob.Replace("\t", "").Replace("\n", "").Replace("\r", "").Replace("[", "").Replace("]", "").Replace("\"", "").Trim();

                                
                                string[] advertData = ob.Split(',');

                                //Device id
                                b.DeviceId = advertData[2];
                                //update credit remaining
                                b.CreditRemaining = advertData[6];
                                //UPDATE Payg unit
                                b.PayGUnit = advertData[7];

                                //Update credit status
                                int creditStatus = Int32.Parse(advertData[6]);
                                if(creditStatus > 0)
                                {
                                    b.CreditStatus = "#00FF00";
                                }
                                else
                                {
                                    b.CreditStatus = "#EA7979";
                                }
                                //update last update date
                                long dateLast = long.Parse(advertData[3]);
                                DateTimeOffset dateTimeOffset = DateTimeOffset.FromUnixTimeSeconds(dateLast);
                                b.LastDateUpdate = dateTimeOffset.Date.ToString("ddd, MMM dd yyyy");
                               
                                //Sotre data
                                Items.Add(b);
                                await GetDataStore().AddItemAsync(b);

                                //Get Location 
                                var request = new GeolocationRequest(GeolocationAccuracy.Medium, TimeSpan.FromSeconds(100));
                                cts = new CancellationTokenSource(1000);
                                var location = await Geolocation.GetLocationAsync(request, cts.Token);

                                if (location == null)
                                {
                                    _userDialogs.Alert("Turn On your Location Please");
                                }
                                else
                                {
                                 
                                    PUEAdvertisedData pUEAdvertisedData = new PUEAdvertisedData()
                                    {
                                        Cr = advertData[6],
                                        Pst = advertData[4],
                                        Fv = advertData[5],
                                        Pu = advertData[7],
                                        Ft = advertData[1],
                                        Did = advertData[2],
                                        Rv = advertData[0],
                                        Gts = advertData[3],
                                        Lt = $"{location.Latitude}",
                                        Ln = $"{location.Longitude}",
                                        La = $"{location.Accuracy}",
                                        Ssn = b.RSSITx
                                    };
                                    //Database connection

                                    using (SQLiteConnection conn = new SQLiteConnection(App.DatabaseLocation))
                                    {
                                        //create table and insert into database!
                                        conn.CreateTable<PUEAdvertisedData>();
                                        
                                            //Instert data in a database
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
                            catch (Exception)
                            {

                            }
                           
                        }
                        else if (a.Device.Name != null)
                        {
                            BleDevice c = await GetDataStore().GetItemAsync(b.Id);
                            c.Text = b.Text;
                            c.Description = b.Description;
                            c.AddressAndName = b.AddressAndName;
                            c.Device = b.Device;
                            c.RSSITx = b.RSSITx;
                            c.DeviceId = b.DeviceId;
                            c.CreditRemaining = b.CreditRemaining;
                            c.PayGUnit = b.PayGUnit;
                            c.LastDateUpdate = b.LastDateUpdate;
                            c.Mfg = b.Mfg;
                            c.Flags = b.Flags;
                            c.MfgCBOR = b.MfgCBOR;
                            c.CreditStatus = b.CreditStatus;

                            await GetDataStore().UpdateItemAsync(c);
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
                    UserDialogs.Instance.Toast("Scanning Devices BLE Done");
                }
            }

            using (SQLiteConnection con = new SQLiteConnection(App.DatabaseLocation))
            {
                con.CreateTable<PUEAdvertisedData>();
                var pueAdvertdata = con.Table<PUEAdvertisedData>().ToList();

                foreach(var data in pueAdvertdata)
                {
                    var SendCbor = CBORObject.NewMap()
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
                            .Add("ln", data.Ln);

                    byte[] bytes = SendCbor.EncodeToBytes();
                    // PUEAd.Add(x);
                    var cborHexstring = DataConverter.BytesToHexString(bytes);
                    cborHexstring = cborHexstring.Replace("-", "");
                    SendCbor.Add("cbor", cborHexstring);
                    var contents = SendCbor.ToJSONString();

                    //post data to IoT Engine
                    if (await PostData.PostTelemetry(contents))
                    {
                        //Delete data from a local database
                        con.Delete<PUEAdvertisedData>(data.Id);
                    }
                }
                // Clear the databse
                con.DeleteAll<PUEAdvertisedData>(); 
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
            catch (Exception)
            {
                _userDialogs.Alert("Process Failed");
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

        public BleDevice SelectedItem
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
        async void OnItemSelected(BleDevice item)
        {

            if (item == null)
                return;
            try
            {
                var config = new ActionSheetConfig();

                /*config.Add("Connect", async () =>
                {*/
                    var adapter = CrossBluetoothLE.Current.Adapter;
                    UserDialogs.Instance.Toast("Trying to connect to device...");
                    await adapter.ConnectToDeviceAsync(item.Device);

                    Console.WriteLine(item.Id);
                     await Shell.Current.GoToAsync($"{nameof(ScannedDetailsPage)}?{nameof(ServerDetailsViewModel.ItemId)}={item.Id}");
                    
               /* });
                config.Cancel = new ActionSheetOption("Cancel");
                config.SetTitle("Device Options");
                UserDialogs.Instance.ActionSheet(config);*/

            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine(ex.ToString());
            }
        }
    }
}

/*
 * 
 * if (!Items.Any(x => x.Id == b.Id) && a.Device.Name != null)
                        {
                            // Add discovered device to BleDevice Model and Datastore Service
                            // if (!Items.Any(x => x.Id == b.Id) && a.Device.Name != null)
                            //Formating advertised data and send to Cloud

                                var cbo = ManufacturedAdvertisedData(b.Mfg);
                                byte[] cbor = DataConverter.StringToByteArray(cbo);
                                var jcbor = CBORObject.DecodeFromBytes(cbor);

                                b.Flags = jcbor.ToString();
                               
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
                                                    .Add("lat", $"{location.Latitude}")
                                                    .Add("long", $"{location.Longitude}");
                                        byte[] bytes = SendCbor.EncodeToBytes();
                                        // PUEAd.Add(x);
                                        var cborHexstring = DataConverter.BytesToHexString(bytes);
                                        cborHexstring = cborHexstring.Replace("-", "");
                                        SendCbor.Add("cd", cborHexstring);
                                      /*  string url = "https://airlink.enaccess.org/api/v1/integrations/http/13fdd7a5-8ca8-8896-d489-62e808de6802";
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