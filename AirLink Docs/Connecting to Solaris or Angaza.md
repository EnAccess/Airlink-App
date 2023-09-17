# Connecting to Solaris or Angaza

AirLink acts as an IoT hub, allowing connections to Solaris / Angaza out of the box. 

1. For Solaris, telemetry update from device to Solaris server - any property sent from the device will be forwarded, and token updates from Solaris Server to device are supported
2. For Angaza, creating devices in AirLink with payg_type = “Angaza” will automatically create those devices in Angaza’s server. From then on, the token and credit expiry date from the Angaza server will be downloaded each time the device properties are updated. When the device reports it’s PAYG state, the payg_until_dt property will be updated to Angaza
    1. Telemetry forwarding to Angaza is not supported out of the box i.e. Device properties such as location sent from the device will be saved to the AirLink server, but will not be automatically forwarded to Angaza. This is because Angaza requires first a registration of a ‘data format’ to save device data, which needs to be done per manufacturer spec. There is a stub of the rule chain required for this interchange setup in the Angaza rule-chain, and can be edited per each manufacturer’s preference!


August 29, 2023 12:00 PM 

[TestAngazaDevices.csv](Connecting%20to%20Solaris%20or%20Angaza/TestAngazaDevices.csv)