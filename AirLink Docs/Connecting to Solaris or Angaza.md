# AirLink PAYGO Options: Built-in, [Solaris](https://www.solarisoffgrid.com) or [Angaza](https://www.angaza.com)

AirLink acts as an IoT hub, allowing connections to Solaris / Angaza out of the box. Whether AirLink devices connect via Bluetooth or GSM to the AirLink server, the server can be told the device type as Solaris and Angaza, in which case it looks for PAYGo Tokens on the respective servers using login credentials provided to it. A manufacturer or distributor may in this way add AirLink devices to existing Angaza or Solaris software stacks, enabling a new customer experience where tokens are automatically entered via:
- a paired smartphone or a device acting as the AirLink GSM/Bluetooth gateway OR
- a bluetooth remote control paired with the target device

The AirLink app can transfer any type of PAYGO token between the server and device. Consequently, the IoT hub can hold a mix of devices configured to different providers, of which the following are supported as of this writing.

## Out-of-the-box PAYGO Token functionality
AirLink natively generates [Nexus Tokens](https://github.com/angaza/nexus-embedded) which the AirLink open-source firmware natively consumes. This means that an AirLink adopter can connect their own software stack to AirLink to enable a PAYGO business case by asking the AirLink server to take care of PAYGO functionality. The API requests to generate these tokens are available in the [Postman Collection](https://github.com/EnAccess/AirLink-Server/blob/main/AirLink%20-%20Thingsboard.postman_collection.json) and the related [Postman Environment](https://github.com/EnAccess/AirLink-Server/blob/main/AirLink%20Demo%20Environment.postman_environment.json), and are the default setup for new AirLink Devices provisioned via the AirLink App. Make sure to add devices with the payg_type property set to "Airlink", as in the following CSV file format useful for bulk devices upload: [TestAirLinkDevices.csv](Connecting%20to%20Solaris%20or%20Angaza/TestAirLinkDevices.csv)

Most PAYGO distributors however don't have their own software stacks. For this purpose, AirLink also provides connectivity to a couple established stacks who share API, Solaris PAYGOPS and Angaza.

## Solaris [OpenPAYGO Tokens](https://github.com/EnAccess/OpenPAYGO-Token) and Telemetry
For Solaris, telemetry update from device to Solaris server - any property sent from the device will be forwarded, and token updates from Solaris Server to device are supported

1. Provisioning Solaris Devices: To add Solaris devices, you will need to provision them both in the Solaris PAYGOPS platform as well as in AirLink separately. To provision devices in AirLink to connect to Solaris servers for PAYGO Tokens, use the format while uploading new devices in the following CSV File:
[TestSolarisDevices.csv](Connecting%20to%20Solaris%20or%20Angaza/TestSoalrisDevices.csv)

2. PAYGO Tokens:

3. Telemetry Data: 

*Note: Only one Solaris credential is supported out of the box, which means that the functionality is most suited to distributors rather than manufacturers. Further development of the AirLink server is possible to support multiple Solaris credentials based on device group.*

## Angaza [Nexus Channel](https://github.com/EnAccess/OpenPAYGO-Token) and automatic device provisioning
For Angaza, creating devices in AirLink with payg_type = “Angaza” will automatically create those devices in Angaza’s server. From then on, the token and credit expiry date from the Angaza server will be downloaded each time the device properties are updated. When the device reports it’s PAYG state, the payg_until_dt property will be updated to Angaza
    
1. Provisioning: Please use a format like the following CSV file to add Angaza devices, so that they get properly created in the Angaza server. Don't worry if something goes wrong, you can always delete devices and start again! [TestAngazaDevices.csv](Connecting%20to%20Solaris%20or%20Angaza/TestAngazaDevices.csv)

2. PAYGO Tokens:

3. Telemetry forwarding to Angaza is not supported out of the box i.e. Device properties such as location sent from the device will be saved to the AirLink server, but will not be automatically forwarded to Angaza. This is because Angaza requires first a registration of a ‘data format’ to save device data, which needs to be done per manufacturer spec. There is a stub of the rule chain required for this interchange setup in the Angaza rule-chain, and can be edited per each manufacturer’s preference!


*Note that only one Angaza credential is supported out of the box, which means that the functionality is best suited to a manufacturer. Further development of the airlink server is possible to support different device groups with different Angaza credentials if needed.*