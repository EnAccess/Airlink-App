# AirLink Devices

![bluetooth-logo-color-black.svg](AirLink%20Devices/bluetooth-logo-color-black.svg)

**Preface: A note on Bluetooth® SIG requirements, Nov 2021**

Our understanding is that the Bluetooth®  Special Interest Group requires that any entity branding and selling devices enabled with Bluetooth®  must register as a member with the SIG at [bluetooth.com](https://www.bluetooth.com), as well as declare the product and the Bluetooth®  component being used. This is true for resellers, distributors, and all commercial sales. The final selling brand and product name must be separately declared by the seller, even if the component containing Bluetooth®  has been declared by the manufacturer.

Although membership has a free tier, each declaration as of this writing costs $8,000, set to rise to $9,600 in 2022. Multiple products using the same Bluetooth®  component (one with an approved QDID) can be added to a new or existing declaration, however if the underlying Bluetooth®  component is changed even within the same product, a new declaration must be filed with the full fee. Repercussions of not filing declarations may include shipments of the product being held by customs agents, from a global reference list maintained at bluetooth.com.

This requirement as we understand only applies for sold products, not prototypes.

*Please note that this note is not official Bluetooth®  SIG communication, but rather it is our understanding of the requirements set by the Bluetooth®  SIG as of this writing.*

---

## Development Reference

### Device Emulator App

To enable quick end to end testing of AirLink, we have designed a single-page Android-native app that imitates an AirLink device with temperature, battery and device configuration resources. The source code of this app as well as an Android-9 executable APK is saved in the [AirLink Devices Github repository](https://github.com/EnAccess/AirLink-Devices) under the Device Simulator folder. 

![Device Simulator app running on an Android-9 phone](AirLink%20Devices/Screenshot_20230208-141454_AirLink_BLE_Simulator.jpg)

Device Simulator app running on an Android-9 phone

This app allows you to:

1. Pair with the main AirLink (gateway) app on another phone
2. Go through the provisioning flow and initialize the token generation flow
3. Send data to the server via the AirLink gateway app
4. Accept tokens from the server - although there is no nexus token decoder running in the app, so it will accept any token

The source code is meant as a reference when designing embedded firmware that can match AirLink’s provisioning and data exchange flows. With the emulator app, anyone can test AirLink without requiring hardware, simply by downloading it onto an Android phone, installing the AirLink gateway app on another phone, and logging on to the demo/custom tenant on the AirLink server.

The [source code](https://github.com/EnAccess/AirLink-Devices) is not meant to actually process tokens, but could act as a starting point if Android Airlink devices are being developed.

### Nordic Device Firmware

Nordic makes the most popular set of Bluetooth chips, and we have developed example firmware to support provisioning, data as well as full Nexus token capability. This firmware is meant to act as a reference for developing custom bluetooth hardware that supports AirLink and also to act as a testbed while developing a custom AirLink gateway app.

Nordic firmware reference source code is available on the AirLink Devices github repository.

![A Nordic DVK-BLE kit running AirLink demo firmware](AirLink%20Devices/dvkble_kit.jpeg)

A Nordic DVK-BLE kit running AirLink demo firmware

![Programming the Nordic kit with AirLink demo firmware](AirLink%20Devices/programmer.jpeg)

Programming the Nordic kit with AirLink demo firmware

### BLE Range Testing

[Range Testing Results](AirLink%20Devices/Range%20Testing%20Results%20ef4c4ece8fba4542830d415dc0fa1a42.md)

The Simusolar team tested how far we could find an AirLink device from in presence of walls and with clear line of sight. 

### From the OCF specification

[](https://openconnectivity.org/specs/OCF_Resource_to_BLE_Mapping_Specification_v2.2.2.pdf)

AirLink Devices adopt the [Open Connectivity Foundation's Resource Model bridging guidelines](https://openconnectivity.org/specs/OCF_Resource_to_BLE_Mapping_Specification_v2.2.3.pdf) for Bluetooth LE devices. A key feature of this bridge is that several OCF Resources are wrapped into one Bluetooth Service to make GET/POST requests efficient. We leverage CBOR for this encapsulation.

![AirLink%20Devices/Screen_Shot_2021-07-13_at_11.34.29_AM.png](AirLink%20Devices/Screen_Shot_2021-07-13_at_11.34.29_AM.png)

![Screen Shot 2021-08-13 at 12.35.43 PM.png](AirLink%20Devices/Screen_Shot_2021-08-13_at_12.35.43_PM.png)

![AirLink%20Devices/Screen_Shot_2021-07-13_at_11.34.40_AM.png](AirLink%20Devices/Screen_Shot_2021-07-13_at_11.34.40_AM.png)

![AirLink%20Devices/Screen_Shot_2021-07-13_at_11.34.54_AM.png](AirLink%20Devices/Screen_Shot_2021-07-13_at_11.34.54_AM.png)

---

## AirLink Protocol Design

### Resource model design

The OCF bridging recommendation covers GATT properties well, however it does not cover Advertising nor does it cover a resource enumerator explicitly. 

We used the following additional assumptions to design our resource models:

1. Bluetooth gateways from any vendor adopting AirLink should be able to detect other AirLink devices, to ensure interoperability as well as crowd-sourced stolen asset detection. Hence the advertising packet needs to be open format with sufficient information to identify the device and it's basic state
2. Extended advertising should not be required to transmit the required data, limiting the overall size to 26 bytes
3. The advertisement data packet as well as other GATT service characteristics must be CBOR encoded lists of Resource Model properties. This is designed for compatibility with the [Nexus Channel](https://angaza.github.io/nexus-channel-models/resource_type_spec.html) effort. The GATT characteristics should be in 2-D array format, whereas the Advertisement packet will be a single dimensional byte array with positionally separated properties to conserve data packet length. The gateway device then converts this into a 2-D CBOR array and includes location information before transmitting to the server.
4. Location is to be appended by the gateway device before transmission to the server, as non-gateway devices are unlikely to have GSM/GPS to locate themselves. However, devices can store locations provided to them by gateway devices to enable a location history within the device if required
5. Pay-as-you-go credits are sent as [Nexus Keycode Tokens](https://nexus.angaza.com/keycode.html), with planned future support for [OpenPAYGO Tokens](https://github.com/EnAccess/OpenPAYGO-Token) - this is to ensure interoperability with existing keypad/remote enabled devices as well as independence from time-stamp synchronization between server/gateway/end device.
6. We cover the following general use cases here:
    1. Required: Asset locatability by any gateway via advertisement
    2. Required: Resource enumerator service
    3. Required: Pay-as-you-go credits - we postulate that this does not require manufacturer specific authorization because OpenPAYG Tokens are already securely encrypted between a server and device
    4. Self-provisioning as supported by [Thingsboard.io](http://thingsboard.io) servers
    5. Optional: Power use and Productive Output data logging
    

### Device Discovery Services

1. The advertisement packet is a compressed resource always readable from the device. We designate it as an 'Implicit GET'. 
A gateway device reads this resource while scanning for devices (before a connection is established), and decompresses it to create a standard-format resource model compatible with AirLink Server. It adds items such as resource type, interface type etc as required by OCF but also timezone, location lat-lon where the device was discovered and the manufacturer ID which is in the bluetooth advertisement header
2. The /res enumerator resource in AirLink is not included explicitly but each bluetooth property has the corresponding resource endpoint in its ‘Descriptor’ field, removing the need for an explicit descriptor resource while still allowing gateways to discover resources available in a device
3. To discover how a device gets added to the AirLink server, check the AirLink Server page!

### AirLink Advertisement /advt

| Resource Property | Octets | Qualifiers | Nx Resource | Description |
| --- | --- | --- | --- | --- |
|  |  |  |  |  |
| “mac” | 6 | Default | AirLink Advt Resource 1.0 | Bluetooth MAC ID Automatically available in BLE Advertisement. Sent to AirLink server as advt_mac converted to all-caps text e.g. BD:DD:EE:FF:AA:BB |
| Array Cbor header | 1 | CBOR Header |  | Array declaration header of 8 elements |
| BLE Advt resource version "rv" | 3 | Float (uint16_t),Read-Only | AirLink Advt Resource 1.0 | 10 (major/minor digits), 2 Bytes = 2^(8*2) = 65536 i.e from 0-65535 (0xFFFF) The format of the data version according to the protocol used. First integer is major number, second minor |
| Device Fault Status "ft", cbor encoded | 1 | Read-Only,Integer (uint8_t),Scope: Time-series | AirLink Advt Resource 1.0 | From 0-23. Any Universal error that should be executed with priority. 
Error 0 = Unprovisioned, 
Error 1 = Lost track of PAYG credit (battery off), 
Error 2 = Battery Fault
Error 3 = Output Overcurrent/Overtemp - details in ftd field in timeseries data
Error 23 = Lost device (e.g. when device doesn't find other Bluetooth devices from it's 'pack'. 
Errors 4-22 are manufacturer specific |
| Device Airlink ID "aid" + Cbor header 4 bytes | 5 | Read-Only,Optional | AirLink Advt Resource 1.0 | 2^(8*4) = 4,294,967,296 numeric device ids. The ID of the device that resides in manufacturer registry. AirLink uses the BLE mac ID to uniquely identify an unknown device so this is only a human readable option |
| Timestamp last pulled from gateway or network  "gts" | 5 | Read-Only,Byte Array | AirLink Advt Resource 1.0 | Linux epoch format, expires in Y2035 |
| Device provisioning status "pst" | 1 | Integer (uint8_t),Read-Only,Scope: Time-series | AirLink Advt Resource 1.0 | 2^8 = 256 i.e from 0-255 (0xFF) The status of the device according to manufacturer definition. It can be 
1-unserialized,
2-unprovisioned,
3-disabled, 
4-recall, 
5-stolen, 
6-9-Manufacturer custom 
The range is from 1-9. If not supported then 0 |
| Device FW Ver "fv" | 2 | Read-Only,Integer (uint8_t) | AirLink Advt Resource 1.0 | 2^8 = 256 i.e from 0-255 (0xFF). Shows the version of the hardware firmware. It ranges from 01-99. If not supported then 0 |
| Device PayG Credit Remaining "cr" | 5 | Read-Only,Scope: Time-series | AirLink Advt Resource 1.0 | 2^(8*2) = 65536 i.e from 0-65535 (0xFFFF). The value  remaining for the device to OFF. Range is from 01-9999
If non payg device then 0 |
| Expected RSSI at 1 meter “s1” | 2 | Read-Only,Scope: Client,Integer (uint8_t) | AirLink Advt Resource 1.0 | Expected signal strength of this Bluetooth device for a receiver (phone / other Bluetooth device) placed at 1 meter, used for distance estimation. 
Value is in negative dB (e.g. a value of s1=70 is considered to be -70dB)
Calibrated during device prototyping, and adjusted by each device for any changes in it’s transmit power with respect to the transmit power at calibration time (e.g. +2dB transmit power during advertising ⇒ s1=68, if 0dB transmit power at calibration time had yielded an RSSI of -70dB). |
| Spare | 1 |  | AirLink Advt Resource 1.0 | Can be used for Manufacturer specific information, for example type of asset, data about status etc |
| Dummy “dmy” |  | Optional | AirLink Advt Resource 1.0 | Some Bluetooth chips require fixed-length advts, this dummy can make up for variation in other properties lengths |
| Device Manufacturer ID "mid" added by gateway device |  | Integer (uint16_t),Read-Only,Mandatory,Scope: Time-series | AirLink Advt Resource 1.0 | From Device advertisement - all manufacturers and end brands of BLE products need to be registered with Bluetooth SIG, as well as EnAccess as tenants to use this service |

### Location Resource /loc

| Resource Property | Octets | Qualifiers | Nx Resource | Description |
| --- | --- | --- | --- | --- |
| Array Cbor header | 1 | CBOR Header |  | Array declaration header of 8 elements |
| Timestamp last pulled from gateway or network  "gts" | 5 | Read-Only,Byte Array | Location Resource 1.0 | Linux epoch format, expires in Y2035 |
| Gateway Manufacturer ID "gmid" added by gateway device | 2 | Integer (uint16_t),Read-Only,Mandatory | Location Resource 1.0 | How can we prevent one manufacturer from messing up the other's IDs? |
| Gateway AirLink ID "gid" added by gateway device | 5 | Integer (uint32_t) | Location Resource 1.0 |  |
| Longitude "ln" added by gateway device |  | String | Location Resource 1.0 | Added by gateway device reporting location of non-gateway device, 10 octets |
| Latitude "lt" added by gatway device |  | String | Location Resource 1.0 | Added by gateway device reporting location of non-gateway device, 10 octets |
| Location accuracy "la" added by gateway device |  | String | Location Resource 1.0 | Added by gateway device reporting location of non-gateway device, 6 octets |
| Device Signal strength "dss" added by gateway device |  | String | Location Resource 1.0 | Added by gateway device reporting the exactly location of the device from a gateway expressed in dBm |
| Timeseries Timestamp “ts” | 4 | Read-Only | AirLink PUE Timeseries 1.0 | TImestamp of when the data is recorded |
| Timeseries History Index “thi” | 4 | Read-Only | AirLink PUE Timeseries 1.0 | Whenever this property is available that means it is a timeseries resource.
thi = 0, means there is no more timeseries data.
Any number greater than zero can be used for indicating which data proceeds especially when the timestamp is the same.  |
| Dummy “dmy” |  | Optional | AirLink PUE Timeseries 1.0 | Some Bluetooth chips require fixed-length characteristics, this dummy can make up for variation in other properties lengths |

### Device Config Service

1. We presume and recommend self-provisioning, although this resource can also be written to if the device firmware permits.
2. Gateways can be updated with a list of these configurations for downstream devices
3. The command resource is a passthrough for building a custom encrypted application links e.g. Nexus Channel
4. On connection, the gateway must write the server access token property with the correct value for that device, upon which the rest of the properties are opened by the device for communication. This is expected to be the programmed behavior of AirLink devices

### AirLink Device Provisioning Resource /dcfg

| Resource Property | Octets | Qualifiers | Nx Resource | Description |
| --- | --- | --- | --- | --- |
| cbor header | 1 | Read-Write |  | encapsulating the rest of the properties |
| Device Provisioning resource version "rv" | 3 | Float (uint16_t),Read-Only | AirLink Device Provisioning 1.0 | 10 (major/minor digits) |
| Device ID "did" + Cbor header 20 bytes | 21 | Mandatory,Read-Write | AirLink Device Provisioning 1.0 | UTF-8 coded device serial numbers |
| AirLink ID "aid" + Cbor header 4 bytes | 5 | Mandatory,Read-Write | AirLink Device Provisioning 1.0 | 2^(8*4) = 4,294,967,296 numeric device ids. The ID of the device that maps 1:1 in manufacturer registry to serial number |
| PayG Units accepted "pul" | 10 | Unencrypted,Read-Only,Mandatory,String,Scope: Client | AirLink Device Provisioning 1.0 | CSV list of acceptable Units e.g. "l" for liters, "h,d" for hours and days |
| Payg Token starting code "psc" | 5 | Write-Only,Scope: Shared | AirLink Device Provisioning 1.0 | 1-day token, https://github.com/EnAccess/OpenPAYGO-HW https://github.com/angaza/nexus-embedded |
| PayG Unit "pu" | 1 | Encrypted,Read-Write,Mandatory,String,Scope: Shared,Scope: Client | AirLink Device Provisioning 1.0 | 36^1  The unit of the PayG update, it can be minutes, hours, days, months and years. [s-seconds, m-minutes, h-hours, d- days, M-months, Y-years] |
| Provisioning Status "pst" | 1 | Unencrypted,Integer,Mandatory,Read-Write,Scope: Client | AirLink Device Provisioning 1.0 | Reflected in Advt packet also. It can be unprovisioned, disabled, recall, stolen, Cash, Loan. The range is from 1-9. If not supported then 0 |
| Server access Token "sat" | 21 | Encrypted,String,Mandatory,Write-Only,Scope: Shared | AirLink Device Provisioning 1.0 | http://thinsboard.io has a 20-char device authentication token unique to each device. During device provisioning, this token is written to the device, permanently attaching the device to the server. The token is never transmitted again. |
| Current Unix Time “cut” | 4 | Write-Only | AirLink Device Provisioning 1.0 | This property can be used to sync or correct system time. |
| Productive Output Set Limit "opmax" | 4 | Read-Write,Integer,Scope: Shared,Scope: Client | AirLink Device Provisioning 1.0 | Max brightness, max water flow etc set for safety / environmental reasons / other reasons |
| Dummy “dmy” |  | Optional | AirLink Device Provisioning 1.0 | Some Bluetooth chips require fixed-length characteristics, this dummy can make up for variation in other properties lengths |

### AirLink Client Provisioning Resource /ccfg

| Resource Property | Octets | Qualifiers | Nx Resource | Description |
| --- | --- | --- | --- | --- |
| cbor header | 1 | Read-Write |  | encapsulating the rest of the properties |
| Client Provisioning resource version "rv" | 3 | Float (uint16_t),Read-Only |  | 10 (major/minor digits) |
| Customer Name
"cn" | 16 | Unencrypted,String,Optional,Read-Write,Scope: Shared,Scope: Client | AirLink Client Provisioning 1.0 | Requested by customers for lost device reporting. This writes the customer name to a device with the maximum of 16 characters with space and special characters inclusive. |
| Customer's Phone "cp"
 | 16 | Unencrypted,String,Optional,Read-Write,Scope: Shared,Scope: Client | AirLink Client Provisioning 1.0 | Requested by customers for stolen device reporting (needs a workflow to collect this number explicitly from client in addition to regular lead number). Assign the mobile number of the customer to a device. With maximum of 16 character including + and country code number. This is for security purpose |
| Readable ID "rid" + Cbor header 2 bytes | 6 | Mandatory,Read-Write,Scope: Shared,Scope: Client | AirLink Client Provisioning 1.0 | 2^(8*4) = 4,294,967,296 numeric device ids or payment reference or any number that device should display |
| Provisioning Status "pst" | 1 | Unencrypted,Integer,Mandatory,Read-Write,Scope: Client | AirLink Client Provisioning 1.0 | Reflected in Advt packet also. It can be unprovisioned, disabled, recall, stolen, Cash, Loan. The range is from 1-9. If not supported then 0 |
| Server Auth Token "sat" encryption overhead | 20 | Encrypted,String,Mandatory,Write-Only,Scope: Shared | AirLink Client Provisioning 1.0 | http://thinsboard.io has a 20-char device authentication token unique to each device |

### Nexus Command Resource /nxc

[Nexus Command Resource /nxc](AirLink%20Devices/Nexus%20Command%20Resource%20nxc%20ed4247090ba4475583e05f72cc537ff0.csv)

### PUE Use Service

We envision 2 primary usages of a productive use asset: 

1. PAYG control: This is a generic PAYG packet intended to cover all known PAYG use cases for BLE assets
2. Use data (time-series): This is a generic IoT Data packet designed to cover both battery-less and battery-based devices
3. Gateways can accumulate data for/from several devices

### PAYG Credit Resource /pc

| Resource Property | Octets | Qualifiers | Nx Resource | Description |
| --- | --- | --- | --- | --- |
| cbor map header | 1 | Read-Write |  | encapsulating the rest of the properties |
| AirLink PAYG resource version "rv" | 3 | Float (uint16_t),Read-Only |  | 10 (major/minor digits) |
| Timeseries History remaining “tsh” | 2 | Read-Only,Optional,Scope: Time-series | PAYG Credit 1.0 | Any resource with one or more timeseries properties is enabled with this optional property which can indicate that the device has stored historical data while offline that it can sequentially upload to the gateway via multiple reads |
| Device PayG Credit Remaining "re" | 5 | Mandatory,Integer,Read-Write,Scope: Time-series | PAYG Credit 1.0 | should be The value  remaining for the device to OFF. 

For Write, a Nexus Channel Link must be established otherwise read-only, updated via token |
| PayG Unit "pu" | 1 | Mandatory,String,Read-Only | AirLink Device Provisioning 1.0 | 36^1  The unit of the PayG update, it can be minutes, hours, days, months and years. [s-seconds, m-minutes, h-hours, d- days, M-months, Y-years] |
| PayG SwitchOffTime “sot” | 6 | DateTime,Optional,Scope: Time-series,Read-Write | PAYG Credit 1.0 | Linux epoch format, expires in Y2035. The datetime at which payg credit currently expires |
| Mode "mo" | 1 | Read-Write,Scope: Shared Attr | PAYG Credit 1.0 | mode of device i.e. leading/following etc

For Write, a Nexus Channel Link must be established otherwise read-only, updated via token |
| PayG Token "tkn" | 5 | Write-Only,Encrypted,Integer,Scope: Shared Attr | PAYG Credit 1.0 | https://github.com/EnAccess/OpenPAYGO-HW. Accepted by device only if valid. No read token to ensure unsecured gateways cannot act maliciously.  |
| Last Added PayG Credit "lcr" | 2 | Read-Only,Integer,Optional,Scope: Time-series | PAYG Credit 1.0 | Historical last PayG credit update duration. Range is from 01-9999 |
| Timestamp at which PayG remaining was calculated "pts" | 6 | DateTime,Optional,Read-Only,Scope: Time-series | PAYG Credit 1.0 | Linux epoch format, expires in Y2035. The Last date and time when the PayG update was fetched from the Server to client [Mobile phone or other communication device] |
| Timestamp of last PAYG Update to device "lts" | 6 | Read-Only,DateTime,Optional,Scope: Time-series | PAYG Credit 1.0 | Linux epoch format, expires in Y2035, readonly - Historical last PayG update Timestamp |
| Current Local Time "lt" | 6 | Read-Write,DateTime,Optional,Scope: Time-series | PAYG Credit 1.0 | Linux epoch format, expires in Y2035. The current time when updating the device with PayG update. We do not recommend using this to calculate PAYG use, because it could be used to trick the device into more tokens. This is for non-PAYG purposes |
| Timeseries Timestamp “ts” | 4 | Read-Only | AirLink PUE Timeseries 1.0 | TImestamp of when the data is recorded |
| Timeseries History Index “thi” | 4 | Read-Only | AirLink PUE Timeseries 1.0 | Whenever this property is available that means it is a timeseries resource.
thi = 0, means there is no more timeseries data.
Any number greater than zero can be used for indicating which data proceeds especially when the timestamp is the same.  |
| Dummy “dmy” |  | Optional | AirLink PUE Timeseries 1.0 | Some Bluetooth chips require fixed-length characteristics, this dummy can make up for variation in other properties lengths |

### AirLink Temperature Resource /temp

| Resource Property | Octets | Qualifiers | Nx Resource | Description |
| --- | --- | --- | --- | --- |
| cbor map header | 1 | Read-Write | TEMP 1.0 | encapsulating the rest of the properties |
| TEMP resource version "rv" | 3 | Float (uint16_t),Read-Only | TEMP 1.0 | 10 (major/minor digits) |
| Timeseries History remaining “tsh” | 2 | Read-Only,Optional,Scope: Time-series | PAYG Credit 1.0 | Any resource with one or more timeseries properties is enabled with this optional property which can indicate that the device has stored historical data while offline that it can sequentially upload to the gateway via multiple reads |
| Current Temperature "temp" | 5 | Read-Only,Mandatory,Scope: Time-series | TEMP 1.0 | 0-128C in 1/2 degree increments |
| Max Temperature "tmax" | 5 | Read-Only,Optional,Scope: Time-series | TEMP 1.0 | 0-128C in 1/2 degree increments |
| Max Temperature "tmin" | 5 | Read-Only,Optional,Scope: Time-series | TEMP 1.0 | 0-128C in 1/2 degree increments |
| Temperature upper limit threshold "hlim" | 5 | Read-Write,Optional,Scope: Client Attr | TEMP 1.0 | 0-128C in 1/2 degree increments |
| Temperature lower limit threshold "llim" | 5 | Read-Write,Optional,Scope: Client Attr | TEMP 1.0 | 0-128C in 1/2 degree increments |
| Timeseries Timestamp “ts” | 4 | Read-Only | TEMP 1.0 | TImestamp of when the data is recorded |
| Timeseries History Index “thi” | 4 | Read-Only | TEMP 1.0 | Whenever this property is available that means it is a timeseries resource.
thi = 0, means there is no more timeseries data.
Any number greater than zero can be used for indicating which data proceeds especially when the timestamp is the same.  |
| Dummy “dmy” |  | Optional | TEMP 1.0 | Some Bluetooth chips require fixed-length characteristics, this dummy can make up for variation in other properties lengths |

### AirLink Productive Use Resource /pu

| Resource Property | Octets | Qualifiers | Nx Resource | Description |
| --- | --- | --- | --- | --- |
| cbor header | 1 | Read-Write |  | encapsulating the rest of the properties |
| AirLink TimeSeries resource version "rv" | 4 | Float (uint16_t),Read-Only | AirLink PUE Timeseries 1.0 | 1.0 |
| Timeseries History remaining “tsh” | 2 | Read-Only,Optional,Scope: Time-series | AirLink PUE Timeseries 1.0 | Any resource with one or more timeseries properties is enabled with this optional property which can indicate that the device has stored historical data while offline that it can sequentially upload to the gateway via multiple reads |
| Time Series Data Format "df" | 1 | Mandatory,Read-Only,Integer | AirLink PUE Timeseries 1.0 | following DF in OpenPAYGO Metrics (in case device has GSM). 0 if not used |
| Productive Equipment Type "pue" | 2 | Read-Only,Integer,Mandatory | AirLink PUE Timeseries 1.0 | e.g. "Surface Pump", "Borehole Pump", "Fishing Light" etc preregistered types |
| BatteryDevice "bat" | 1 | Read-Only,Integer,Mandatory | AirLink PUE Timeseries 1.0 | Yes/No Yes = it has an internal or system level battery |
| Device Fault "ft" | 1 | Mandatory,Read-Only,Integer,Enum | AirLink PUE Timeseries 1.0 | Same as Advertisement packet  |
| Device Fault Data "ftd" | 2 | Integer,ByteArray,Optional | AirLink PUE Timeseries 1.0 | Can contain details of error e.g. over-pressure error could contain max pressure measured |
| seconds since data measured "ss" | 6 | Read-Only,Mandatory,DateTime | AirLink PUE Timeseries 1.0 | seconds passed since last /pu data pull by any gateway device - presumption is that gateway transmits the data to server. Useful for devices that store a rolling history of data |
| Productive Output Primary Metric "op" | 4 | Optional Grp 1,Read-Only,Integer | AirLink PUE Timeseries 1.0 | e.g. Water output for pumps in Litres/hour |
| Productive Output Primary Set Limit ”opl” | 4 | Optional Grp 1,Read-Write,Integer | AirLink PUE Timeseries 1.0 | The limit of primary product Output 
Eg. 100L/H for the pump that can go to 500 L/H |
| Productive Output Secondary Metric "os" | 4 | Optional Grp 1,Read-Only,Integer | AirLink PUE Timeseries 1.0 | e.g. Pressure for pumps in kPa (1kPa = 10cm water or 0.1 bar) |
| Productive Output Secondary Set Limit “osl” | 4 | Optional Grp 1,Read-Write,Integer | AirLink PUE Timeseries 1.0 | The limit of secondary product Output 
Eg. Could be a pressure of 5kPa for the pump that can preduce the pressure of 10kPa |
| Timeseries Timestamp “ts” | 4 | Read-Only | AirLink PUE Timeseries 1.0 | TImestamp of when the data is recorded |
| Timeseries History Index “thi” | 4 | Read-Only | AirLink PUE Timeseries 1.0 | Whenever this property is available that means it is a timeseries resource.
thi = 0, means there is no more timeseries data.
Any number greater than zero can be used for indicating which data proceeds especially when the timestamp is the same.  |
| Dummy “dmy” |  | Optional | AirLink PUE Timeseries 1.0 | Some Bluetooth chips require fixed-length characteristics, this dummy can make up for variation in other properties lengths |

### Energy Consumption Resource /eout

| Resource Property | Octets | Qualifiers | Nx Resource | Description |
| --- | --- | --- | --- | --- |
| cbor header | 1 | Read-Write |  | encapsulating the rest of the properties |
| Timeseries History remaining “tsh” | 2 | Read-Only,Optional,Scope: Time-series | energy consumption 1.0 | Any resource with one or more timeseries properties is enabled with this optional property which can indicate that the device has stored historical data while offline that it can sequentially upload to the gateway via multiple reads |
| Voltage (milliVolts) "vo" | 4 | Optional,Read-Only,Integer,Source: Time-series | energy consumption 1.0 | Output voltage depending on data format registered by manufacturer |
| Current (centiAmps) "ao" | 4 | Optional,Read-Only,Integer,Source: Time-series | energy consumption 1.0 | Output current depending on data format registered by manufacturer |
| Current Limit (centiAmps) "aol" | 4 | Optional,Integer,Read-Write | energy consumption 1.0 | Current limit setting |
| Power (deciWatts) "po" | 4 | Optional,Read-Only,Integer,Source: Time-series | energy consumption 1.0 | Output power depending on data format registered by manufacturer |
| eo | 4 | Optional,Read-Only,Integer,Source: Time-series | energy consumption 1.0 | 'Energy consumed' in deciwatt-hours(Wh / 10). Computed over a time window defined by egs and egp |
| eos | 4 | Optional,Read-Only,Integer,Source: Time-series | energy consumption 1.0 | 'Energy consumed start'. Minutes in the past (minutes ago) when the reported eg value began accumulation |
| eop | 4 | Optional,Read-Only,Integer,Source: Time-series | energy consumption 1.0 | 'Energy consumed period'. Minutes since egs over which the value of eg was accumulated. For example, if egs is 60, and egp is 60, the value of eg represents the watt-hours generated during the past hour |
| Timeseries Timestamp “ts” | 4 | Read-Only | energy consumption 1.0 | TImestamp of when the data is recorded |
| Timeseries History Index “thi” | 4 | Read-Only | energy consumption 1.0 | Whenever this property is available that means it is a timeseries resource.
thi = 0, means there is no more timeseries data.
Any number greater than zero can be used for indicating which data proceeds especially when the timestamp is the same.  |
| Dummy “dmy” |  | Optional | energy consumption 1.0 | Some Bluetooth chips require fixed-length Characteristics, this dummy can make up for variation in other properties lengths |

### Energy Generation Resource /ein

| Resource Property | Octets | Qualifiers | Nx Resource | Description |
| --- | --- | --- | --- | --- |
| cbor header | 1 | Read-Write |  | encapsulating the rest of the properties |
| Voltage (milliVolts) "vi" | 4 | Read-Only,Integer,Optional | energy generation 1.0 | Input voltage depending on data format registered by manufacturer. We will start with PV in controllers and Output in FL |
| Current (centiAmps) "ai" | 4 | Read-Write,Integer,Optional | energy generation 1.0 | Input current depending on data format registered by manufacturer. We will start with PV in controllers and Output in FL |
| Power (deciWatts) "pi" | 4 | Integer,Optional,Read-Only | energy generation 1.0 | Input power depending on data format registered by manufacturer. We will start with PV in controllers and Output in FL |
| Type of source "st" | 1 | Mandatory,Read-Write,Enum,Integer | energy generation 1.0 | Type of power generator. Known types -
0 = Disconnected/None - autodetected
1 = DC Solar - autodetected
2 = AC Grid/microgrid (as a source) - autodetected
3 = DC Grid/microgrid (as a source) - from gateway
4 = AC Wind power - from gateway
5 = DC Wind power - from gateway
6 = AC Hydro power - from gateway
7 = DC Hydro power - from gateway
8 = AC Petrol/Diesel Generator - from gateway
100 = Unknown - from gateway |
| eg | 4 | Optional,Read-Only,Integer | energy generation 1.0 | 'Energy generated' in deciwatt-hours(Wh / 10). Computed over a time window defined by egs and egp. |
| egs | 4 | Optional,Read-Only,Integer | energy generation 1.0 | 'Energy generation start'. Minutes in the past (minutes ago) when the reported eg value began accumulation. |
| egp | 4 | Optional,Read-Only,Integer | energy generation 1.0 | 'Energy generation period'. Minutes since egs over which the value of eg was accumulated. For example, if egs is 60, and egp is 60, the value of eg represents the watt-hours generated during the past hour. |

### Battery Resource /batt

| Resource Property | Octets | Qualifiers | Nx Resource | Description |
| --- | --- | --- | --- | --- |
| cbor header | 1 | Read-Write |  | encapsulating the rest of the properties |
| Timeseries History remaining “tsh” | 2 | Read-Only,Optional,Scope: Time-series | PAYG Credit 1.0 | Any resource with one or more timeseries properties is enabled with this optional property which can indicate that the device has stored historical data while offline that it can sequentially upload to the gateway via multiple reads |
| Bat Voltage mV "vb" | 4 | Read-Only,Integer,Optional Grp 3,Scope: Time-series | Battery 1.0 | Only for Battery Device |
| Bat charging or discharge current mA "ib" | 4 | Read-Only,Integer,Optional Grp 3,Scope: Time-series | Battery 1.0 | Only for Battery Device |
| Bat Pct "cp" | 3 | Optional Grp 3,Read-Only,Integer,Scope: Time-series | Battery 1.0 | Only for Battery Device, charge percentage |
| Charging Status "cs" | 1 | Enum,Optional Grp 3,Scope: Time-series | Battery 1.0 | 0 = No Data
1 = Charging - fast
2 = Charging - slow / trickle
3 = Discharging |
| Alert Threshold (%) "th" | 3 | Read-Write,Optional Grp 3,Integer,Scope: Time-series | Battery 1.0 |  |
| Low battery "lb" | 1 | Bool,Optional Grp 3,Scope: Time-series | Battery 1.0 | 0: cp>th
1: cp<th |
| LastChargeCycle BatPctMin "cmin" | 2 | Optional,Read-Only,Integer,Scope: Time-series | Battery 1.0 | Only for Battery Device, Could be Infrequently reported |
| LastChargeCycle BatPctMax "cmax" | 2 | Optional,Read-Only,Integer,Scope: Time-series | Battery 1.0 | Only for Battery Device, Could be Infrequently reported |
| LastChargeCycle ChgTime "tc" | 2 | Optional,Read-Only,Integer,Scope: Time-series | Battery 1.0 | in minutes, Only for Battery Device, Could be Infrequently reported |
| LastChargeCycle ChgUnits (mAh) "qc" | 2 | Optional,Read-Only,Integer,Scope: Time-series | Battery 1.0 | in milliamp-hours, Only for Battery Device, Could be Infrequently reported |
| Bat Health "bh" | 1 | Optional,Read-Only,Integer,Scope: Time-series | Battery 1.0 | Only for Battery Device, Could be Infrequently reported |
| Timeseries Timestamp “ts” | 4 | Read-Only | Battery 1.0 | TImestamp of when the data is recorded |
| Timeseries History Index “thi” | 4 | Read-Only | Battery 1.0 | Whenever this property is available that means it is a timeseries resource.
thi = 0, means there is no more timeseries data.
Any number greater than zero can be used for indicating which data proceeds especially when the timestamp is the same.  |
| Dummy “dmy” |  | Optional | Battery 1.0 | Some Bluetooth chips require fixed-length Characteristics, this dummy can make up for variation in other properties lengths |
| Battery power management switch “pms” | 4 | Read-Write | AirLink Device Control 1.0 | XXXXXXXX - Battery Power management is ON 
0xBA1234CA - Battery Power management switch to OFF (Idle for battery draining during battery calibration)
0xBA1234DA - Battery Power management switched OFF

Mapped |
| Battery Capacity Set “bcs” | 4 | Write-Only | AirLink Device Control 1.0 | Battery capacity in mAh in range of 1000-20000 |