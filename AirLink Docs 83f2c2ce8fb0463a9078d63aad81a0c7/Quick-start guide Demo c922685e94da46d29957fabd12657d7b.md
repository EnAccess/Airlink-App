# Quick-start guide Demo

Trying out AirLink is easy all you need are two Android phones (tested up to Android 11) and access to the Demo Server hosted by EnAccess.

To get started.

1. Download Android [device](https://github.com/EnAccess/Airlink-Devices/releases/) app APK file and install on one smart phone (find out more about installing APKs on Android [here](https://www.lifewire.com/install-apk-on-android-4177185).) 
2. Download Android actual [AirLink smartphone gateway](https://github.com/EnAccess/Airlink-App/releases/) app APK file and install on a 2nd Android smart phone 
3. [R](https://enaccess.org/airlink/)equest from EnAccess a login to the EnAccess Airlink Demo server by sending an e-mail to [EnAccess](mailto:help@enaccess.org)

and now you have the three components needed - Device, App and Server - to try AirLink quickly without buying any hardware!

### How to get started with your AirLink Server tenant

Here is a step by step setup to demo the Airlink server with two smart phones, one acting as a device and the other acting as a gateway. You will complete the following steps:

1. Login to the EnAccess Airlink Demo server
2. Connect the AirLink App to the server
3. Provision a device using the App, and finally generate a Pay as you go token for the airlink device

Step 1:

1. Login to the EnAccess Airlink Demo Server using the login provided by [EnAccess](mailto:help@enaccess.org)
2. Click on Device profiles
    
    ![Untitled](Quick-start%20guide%20Demo%20c922685e94da46d29957fabd12657d7b/Untitled.png)
    
3. Click on Gateways 
    
    ![Untitled](Quick-start%20guide%20Demo%20c922685e94da46d29957fabd12657d7b/Untitled%201.png)
    
4. Click on “Copy device profile ID” open a notepad application & paste the text for use for provisioning the gateway on the app. 

![Untitled](Quick-start%20guide%20Demo%20c922685e94da46d29957fabd12657d7b/Untitled%202.png)

1. Click on Devices

![Untitled](Quick-start%20guide%20Demo%20c922685e94da46d29957fabd12657d7b/Untitled%203.png)

1. Click on Copy device profile Id and paste to a notepad for use in app

![Untitled](Quick-start%20guide%20Demo%20c922685e94da46d29957fabd12657d7b/Untitled%204.png)

1. Open the Airlink gateway app and click on profile
Input in app. 
Airlink Server Url: https://airlink.enaccess.org
Email: your e-mail for logging into airlink.enaccess.org
Password: your password for logging into airlink.enaccess.org
Device profile ID: device profile Id copied from step 6
Gateway profile ID: gateway pfoile Id copied from step 5 
    
    ![Untitled](Quick-start%20guide%20Demo%20c922685e94da46d29957fabd12657d7b/Untitled%205.png)
    
2. Click Save
3. Click Provision Gateway, you will see gateway provision successful, if it succeeds

    
    ![Untitled](Quick-start%20guide%20Demo%20c922685e94da46d29957fabd12657d7b/Untitled.jpeg)
    
4. Click Ok
5. On other android phone, open the AirLink BLE Simulator. Ensure the device Status is set to Advertising.

    
    ![Untitled](Quick-start%20guide%20Demo%20c922685e94da46d29957fabd12657d7b/Untitled%201.jpeg)
    
6. On the Airway gateway app, click on Devices.

    
    ![Untitled](Quick-start%20guide%20Demo%20c922685e94da46d29957fabd12657d7b/Untitled%206.png)
    
7. Click on the device labeled Airlink
8. Click on Provision on the Airway gateway app

    
    ![Untitled](Quick-start%20guide%20Demo%20c922685e94da46d29957fabd12657d7b/Untitled%207.png)
    
9. A box will pop up that says “Device not serialized. Select your choice for serialization” click on “Type serial number”

![Untitled](Quick-start%20guide%20Demo%20c922685e94da46d29957fabd12657d7b/Untitled%208.png)

1. Enter a 5 digit serial number. For this example, I will use 543231. Please note the serial number can only be 5 digits to work correctly on demo app.

![Untitled](Quick-start%20guide%20Demo%20c922685e94da46d29957fabd12657d7b/Untitled%209.png)

1. After clicking provision, click authorize. 

![Untitled](Quick-start%20guide%20Demo%20c922685e94da46d29957fabd12657d7b/Untitled%2010.png)

1. The AirLink BLE Simulator app Serial Number should change to the specified serial number. If it doesn’t, you might need to restart. You will also need to close out of the Airlink app by hitting the back button and refreshing to see the device with the new serial number. If it doesn’t show up with the new serial number, restart your phone. 
2. Once both phones are showing the same serial number, you should also be able to click on All under “Devices groups” and you will see device listed. 

![Untitled](Quick-start%20guide%20Demo%20c922685e94da46d29957fabd12657d7b/Untitled%2011.png)