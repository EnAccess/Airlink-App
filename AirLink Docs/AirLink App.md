# AirLink App

The AirLink Mobile app is a communication app skeleton enabling gateway functionality i.e. end to end communication between AirLink Bluetooth® devices and an AirLink server. The app is intended to act as a base that takes care of device interactions, on which different customer experiences can be built by the businesses adopting AirLink. 

![AirLink Data Flow.png](AirLink%20App/AirLink_Data_Flow.png)

Once the *App Instance is authenticated to the tenant or customer by the application server transferring the provisioning codes, it can provision the phone as an AirLink gateway using the phone’s IMEI*. This allows flexibility in lost phones by tying functionality and device ownership to an authenticated user rather than a particular phone. The app provides a UI for entering these codes until the application server is enabled.

The app can be used for the following purposes:

1. Scanning and connecting to AirLink devices automatically
2. Registering AirLink devices to the server securely
3. Updating Pay-as-you-go status of the device securely
4. Posting data from the device to the server with authentication
5. Finding AirLink devices even when the app is not running, and posting their locations to the server

## Architecture

![Mobile App Framework built on Xamarin](AirLink%20App/App_Architecture.png)

Mobile App Framework built on Xamarin

## Platform : Xamarin

### App Development Framework

**Xamarin multi-platform mobile app development framework**

This is Microsoft's multi-platform mobile app development framework. 

Access of Bluetooth hardware requires platform specific code in Xamarin, and the AirLink App is implemented only for Android  at present but can be extended to iOS with minimal additional code. 

We chose Xamarin as the development environment due to it’s relative maturity compared with Flutter and larger community in case of development challenges, however we believe that an AirLink spec app can also be implemented in Flutter using the Xamarin app as a reference for functionality.

Xamarin Forms adds another layer of UI abstraction, at some cost of speed. We use Xamarin Forms for UI pages and all pages are represented in XAML.

[https://www.youtube.com/watch?v=JH8ekYJrFHs&list=PLdo4fOcmZ0oU10SXt2W58pu2L0v2dOW-1](https://www.youtube.com/watch?v=JH8ekYJrFHs&list=PLdo4fOcmZ0oU10SXt2W58pu2L0v2dOW-1)

**Xamarin uses a MVVM Architecture**

![By Ugaya40 - Own work, CC BY-SA 3.0, [https://commons.wikimedia.org/w/index.php?curid=19056842](https://commons.wikimedia.org/w/index.php?curid=19056842)](AirLink%20App/MVVMPattern.png)

By Ugaya40 - Own work, CC BY-SA 3.0, [https://commons.wikimedia.org/w/index.php?curid=19056842](https://commons.wikimedia.org/w/index.php?curid=19056842)

**Material Design:**

This app uses Material Design for it’s pages:

[Xamarin.Forms 101: Using Material Design in Xamarin Forms](https://channel9.msdn.com/Shows/XamarinShow/XamarinForms-101-Using-Material-Design-in-Xamarin-Forms)

**Secure Storage:**

This app uses secure storage to save all authentication secrets

[Xamarin.Essentials: Secure Storage - Xamarin](https://docs.microsoft.com/en-us/xamarin/essentials/secure-storage?tabs=android)

**Preparing for Release:**

[Preparing an Application for Release - Xamarin](https://docs.microsoft.com/en-us/xamarin/android/deploy-test/release-prep/?tabs=windows#AOT_Compilation)

**Next:** 

Microsoft introduced new development framework [ .NET MAUI ] for increased code sharing across platforms, by leveraging .NET layers. This Xamarin-forms app could be converted to .NET MAUI in 2022 using the migration scripts that Microsoft has promised to provide.

[https://docs.microsoft.com/en-us/dotnet/maui/what-is-maui](https://docs.microsoft.com/en-us/dotnet/maui/what-is-maui)

### NuGet packages

- Acr.UserDialogs (7.2.0.562)
- ble.net(1.2.1)
- NetStandard.Library (2.0.3)
- Newtonsoft.Json (13.0.1)
- PeterO.Cbor(4.5.0)
- Plugin.BLE (2.1.2)
- Rg.plugins.Popup (2.0.0.12)
- sqlite-net (1.6.292)
- sqlite-net-pcl (1.8.116)
- Xamarin.CommunityToolkit (1.3.2)
- Xamarin.Essentials (1.7.0)
- Xamarin.Forms (5.0.0.2291)
- Xamarin.Forms.PancakeView (2.3.0.763-beta)
- Xamarin.Forms.Visual.Material (5.0.0.2291)
- ZXing.Net.Mobile (3.1.0-beta2)

### Software

Visual Studio 2019, available for Mac/Windows

[https://visualstudio.microsoft.com/vs/](https://visualstudio.microsoft.com/vs/)

[Visual Studio setup and to Git library instructions (Mac)](AirLink%20App/Visual%20Studio%20setup%20and%20to%20Git%20library%20instruction%201c38135f4b6b4e3db7ed0d2b3a30ccae.md)

### Dev hardware

Computer recommendation: 8GB RAM, 128GB SSD, 2.0+ GHz processor

Test AirLink Device: BLE Development Kit or any device with BLE.

Test Airlink Gateway Device: Android mobile phone. 

[Set Up Device for Development - Xamarin](https://docs.microsoft.com/en-us/xamarin/android/get-started/installation/set-up-device-for-development)

![Xamarin Libraries leveraged to build the framework](AirLink%20App/IoT_Communications_and_Components_spec_-_App_Architecture-2.png)

Xamarin Libraries leveraged to build the framework

## Platform : Flutter

### App Development Framework

**Flutter multi-platform mobile app development framework**

This is Google’s multi-platform mobile app development framework. 

[https://www.youtube.com/watch?v=VPvVD8t02U8](https://www.youtube.com/watch?v=VPvVD8t02U8)

**Flutter uses a layered Architecture**

[Flutter architectural overview](https://docs.flutter.dev/resources/architectural-overview)

**UI Design:**

Flutter uses design widgets to make it easy to move between software that supports prototyping (e.g. Figma) and app development. This app uses the in-built Flutter widgets to display the app’s functionalities. However, they can be customized to fit the specific needs of the app, allowing you to create unique and engaging user experiences.

### Flutter packages

To realize the Bluetooth requirements and other core functionality of AirLink, the AirLink app (gateway) uses the following packages:

- line_icons: ^2.0.1
- flutter_blue: ^0.8.0
- cbor: ^5.0.1
- convert: ^3.0.1
- hex: ^0.2.0
- flutter_secure_storage: ^5.0.2
- flutter_dotenv: ^5.0.2
- http: ^0.13.4
- device_info_plus: ^3.2.2
- flutter_barcode_scanner: ^2.0.0
- location: ^4.3.0
- sqflite: ^2.0.2
- provider: ^6.0.3
- app_settings: ^4.1.8
- workmanager: ^0.5.0
- permission_handler: ^10.2.0
- timezone: ^0.9.0

![Flutter Libraries leveraged to build the framework](AirLink%20App/IoT_Arch_Open-Source_App_Architecture.jpeg)

Flutter Libraries leveraged to build the framework

## Gateway Sync

The primary role of the AirLink gateway is to keep AirLink devices and the AirLink server in sync with respect to the state and operation of the device. There are three types of **data sync**:

1. Server updates Device: Pay as you go credits after payment are the primary server update, along with client and configuration data
    
    ![AirLink Gateways or this App maps Server and Device properties](AirLink%20App/IoT_Communications_and_Components_spec_-_App_Architecture-2%201.png)
    
    AirLink Gateways or this App maps Server and Device properties
    
2. Device posts time-series telemetry via primary gateway: Device posts various IoT data described in Nexus Resource Models relating to energy generation, consumption, battery use as well as productive output. In this case, the app actually masquerades as the device and posts data directly into the device's telemetry endpoint. This is enabled for the app via user input of device access token or in a production app, from the server pairing the gateway with devices via sharing of the access token automatically upon sale. Location is added by the gateway.
    
    
3. Neighborhood watch gateway posts device advertisement: If the app finds an AirLink device that is not registered as managed by that app, it will post it to the server as a 'piggy-back' onto it's own telemetry, which the server then snips out and decides to post to the original device or forward on to the lost devices database
    
    
    ![**AirLink Lost/Stolen Devices Flow**](AirLink_Unknown_Device_Flow.png)
    
    **AirLink Lost/Stolen Devices Flow**
    

To convert between server-friendly JSON and Bluetooth-service friendly CBOR/.NET objects, the [Json.NET](http://Json.NET) and [PeterO.CBOR](https://github.com/peteroupc/CBOR) libraries are used. Since the list of properties can vary, we use collections and read the property types = device resource models such as “/batt” and “/temp” from the Bluetooth Descriptors.

[Serializing Collections](https://www.newtonsoft.com/json/help/html/SerializingCollections.htm)

## App UX Interactions

![User - App - Device/Server Interactions](AirLink%20App/IoT_Communications_and_Components_spec_-_App_Architecture.png)

User - App - Device/Server Interactions

## App Components

[GitHub - EnAccess/Airlink-App](https://github.com/EnAccess/Airlink-App)

| Component | Category | Function |
| --- | --- | --- |
| BleDevice.cs | Platform Independent,AirLink Device Model | Describes typical AirLink Device and properties |
| AirLinkDevice.cs | Platform Independent | Describes server-side interpretation of AirLink resource models |
| BleServer.cs | Android | The gateway device always acts as a server, and does not advertise an AirLink Advertisement packet. This server  |
| MainActivity.cs | Android,App Business Logic | Start background services |
| BackgroundService.cs | Service,Android | BLE Advt monitoring registered, even if app exits or phone reboots |
| HttpsEndpoint.cs | Platform Independent | Selects appropriate AirLink server endpoint based on type of transmission |
| IDataStore.cs | Platform Independent | Implements the database to store devices found |
| PostData.cs | Platform Independent | Sends Data to AirLink server and processes errors |
| ProfilePageViewModel.cs | UI Business Logic,Platform Independent | Handles all the entries that configure the App to connect to the AirLink server |
| BLEDeviceDetailsViewModel.cs | UI Business Logic,Platform Independent | Handles a single selected BLE device, sync properties, provision etc |
| BLEDevicesViewModel.cs | UI Business Logic,Platform Independent | Handles BLE devices scan page |

## App Screenshots

### Configuring to connect to server

First Step: Enter the information from AirLink Server and Provision the phone as a gateway on the server.

![3. Profile view.jpg](AirLink%20App/3._Profile_view.jpg)

If you enter the data correctly including the tenant administrator, the gateway will provision.

![3.1 PROVISION GATEWAY - Gateway provisioned successfully.jpg](AirLink%20App/3.1_PROVISION_GATEWAY_-_Gateway_provisioned_successfully.jpg)

### Connecting to AirLink devices

Second Step: Your phone is ready to sync devices. Discover AirLink devices in the vicinity!  

![1. Devices view.jpg](AirLink%20App/1._Devices_view.jpg)

Once you find a device, tapping on it simply brings up a list of Nexus resources available on the device

![2. Resources view.jpg](AirLink%20App/2._Resources_view.jpg)

### Authorizing the gateway to the device with the Access Token

Always, when connecting to a device, we recommend that the device lock it’s properties until the  (default or server) access token is supplied. Authorizing the device supplies it with the default access token.

![2.1 READ RESOURCE - Data is empty.jpg](AirLink%20App/2.1_READ_RESOURCE_-_Data_is_empty.jpg)

To authorize the device, simply tap the “Authorize” button. The default access token is already saved on both the App and the device. The device will then compare its access token with this default one. Once they match, the device will be successfully authorized. 

![2.2 AUTHORIZE - Device authorized.jpg](AirLink%20App/2.2_AUTHORIZE_-_Device_authorized.jpg)

Once authorized, you can now read data from the device. The App receives CBOR encoded data from the device, and decodes it into a JSON that is more amenable to posting to the server, and displays this for each property when tapped.

![2.3 READ RESOURCE - Data is displayed.jpg](AirLink%20App/2.3_READ_RESOURCE_-_Data_is_displayed.jpg)

### Serializing and provisioning a new device and preparing it for accepting tokens

If a device has just been manufactured, it may not yet be serialized, and be locked with a default access token. Enter this token, then press “Provision” to provision the device. The app will prompt for serial number entry.

![2.4 PROVISION - Choice for serialization.jpg](AirLink%20App/2.4_PROVISION_-_Choice_for_serialization.jpg)

Scan or enter by hand this serial number. This is a one-time activity after which the device will forever remember it’s serial number. However if the serial number exists on the server, the provisioning will fail.

![2.5 TYPE SERIAL NUMBER.jpg](AirLink%20App/2.5_TYPE_SERIAL_NUMBER.jpg)

As long as a unique serial number is supplied, the server accepts the device and returns a device-specific access token, which the app saves automatically to secure storage as well as displays in the access token field

![2.6 Device provisioned successfully.jpg](AirLink%20App/2.6_Device_provisioned_successfully.jpg)

### Entering Tokens

Some properties are writeable, especially true for the PAYG token property, found in the “PC” resource. Tapping this will open a prompt to enter a token. During the Provisioning stage, the token generator on the server is initialized and matched to each device’s secret. Hence, the token can be obtained from the server automatically by syncing the phone, or by manually copying the PC_tkn property value and inputting by hand while the phone is offline.

![2.7 ENTER PAYG TOKEN.jpg](AirLink%20App/2.7_ENTER_PAYG_TOKEN.jpg)

PAYG tokens are single-use and must match the individual device. If these criteria are met, the device accepts the token.

![2.8 SUCCESS - Success on Token entry.jpg](AirLink%20App/2.8_SUCCESS_-_Success_on_Token_entry.jpg)

### Synchronizing data with the server over the lifetime of the device

All AirLink properties can be kept in sync between the server and the individual device simply by tapping the Sync button, or using the underlying function in an automated flow in your custom version of the app

![2.9 SYNC - Syncing data.jpg](AirLink%20App/2.9_SYNC_-_Syncing_data.jpg)

The ability of the gateway to post device data to the server (”Client Scope”) as well as pull server data into the device (”Shared Scope”) generates a success message. All failure messages can be effectively debugged using the USB-connected debug mode of Visual Studio.

![2.10 SUCCESS - Success on syncing data.jpg](AirLink%20App/2.10_SUCCESS_-_Success_on_syncing_data.jpg)

---

![syo9FlQN.jpg](AirLink%20App/syo9FlQN.jpg)

Copyright 2021 Simusolar Inc 

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.