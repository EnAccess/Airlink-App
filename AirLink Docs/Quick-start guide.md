# Quick-start guide

Trying out AirLink is easy: 

1. Download two Android app APK files and install on two smartphones
    1. one acting [as device](https://github.com/EnAccess/Airlink-Devices/releases/) - on a phone with Android 9 or lower - and 
    2. one acting as the actual [AirLink smartphone gateway](https://github.com/EnAccess/Airlink-App/releases/) - tested upto Android 11 
2. [Request the Demo tenant server login](https://enaccess.org/airlink/) from EnAccess, 

and you have the three components needed -Device, App and Server- to try AirLink quickly without buying any hardware! Check out this video for more - [AirLink demo video](https://youtu.be/OAEcQaUBIao)

### Who Is AirLink for?

AirLink is a ready-made protocol and software backend for businesses who want to enable **Pay as you go control and data on their products using a smartphones as a gateway**; either because the end product e.g. a home light does not have a remote control or GSM based pay as you go built in, or because adding a smartphone to your product offering adds significant value to your customers.

AirLink is also for businesses who want their products secured against loss or theft using crowd-sourced ‘pings’ via everyone else who uses AirLink devices.

### Components

1. **Server:** EnAccess.org runs a multi-tenant AirLink [server](AirLink%20Server.md) for early adopters and people who want to try out airlink - you can subscribe to as a tenant
    1. Get a tenant login from EnAccess via an [email](mailto:help@enaccess.org) request or use the Demo tenant to try out AirLink (contact [EnAccess](mailto:help@enaccess.org) for login)
    2. Optional: Get your own [thingsboard.io](http://thingsboard.io) server configured to support AirLink using the JSON files available on AirLink Server Github page, then you don’t need the EnAccess server.
2. **PAYG Devices:** Get AirLink Devices
    1. Use a smartphone with the ‘AirLink Device Emulator’ app from the AirLink Devices repository to get started and test airlink without requiring any hardware!
    2. Find Suppliers or make your own Bluetooth hardware that is compatible with the [AirLink Devices](AirLink%20Devices.md) spec. Use the example firmware available for Nordic BLE products on the AirLink Devices Github library
    3. If you want to re-brand the devices that you sell, register with Bluetooth SIG, create a declaration for your product, and use ID text they provide as the 'advertisement' manufacturer text in the Bluetooth advertisement
3. **Smartphone:** Get an Android phone and install the [Airlink App](AirLink%20App.md)!
    1. Follow the steps in the next section to setup your AirLink Server tenant
    2. Scan the device via the app and see if it registers on the server
4. **API:** Use a third party business application to automate device on/off e.g. [Solaris](https://www.solarisoffgrid.com) via API calls to the AirLink server
    1. Develop your business integrations further by building on the open source app for clients or API integrations with the IoT server
    2. Don't forget to integrate with the EnAccess server for the inter-company, crowdsourced 'Neighborhood Watch' (lost assets database)

<a name="tenant-config">

### How to get started with your own AirLink deployment
</a>

Once you decide to try your own AirLink deployment and obtain a login from EnAccess on the managed demo server which can handle startup-scale IoT traffic (the fastest way to get your own AirLink deployment going), or setup your own [Thingsboard.io](http://Thingsboard.io) server, here is a step by step setup for your tenant login in the AirLink server. 

In short, you will first setup the server, then connect the AirLink App to the server, provision a device using the App, and finally generate a Pay as you go token for the airlink device. Here are the steps in detail:

1. Assumption: You have a **“Tenant Administrator”** email login provided by EnAccess, or one that you made for your own server. Login with this administrator account.
Steps 2-5 are also covered in this video: 

    [Tenant setup: Users, Profiles and Rule Chains](https://youtu.be/Sw0xrE0ZpbI)

2. Go to Users → Tenant Users, click on the + sign at the the top right of the page to create a new **Tenant User**. If activating by displaying activation link, note down the email and password. Note that the AirLink app uses this login information for administrative actions like registering devices via *Oauth*, whereas device data exchange is done using *access tokens*.
![AddingUsers.gif](AirLink%20Server/AddingUsers.gif)
3. Setup Device Profiles
    
    ![Screen Shot 2022-01-26 at 9.20.24 PM.png](AirLink%20Server/Screen_Shot_2022-01-26_at_9.20.24_PM.png)
    
    1. Setup a **“Gateways”** profile and enable the “Allow provisioning...” option. To do this, you need to tap the pencil button and then remember to save by pressing the tick-mark button.
        
        ![Screen Shot 2022-01-26 at 9.20.13 PM.png](AirLink%20Server/Screen_Shot_2022-01-26_at_9.20.13_PM.png)
        
    2. Setup a **“Devices”** Profile, and enable the “Default” checkbox as in the figure above. Also enable the “Allow provisioning...” option as in the previous step
    3. Copy the Provisioning Keys and Secrets, you will need to input these in the AirLink app!
4. Import the **rule chains**: All data that flows to the thingsboard server goes to the root rule chain, and any other rule chain that the root chain hands off to. To process AirLink data, we created two rule chains saved as .json files in the [AirLink Server repository](https://github.com/EnAccess/AirLink-Server). This is where to find the Rule chains, just below the Home icon.
   ![Screen Shot 2022-01-26 at 9.27.48 PM.png](AirLink%20Server/Screen_Shot_2022-01-26_at_9.27.48_PM.png)
        
    1. Make sure to import the lowest level rule chains first by following this order in Rule Chain → + → Import Rule Chain:
       1. **“Interact with other PAYG Software Providers”** - click save
       
       ![FirstRuleChain1.png](AirLink%20Server/FirstRuleChain1.png)
       
       ![FirstRuleChain2.png](AirLink%20Server/FirstRuleChain2.png)
       2. **“Root Advertisements and Telemetry”** - edit the link to the Interact with other PAYG Software Providers rule chain, then click save
       
       ![SecondRuleChain1.png](AirLink%20Server/SecondRuleChain1.png)
       
       ![SecondRuleChain2.png](AirLink%20Server/SecondRuleChain2.png)
       
       ![SecondRuleChain3.png](AirLink%20Server/SecondRuleChain3.png)
       
       ![SecondRuleChain4.png](AirLink%20Server/SecondRuleChain4.png)
       
       ![SecondRuleChain5.png](AirLink%20Server/SecondRuleChain5.png)

    2. Mark the **“Root Advertisements and Telemetry”** rule chain as “Root” using the Flag icon next to it
        
        ![Root rule chain.png](AirLink%20Server/Root%20rule%20chain.png)
        
5. That’s it for the minimum required configuration on the Server! Next, **configure your AirLink App** to talk to your server per the following video, and you are set to provision and test real devices!
    
    [AirLink App and End to End flow](https://youtu.be/OAEcQaUBIao)
    
6. After registering a device using the above flow, you can **generate a Nexus Keycode PAYG token** for it by using the **Postman collection in the AirLink-Server repository.** 
    1. Download both the **API calls** collection and the **environment**, and upload to your Postman (getpostman.com) 
    2. First use the login flow with the **Tenant User username/password** of the demo user to authenticate and get a JWT token, then 
    3. enter the **JWT token** into the Airlink environment current value
    4. Use the Generate Token flow with the correct device ID to generate a Nexus Keycode **PAYG token** for your device. This token will be automatically saved in the device properties as well
    5. Connect the AirLink App and type the token in manually into the PC resource, or via keypad as shown in the video above

7. If you are connecting to one of the supported built-in integrations - Solaris Or Angaza, follow this guide to connect AirLink devices to those software stacks: [Connecting to other PAYGO software providers](Connecting%20to%20Solaris%20or%20Angaza.md)