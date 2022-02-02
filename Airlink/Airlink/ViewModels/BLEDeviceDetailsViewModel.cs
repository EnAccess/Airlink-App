using Acr.UserDialogs;
using Airlink.Models;
using Airlink.Services;
using Airlink.Views;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using PeterO.Cbor;
using Plugin.BLE;
using Plugin.BLE.Abstractions.Exceptions;
using Rg.Plugins.Popup.Services;
using System;
using System.Collections.ObjectModel;
using System.Diagnostics;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using Xamarin.Essentials;
using Xamarin.Forms;
using Xamarin.Forms.Xaml;
using System.Collections.Generic;
using nexus.core.text;
using System.Net.Http;

namespace Airlink.ViewModels
{
    [XamlCompilation(XamlCompilationOptions.Compile)]
    [QueryProperty(nameof(ItemId), nameof(ItemId))]
    public class BLEDeviceDetailsViewModel : BaseViewModel
    {
        CancellationTokenSource cts;
        private string _dataa;

        private string _itemId;

        private string _text;
        public string Id { get; set; }

        private bool _isBusy;
        private bool _isVisible;
        public new bool IsBusy
        {
            get { return _isBusy; }
            set { _isBusy = value; OnPropertyChanged(); }
        }
        public bool IsVisible
        {
            get { return _isVisible; }
            set { _isVisible = value; OnPropertyChanged(); }
        }

        public string Text
        {
            get => _text;
            set => SetProperty(ref _text, value);
        }

        public string DataSend
        {
            get => _dataa;
            set => SetProperty(ref _dataa, value);
        }
        public string ItemId
        {
            get
            {
                return _itemId;
            }
            set
            {
                _itemId = value;
                LoadItemId(value);
            }
        }
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
        public bool _isGridVisible;
        public bool IsGridVisible
        {
            get { return _isGridVisible; }
            set { _isGridVisible = value; OnPropertyChanged(); }
        }
        public bool _isScannerVisible;
        public bool IsScannerVisible
        {
            get { return _isScannerVisible; }
            set { _isScannerVisible = value; OnPropertyChanged(); }
        }
        public void StartScanning()
        {
            IsScanning = true;
            IsAnalyzing = true;
            IsGridVisible = false;
            IsScannerVisible = true;
        }
        public void StopScanning()
        {
            IsScanning = false;
            IsAnalyzing = false;
            IsGridVisible = true;
            IsScannerVisible = false;
        }

        private static int id = 1;
        public string deviceTitle { get { return deviceName; } }
        public static string deviceName;

        private string _wrvalue;
        public string WrValue
        {
            get => _wrvalue;
            set => SetProperty(ref _wrvalue, value);
        }
        public Property propertyId;
        public ObservableCollection<Resource> Resources { get; }

        public ObservableCollection<Property> Properties { get; }

        public ObservableCollection<Descriptor> Descriptors { get; }

        public ObservableCollection<ResourceAndProperties> ResourcesAndProperties { get; }

        public ObservableCollection<PropertiesAndDescriptors> PropertiesAndDescriptors { get; }

        public ObservableCollection<PropertyID> PropertyUUIDs { get; }

        public Command<string> ReadPropertyCommand { get; }

        public Command<string> CancelCommand { get; }

        public Command WriteValueCommand { get; }

        public KeyValuePair<string, string> ServerAttributes { get; set; }
        public BLEDeviceDetailsViewModel()
        {
            Title = "D_" + deviceName;

            //Resources
            Resources = new ObservableCollection<Resource>();

            //Properties
            Properties = new ObservableCollection<Property>();

            //PropertyUUID
            PropertyUUIDs = new ObservableCollection<PropertyID>();

            //Descriptors
            Descriptors = new ObservableCollection<Descriptor>();

            //Resource and Properties
            ResourcesAndProperties = new ObservableCollection<ResourceAndProperties>();

            //Read Button
            ReadPropertyCommand = new Command<string>(ReadCommandAsync);

            //Popup Ok Buttuon
            WriteValueCommand = new Command<string>(WriteValue);

            //Popup Cancel Button
            CancelCommand = new Command<string>(async async => await CancelPopup());
        }
        /*
         * Read Server Shared and Client Attributes to store into Device
         */
        public async void GetServerAttributes()
        {
            try
            {
                UserDialogs.Instance.ShowLoading("Syncing data, please wait...");
                HttpClient getclient = new HttpClient();

                string url = HttpsEndpoint.ApiEndPoint("getAttributes", deviceName);
                if (string.IsNullOrEmpty(url))
                {
                    UserDialogs.Instance.Alert("Please make sure the Server Information is not Empty", "");
                }
                else
                {
                    getclient.DefaultRequestHeaders.Accept.Clear();
                    var getTask = getclient.GetAsync(url);
                    var response = await getTask;
                    var attributesFromServer = await response.Content.ReadAsStringAsync();
                    //Debug.WriteLine("GET response attributesFromServer: " + attributesFromServer);

                    JObject jsonObj = JObject.Parse(attributesFromServer);
                    //get shared attributes and serialize them to object
                    JObject sharedObj = (JObject)jsonObj["shared"];

                    bool postToServer = true;

                    await ReadWritePostResource(sharedObj, postToServer);

                }


            }
            catch (Exception ex)
            {
                Debug.WriteLine("Error syncing data." + ex.Message);
                UserDialogs.Instance.HideLoading();
                UserDialogs.Instance.Alert("Error syncing data.", "Error!");
            }
        }


        /* Get services, charactersitics and descriptors
         * Read descriptors
         * Match descriptor name with JSONdata key prefix
         * Write to the particular resource containing that descriptor name
         * 
         * The function also checks whether to post all device resource data to the IoT server
         */
        JObject DeviceJsonObj;
        public async Task ReadWritePostResource(JObject JsonObj, bool postToServer)
        {
            List<Task> postToServerTasks = new List<Task>();
            List<Task> Tasks = new List<Task>();

            var item = await DataStore.GetItemAsync(ItemId);

            var services = await item.Device.GetServicesAsync();

            foreach (var service in services)
            {
                if (service.Id.ToString().StartsWith("0000180")) continue; //Skip Generic UUIDs
                var characteristics = await service.GetCharacteristicsAsync();

                // Looping the OCF Resource properties
                foreach (var characteristic in characteristics)
                {
                    if (postToServer)
                    {
                        var cbytes = await characteristic.ReadAsync();
                        string hexData = DataConverter.BytesToHexString(cbytes);
                        string json = await PayGData.ReadDataFromBLEAysnc(hexData);
                        DeviceJsonObj = JObject.Parse(json);

                    }
                    //Get descriptors
                    var descriptors = await characteristic.GetDescriptorsAsync();

                    foreach (var descriptor in descriptors)
                    {
                        //Read descriptors
                        var bytes = await descriptor.ReadAsync();
                        string descriptorHexString = bytes.EncodeToBase16String();

                        // Skip if it is not a user descriptor aka 2901
                        if (!descriptor.Id.Equals(Guid.Parse("00002901-0000-1000-8000-00805f9b34fb")))
                        {
                            continue;
                        }

                        //Convert the descriptor value from hex to ascii
                        string descriptorValue = string.Empty;
                        for (int a = 0; a < descriptorHexString.Length - 2; a += 2)

                        {
                            string Char2Convert = descriptorHexString.Substring(a, 2);
                            int n = Convert.ToInt32(Char2Convert, 16);
                            char c = (char)n;
                            descriptorValue += c.ToString();
                        }

                        if (JsonObj == null)
                        {
                            Debug.WriteLine("No data available");
                        }
                        else
                        {
                            foreach (JProperty property in JsonObj.Properties())
                            {
                                //get attributes prefix only
                                string stringBeforeChar = property.Name.Substring(0, property.Name.IndexOf("_"));

                                string contents = string.Empty;
                                if (stringBeforeChar == descriptorValue.ToUpper())
                                {
                                    //remove descriptor prefix from attributes
                                    string newPropertyName = property.Name.Substring(property.Name.IndexOf('_') + 1);

                                    if (property.Value.Type.ToString() == "Integer")
                                    {
                                        contents = "{\"" + newPropertyName + "\" : " + property.Value + "}";
                                    }
                                    else if (property.Value.Type.ToString() == "String")
                                    {
                                        contents = "{\"" + newPropertyName + "\" : \"" + property.Value.ToString() + "\"}";
                                    }

                                    var cborJsonData = CBORObject.FromJSONString(contents);
                                    byte[] cborData = cborJsonData.EncodeToBytes();

                                    if (characteristic.CanWrite)
                                    {
                                        //Write attributes to the Ble device
                                        try
                                        {
                                            await characteristic.WriteAsync(cborData);
                                            Debug.WriteLine("Data is successfully written to device!");
                                        }
                                        catch (Exception ex)
                                        {
                                            Debug.WriteLine($"Error on writing attributes to BLE device. {ex.Message}");
                                        }
                                    }
                                    else
                                    {
                                        Debug.WriteLine("This property cannot be written. It is a ReadOnly property.");
                                    }
                                }
                            }

                        }

                        if (postToServer)
                        {
                            Tasks.Add(PostBleDataToServerAsync(DeviceJsonObj, postToServerTasks, descriptorValue));
                        }

                    }

                }
            }

            await Task.WhenAll(Tasks);
            UserDialogs.Instance.HideLoading();
            UserDialogs.Instance.Alert("Success!");

        }


        public async Task WriteBytesToDevice(string propertyAttribute, byte[] cborData)
        {
            var item = await DataStore.GetItemAsync(ItemId);
            var services = await item.Device.GetServicesAsync();

            foreach (var service in services)
            {
                if (service.Id.ToString().StartsWith("0000180")) continue; //Skip Generic UUIDs
                var characteristics = await service.GetCharacteristicsAsync();

                // Looping the OCF Resource properties
                foreach (var characteristic in characteristics)
                {
                    //Get descriptors
                    var descriptors = await characteristic.GetDescriptorsAsync();

                    foreach (var descriptor in descriptors)
                    {
                        //Read descriptors
                        var bytes = await descriptor.ReadAsync();
                        string descriptorHexString = bytes.EncodeToBase16String();

                        //Convert the descriptor value from hex to ascii
                        string descriptorValue = string.Empty;
                        for (int a = 0; a < descriptorHexString.Length - 2; a += 2)

                        {
                            string Char2Convert = descriptorHexString.Substring(a, 2);
                            int n = Convert.ToInt32(Char2Convert, 16);
                            char c = (char)n;
                            descriptorValue += c.ToString();
                        }

                        if (propertyAttribute == null)
                        {
                            Debug.WriteLine("No data available");
                        }
                        else
                        {
                            //get attributes prefix only
                            string attrPrefix = propertyAttribute.Substring(0, propertyAttribute.IndexOf("_"));

                            //get attribute name by remove its prefix
                            string attrName = propertyAttribute.Substring(propertyAttribute.IndexOf('_') + 1).ToLower();

                            if (attrPrefix.ToUpper() == descriptorValue.ToUpper())
                            {
                                if (characteristic.CanWrite)
                                {
                                    //Write attributes to the Ble device
                                    try
                                    {
                                        var cbor = CBORObject.NewMap().Add(attrName, cborData);
                                        // The following converts the map to CBOR
                                        byte[] cborBytes = cbor.EncodeToBytes();

                                        bool isSuccessfullyWritten = await characteristic.WriteAsync(cborBytes);
                                        if (isSuccessfullyWritten)
                                        {
                                            Debug.WriteLine("Data is successfully written to device!");
                                        }
                                        else
                                        {
                                            Debug.WriteLine("Error! Data is not written to the device");
                                        }

                                    }
                                    catch (Exception ex)
                                    {
                                        Debug.WriteLine($"Error on writing attributes to BLE device. {ex.Message}");
                                    }
                                }
                                else
                                {
                                    Debug.WriteLine("This property cannot be written. It is a ReadOnly property.");
                                }
                            }

                        }

                    }

                }
            }

        }


        //Post Ble data to server 
        private static async Task PostBleDataToServerAsync(JObject deviceJsonObj, List<Task> postToServerTasks, string descriptorValue)
        {
            foreach (JProperty property in deviceJsonObj.Properties())
            {
                string contentsToSend;
                //checked if descriptors contain characters
                if (descriptorValue.Length > 1)
                {
                    //create a json string content to send to server
                    contentsToSend = "{\"" + descriptorValue.ToUpper() + "_" + property.Name.ToString() + "\" : \"" + property.Value.ToString() + "\"}";
                }
                else
                {
                    //create a json string content to send to server
                    contentsToSend = "{\"" + "_" + property.Name.ToString() + "\" : \"" + property.Value.ToString() + "\"}";
                }

                //send the data to server
                postToServerTasks.Add(AirLinkServer.PostToAirLinkServer(contentsToSend, deviceName, "telemetry"));
            }
            await Task.WhenAll(postToServerTasks);
        }


        /*
         * Read the OCF Resource property with the UUID
         */
        public async void ReadCommandAsync(string xid)
        {
            try
            {
                UserDialogs.Instance.ShowLoading("Loading..");
                //Find the Property from the Property List using the ID
                propertyId = Properties.FirstOrDefault(o => o.Id == xid);

                if (propertyId != null && propertyId.Read)
                {
                    //Read from the Property
                    byte[] rvalue = await propertyId.IProperty.ReadAsync();
                    string hexResult = DataConverter.BytesToHexString(rvalue);

                    Debug.WriteLine(hexResult.ToString());

                    string json = await PayGData.ReadDataFromBLEAysnc(hexResult);

                    UserDialogs.Instance.HideLoading();
                    UserDialogs.Instance.Alert($"{json}", "");
                }
                else
                {
                    UserDialogs.Instance.Alert("Sorry The Property cannot be read.", "ERROR!");
                    Debug.WriteLine("Sorry The Property cannot be Read! ", "");
                }

            }
            catch (Exception ex)
            {
                UserDialogs.Instance.HideLoading();
                UserDialogs.Instance.Alert($"{ex.Message}", "Error");
            }

        }


        /*
         * Write To the Resource Property with the UUID
         * Use the UUID to select only selected property from the Selected Resources
         * Write to a property
         * Read what is writen to a property
         * Display the readings
         * Delete temporary property storage
         * Delete temporary property id storage
         */
        public async void WriteToProperty(string data, string puiid)
        {
            try
            {
                if (data != null && puiid != null)
                {
                    //Take cbor format from Json
                    //var cborJsonData = (JObject)JsonConvert.DeserializeObject(data);
                    //string cborData = cborJsonData["cbor"].Value<string>();
                    //Find the Property from the Property List using the ID
                    var item = await AllPropertyDataStore.GetItemAsync(puiid);
                    var cborJsonData = CBORObject.FromJSONString(data);
                    byte[] cborData = cborJsonData.EncodeToBytes();
                    if (cborData.Length < 100)
                    {
                        bool wrvalue = await item.IProperty.WriteAsync(cborData);

                        if (wrvalue && item.Read)
                        {

                            byte[] rvalue = await item.IProperty.ReadAsync();

                            var cborString = CBORObject.DecodeFromBytes(rvalue);
                            string cbor = cborString.ToString();
                            string hexResult = DataConverter.BytesToHexString(rvalue);
                            _ = UserDialogs.Instance.Alert($"Json! : {cbor}", "");
                        }
                        else
                        {
                            _ = UserDialogs.Instance.Alert("The property cannot be read", "");
                        }
                    }
                    else
                    {
                        Debug.WriteLine("You are writing more than 100 bytes of data", "");
                    }

                    _ = await AllPropertyDataStore.DeleteItemsAsync();
                    _ = await PropertyDataStore.DeleteItemsAsync();
                }
            }
            catch (Exception ex)
            {
                Debug.WriteLine(ex.Message);
            }


        }

        /*
         * Cancel the Popup Page
         * Clear the temporary Property and Property id storages
         */
        private async Task CancelPopup()
        {
            try
            {
                _ = await AllPropertyDataStore.DeleteItemsAsync();
                _ = await PropertyDataStore.DeleteItemsAsync();
                await PopupNavigation.PopAllAsync();
            }
            catch (Exception ex)
            {
                Debug.WriteLine(ex.Message);
            }

        }
        /*
         * Get the Property UUID and Values to write
         * Use the temporary UUID stored and Vulee to call the WriteToProperty method
         * Call the methos to Write
         * After Close the popup page
         */
        public async void WriteValue(string xid)
        {
            try
            {
                //Get Location v
                var request = new GeolocationRequest(GeolocationAccuracy.High, TimeSpan.FromSeconds(10));
                cts = new CancellationTokenSource();
                var location = await Geolocation.GetLocationAsync(request, cts.Token);

                if (location != null)
                {

                    var SendCbor = CBORObject.NewMap()
                                .Add("tkn", 123456789987654321)
                                .Add("tsc", "210819")
                                .Add("lcr", $"{DateTime.Now}")
                                .Add("lat", $"{location.Latitude}")
                                .Add("long", $"{location.Longitude}")
                                .Add("acc", $"{location.Accuracy}");
                    byte[] bytes = SendCbor.EncodeToBytes();
                    // PUEAd.Add(x);
                    var cborHexstring = DataConverter.BytesToHexString(bytes);
                    cborHexstring = cborHexstring.Replace("-", "");

                    string data = cborHexstring;
                    //string data = WrValue;
                    var item = await PropertyDataStore.GetItemAsync();

                    string propertID = item.PropertyUUID.ToString();
                    WriteToProperty(data, propertID);

                    _ = PopupNavigation.Instance.PopAsync();
                }
            }
            catch (Exception ex)
            {
                Debug.WriteLine(ex.Message);
            }

        }
        /*
         * Discovers the OCF Resources and assign it to Resource Model
         * Discover OCF Resource properties assign it to Property Model
         * Assigns All the OCF Rescource prpoerty to its particullar OCF resource.
         */
        public async void LoadItemId(string itemId)
        {

            try
            {
                IsBusy = true;
                IsVisible = false;
                //Debug.WriteLine("ITEMIDTXT: "+itemId);
                var item = await DataStore.GetItemAsync(itemId);

                Id = item.Id;
                //Debug.WriteLine("ITEMID: " + item.Id);
                //Text = item.AddressAndName;
                Text = item.Address;
                deviceName = item.DeviceId;
                MessagingCenter.Send<App, string>((App)Application.Current, "UpdateDevID", deviceName);
                //Debug.WriteLine("ITEMNAME: " + deviceName);
                try
                {
                    //Acr.UserDialogs.UserDialogs.Instance.Alert("Connect Success!", "");
                    DataSend += "Trying to discover services...\r\n";

                    var services = await item.Device.GetServicesAsync();

                    // Looping the OCF Resources to get the OCF Resource properties
                    foreach (var service in services)
                    {
                        if (service.Id.ToString().StartsWith("0000180")) continue; //Skip Generic UUIDs
                        var characteristics = await service.GetCharacteristicsAsync();

                        // Looping the OCF Resource properties and adding it Property Model
                        foreach (var characteristic in characteristics)
                        {
                            //Get descriptors
                            var descriptors = await characteristic.GetDescriptorsAsync();

                            foreach (var descriptor in descriptors)
                            {
                                //Read descriptors
                                var bytes = await descriptor.ReadAsync();
                                string descriptorHexString = bytes.EncodeToBase16String();

                                // Skip if it is not a user descriptor aka 2901
                                if (!descriptor.Id.Equals(Guid.Parse("00002901-0000-1000-8000-00805f9b34fb")))
                                {
                                    await descriptor.WriteAsync(new byte[2] { 02, 00 });
                                    continue;
                                }

                                //Convert the descriptor value from hex to ascii
                                string descriptorValue = string.Empty;
                                for (int a = 0; a < descriptorHexString.Length - 2; a += 2)

                                {
                                    string Char2Convert = descriptorHexString.Substring(a, 2);
                                    int n = Convert.ToInt32(Char2Convert, 16);
                                    char c = (char)n;
                                    descriptorValue += c.ToString();
                                }

                                Property bc = new Property
                                {
                                    Id = characteristic.Id.ToString(),
                                    Name = descriptorValue,
                                    Read = characteristic.CanRead,
                                    Update = characteristic.CanUpdate,
                                    Write = characteristic.CanWrite,
                                    Servicename = service.Name,
                                    ServiceID = service.Id.ToString(),
                                    IProperty = characteristic,
                                    DescriptorList = Descriptors,

                                };

                                Properties.Add(bc);

                            }

                        }

                        // Adding the OCF Resources and OCF resource properties to A Resource Model

                        Resource bs = new Resource
                        {
                            Id = service.Id.ToString(),
                            Name = service.Name,
                            PropertiesList = Properties,

                        };
                        Resources.Add(bs);
                    }


                    //Assign the OCF Recource Property to its particular OCF Resource 

                    ResourcesAndProperties.Clear();

                    foreach (Resource c in Resources)
                    {
                        var xc = Properties.Where(x => x.ServiceID == c.Id).ToList();
                        ObservableCollection<Property> collection = new ObservableCollection<Property>(xc);
                        ResourceAndProperties svx = new ResourceAndProperties
                        {
                            Id = c.Id,
                            Name = c.Name,
                            PropertiesList = collection,
                        };
                        ResourcesAndProperties.Add(svx);
                    }

                    IsBusy = false;
                    IsVisible = true;

                }
                catch (DeviceConnectionException ex)
                {
                    Debug.WriteLine("Error " + ex.Message + ", please try again.");
                }


            }
            catch (Exception ex)
            {
                Debug.WriteLine("Error " + ex.Message + ", please try again.");
            }
        }
        /*
         * Auto increment 
         */
        private static int GenerateId()
        {
            return id++;
        }
        /*
         * Disconnect on Disapperaing
         */
        public async void OnDisappearingAsync()
        {
            var adapter = CrossBluetoothLE.Current.Adapter;

            var item = await DataStore.GetItemAsync(ItemId);

            await adapter.DisconnectDeviceAsync(item.Device);

        }


    }
}
