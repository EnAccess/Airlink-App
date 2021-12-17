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

        public Command<string> WritePropertyCommand { get; }

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

            //Write Button
            WritePropertyCommand = new Command<string>(WriteCommandAsync);

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
                var item = await DataStore.GetItemAsync(ItemId);
                Debug.WriteLine("Retrieved item " + item.DeviceId);

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

                    var services = await item.Device.GetServicesAsync();

                    // Looping the OCF Resources to get the OCF Resource properties
                    foreach (var service in services)
                    {
                        if (service.Id.ToString().StartsWith("0000180")) continue; //Skip Generic UUIDs
                        var characteristics = await service.GetCharacteristicsAsync();

                        // Looping the OCF Resource properties and adding it Property Model
                        foreach (var characteristic in characteristics)
                        {
                            //Read characteristic
                            var cbytes = await characteristic.ReadAsync();
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

                                Debug.WriteLine(characteristic.Id.ToString() + " - " + descriptorValue);
                                Debug.WriteLine("Charactersitic properties: " + characteristic.Properties);

                                foreach (JProperty property in sharedObj.Properties())
                                {
                                    //get attributes prefix only
                                    string stringBeforeChar = property.Name.Substring(0, property.Name.IndexOf("_"));
                                    //Debug.WriteLine(stringBeforeChar);
                                    string contents = string.Empty;
                                    string newPropertyName = string.Empty;
                                    if (stringBeforeChar == descriptorValue.ToUpper())
                                    {
                                        //remove descriptor prefix from attributes
                                        newPropertyName = property.Name.Substring(property.Name.IndexOf('_') + 1);

                                        if (property.Value.Type.ToString() == "Integer")
                                        {
                                            contents = "{\"" + newPropertyName + "\" : " + property.Value + "}";
                                        }
                                        else if(property.Value.Type.ToString() == "String")
                                        {
                                            contents = "{\"" + newPropertyName + "\" : \"" + property.Value.ToString() + "\"}";
                                        }

                                        var cborJsonData = CBORObject.FromJSONString(contents);
                                        byte[] cborData = cborJsonData.EncodeToBytes();
                                        string hexResult = DataConverter.BytesToHexString(cborData);
                                        hexResult = hexResult.Replace("-", " ");
                                        //Debug.WriteLine(contents + " - " + hexResult);

                                        if (characteristic.CanWrite)
                                        {
                                            //Write shared attributes from the server to the Ble device
                                            await characteristic.WriteAsync(cborData);
                                            Debug.WriteLine("Data is successfully written to device!");
                                        }
                                        else
                                        {
                                            Debug.WriteLine("This property cannot be written. It is a ReadOnly property.");
                                        }

                                    }

                                }

                                //Post data to server
                                string contentsToSend = string.Empty;
                                foreach (JProperty property in jsonObj.Properties())
                                {
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
                                    var postAttributes = await AirLinkServer.PostToAirLinkServer(contentsToSend, deviceName, "telemetry");
                                }

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
        /*
         * Read the OCF Resource property with the UUID
         */
        public async void ReadCommandAsync(string xid)
        {          
            try
            {
                //Find the Property from the Property List using the ID
                propertyId = Properties.FirstOrDefault(o => o.Id == xid);

                if (propertyId != null && propertyId.Read)
                {
                    //Read from the Property
                    byte[] rvalue = await propertyId.IProperty.ReadAsync();
                    string hexResult = DataConverter.BytesToHexString(rvalue);
                    string json = await PayGData.ReadDataFromBLEAysnc(hexResult);
                    //string result = CBORObject.DecodeFromBytes(rvalue).ToString();
                    string result = DataConverter.BytesToASCII(rvalue);

                    UserDialogs.Instance.Alert($"Json: {json}.!", "");
                    //Write to the Bluetooth Property
                    //FIXME WHY WAS THIS HERE: WriteCommandAsync(xid);

                }
                else
                {
                    Debug.WriteLine("Sorry The Property cannot be Read! ", "");
                }

            }
            catch (Exception ex)
            {
                Debug.WriteLine(ex.Message);
            }
            
        }

        /*
         * Check if we can Write To the Resource Property with the UUID
         * Use the UUID to select only selected property from the Selected Resources
         * Add the details of the selected property to a temporary property datastore
         * Add the the UUID of the Property
         * Check if the Property can Write if not cancel the process
         * if It can write Open the POPUP PAGE using Rg.plugin.popup Nuggets
         */
        public async void WriteCommandAsync(string xid)
        {
           
            try
            {
                //Find the Property from the Property List using the ID
                propertyId = Properties.FirstOrDefault(x => x.Id == xid);
                Property ac = new Property
                {
                    Id = propertyId.Id,
                    Read = propertyId.Read,
                    Write = propertyId.Write,
                    Update = propertyId.Update,
                    Name = propertyId.Name,
                    ServiceID = propertyId.ServiceID,
                    Servicename = propertyId.Servicename,
                    IProperty = propertyId.IProperty
                };
                Properties.Add(ac);
                await AllPropertyDataStore.AddItemAsync(ac);
                PropertyUUIDs.Clear();
                PropertyID bc = new PropertyID
                {
                    PropertyUUID = xid,
                };
                PropertyUUIDs.Add(bc);

                await PropertyDataStore.AddItemAsync(bc);

                if(propertyId != null && propertyId.Write)
                {
                    //Write to the Bluetooth Characteristics
                    string json = await PayGData.SendDataToBLEAsync();
                    WriteToProperty(json, xid);
                    //await  PopupNavigation.Instance.PushAsync(new WritetoPropertPopup(), true);
                }
                else
                {
                    Debug.WriteLine("Property Write Failed!", "");
                }

            }
            catch (Exception ex)
            {
                Debug.WriteLine(ex.Message);
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
                    // bool wrvalue = await item.IProperty.WriteAsync(Encoding.ASCII.GetBytes(cborData));
                   var cborJsonData = CBORObject.FromJSONString(data);
                   byte[] cborData = cborJsonData.EncodeToBytes();
                    if (cborData.Length < 100) //FIXME what about properties with more data
                    {
                        bool wrvalue = await item.IProperty.WriteAsync(cborData);

                        if (wrvalue && item.Read)
                        {

                            byte[] rvalue = await item.IProperty.ReadAsync();

                            var cborString = CBORObject.DecodeFromBytes(rvalue);
                            String cbor = cborString.ToString();
                            string hexResult = DataConverter.BytesToHexString(rvalue);
                            _ = UserDialogs.Instance.Alert($"Json! : {cbor}", "");
                            //string hexResult = DataConverter.BytesToHexString(rvalue);

                            //string asciiresult = DataConverter.BytesToASCII(rvalue);
                            // _ = UserDialogs.Instance.Alert($"Successfully! Text: {asciiresult} Hex: {hexResult}", "");
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
                                .Add("tkn",123456789987654321)
                                .Add("tsc","210819")
                                .Add("lcr",$"{DateTime.Now}")
                                .Add("lat", $"{location.Latitude}")
                                .Add("long", $"{location.Longitude}")
                                .Add("acc",$"{location.Accuracy}");
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
                            //Read characteristic
                            var cbytes = await characteristic.ReadAsync();
                            string hexResult = DataConverter.BytesToHexString(cbytes);
                            string json = await PayGData.ReadDataFromBLEAysnc(hexResult);
                            
                            //Get descriptors
                            var descriptors = await characteristic.GetDescriptorsAsync();
                            
                            foreach (var descriptor in descriptors)
                            {
                                //Read descriptors
                                var bytes = await descriptor.ReadAsync();
                                string descriptorHexString = bytes.EncodeToBase16String();

                                //Convert the descriptor value from hex to ascii
                                string descriptorValue = string.Empty;
                                for (int a = 0; a < descriptorHexString.Length-2; a += 2)

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

                    //Console.WriteLine(ResourcesAndProperties);
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
