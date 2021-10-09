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

namespace Airlink.ViewModels
{
    [QueryProperty(nameof(ItemId), nameof(ItemId))]
    public class ServerDetailsViewModel : BaseViewModel
    {
        CancellationTokenSource cts;
        private string _dataa;

        private string _itemId;

        private string _text;
        public string Id { get; set; }
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

        public ObservableCollection<ResourceAndProperties> ResourcesAndProperties { get; }

        public ObservableCollection<PropertyID> PropertyUUIDs { get; }

        public Command<string> ReadPropertyCommand { get; }

        public Command<string> WritePropertyCommand { get; }

        public Command<string> CancelCommand { get; }

        public Command WriteValueCommand { get; }
        public ServerDetailsViewModel()
        {
            Title = "Device Information";

            //Resources
            Resources = new ObservableCollection<Resource>();

            //Properties
            Properties = new ObservableCollection<Property>();

            //PropertyUUID
            PropertyUUIDs = new ObservableCollection<PropertyID>();

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
                     WriteCommandAsync(xid);

                }
                else
                {
                     UserDialogs.Instance.Alert("Sorry.! The Property Can not Read! ", "");
                }

            }
            catch (Exception)
            {
                UserDialogs.Instance.Toast("Error, please try again.");
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
                    UserDialogs.Instance.Alert("The Property can not Write....! ", "");
                }

            }
            catch (Exception)
            {
                _ = UserDialogs.Instance.Toast("Error, please try again.");
            }
           
        }

        /*
         * Write To the Resource Property with the UUID
         * Use the UUID to select only selected property from the Selected Resources
         * Write to a property
         * Read what os writen to a property
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
                    if (cborData.Length < 100)
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
                            _ = UserDialogs.Instance.Alert("Successfully!  The property do not read", "");
                        }
                    }
                    else
                    {
                        _ = UserDialogs.Instance.Alert("You can write more than 100 bytes of data", "");
                    }
                    
                    _ = await AllPropertyDataStore.DeleteItemsAsync();
                    _ = await PropertyDataStore.DeleteItemsAsync();
                }
            }
            catch (Exception)
            {
                UserDialogs.Instance.Toast("Error, please try again.");
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
            catch (Exception)
            {
                UserDialogs.Instance.Toast("Error, please try again.");
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
            catch (Exception)
            {
                UserDialogs.Instance.Toast("Error, please try again.");
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
                Debug.WriteLine(itemId);
                var item = await DataStore.GetItemAsync(itemId);

                Id = item.Id;
                Text = item.AddressAndName;
                try
                {
                    Acr.UserDialogs.UserDialogs.Instance.Alert("Connect Success!", "");
                    DataSend += "Try to discover services...\r\n";

                    var resources = await item.Device.GetServicesAsync();

                    deviceName = item.Device.Name;

                    // Looping the OCF Resources to get the OCF Resource properties
                    foreach (var rescource in resources)
                    {
                        
                        var properties = await rescource.GetCharacteristicsAsync();

                        // Looping the OCF Resource properties and adding it Property Model
                        foreach (var property in properties)
                        {
                           
                            Property bc = new Property
                            {
                                Id = property.Id.ToString(),
                                Name = property.Name,
                                Read = property.CanRead,
                                Update = property.CanUpdate,
                                Write = property.CanWrite,
                                Servicename = rescource.Name,
                                ServiceID = rescource.Id.ToString(),
                                IProperty = property,
                            };
                            Properties.Add(bc);

                            
                        }
                      
                        // Adding the OCF Resources and OCF resource properties to A Resource Model
                        Resource bs = new Resource
                        {
                            Id = rescource.Id.ToString(),
                            Name = rescource.Name,
                            PropertiesList = Properties,
                        };
                        Resources.Add(bs);

                    }

                    /*
                     * Assign the OCF Recource Property to its particular OCF Resource 
                     */
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

                    Console.WriteLine(ResourcesAndProperties);
                }
                catch (DeviceConnectionException ex)
                {
                    UserDialogs.Instance.Toast("Error, please try again.");
                }

            }
            catch (Exception)
            {
                UserDialogs.Instance.Toast("Error, please try again.");
            }
        }
        /*
         * Auto increment 
         */
        private static int generateId()
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
