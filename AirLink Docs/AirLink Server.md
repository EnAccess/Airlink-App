# AirLink Server

### Demo Tenant

We have created a fully functional demo tenant to enable quick testing of AirLink in conjunction with the gateway and device apps. The demo tenant also can plot information reported from the Nordic BLE kit, as shown below:

![demo tenant.jpg](AirLink%20Server/demo_tenant.jpg)

## AirLink IoT Server Architecture

AirLink builds a structure on top of a standard [Thingsboard.io](http://Thingsboard.io) professional edition server. The only, minimal customization is the addition of a rule node to generate PAYG tokens, which is not a default part of Thingsboard. A Thingsboard PE server is a ‘multi-tenant’ server, which means several separated businesses can run their IoT devices from a single server without visibility into the other tenants data. This setup makes it a perfect candidate for a centrally hosted server that can onboard new participants in the AirLink community. ***Please familiarize yourself with [http://thingsboard.io/](http://thingsboard.io/) documentation before reading the rest of this page!***

[How we chose [Thingsboard.io](http://Thingsboard.io) for AirLink Server](AirLink%20Server/How%20we%20chose%20Thingsboard%20io%20for%20AirLink%20Server%20fdf5dfccc506431c838c41eb1c407933.md)

In the figure, the “AirLink Tenant” is the main location of the IoT setup of a particular tenant, which can be very different from the next tenant. In fact, we setup a second “Lost & Found Tenant”, also referred in this documentation as “Neighborhood Watch”, which is intended to be a common repository for tenant gateways who find AirLink devices that don’t belong to them but want to help locate them.

This documentation serves as the reference to setup your own tenant in a way that is AirLink compliant. The bulk of the setup is very simple, and the only relatively complex configuration which is the “Rule Chain”, can be imported from a JSON file available in the [AirLink Server repository](https://github.com/EnAccess/AirLink-Server).

![AirLink Server Tenant Setup](AirLink%20Server/IoT_Communications_and_Components_spec_-_Thingsboard.io_Architecture.png)

AirLink Server Tenant Setup

| Business Need | Business Concepts | Thingsboard Concepts |
| --- | --- | --- |
| Devices provision themselves | Technician,ProvisionDevice | API Token,Gateway,Integration,Provisioning,Device AuthToken,Rule-chain Script |
| AirLink uses nexus channel resource models ie standard device types | AirLink | Attributes,Device Profiles |
| Simusolar uses Aeris globalSIM in PAYG** gateways | Aeris VPN,First PAYG Server | Integration,Device AuthToken,Gateway |
| Phone or solar panel controls device | AirLink | Device AuthToken,Device Group |
| Device belongs to customer | PAYG Customer,PAYG Box ID,System ID,Sales Order | Customer,Device,Integration,API Token |
| Orders make Customers | Sales Order,PAYG Customer | Customer,Asset |
| CBOR transfer over HTTP/MQTT | AirLink | Integration,Data Converter |
| Loan platform updates credits | PAYG Credit,Financing,Webi | Integration,API Token |
| Device heeds PAYG credits | Financing | Integration,Device AuthToken |
| AirLink uses Nexus Keycode or Solaris OpenPAYGO Token | AirLink,Token Automation | Rule-chain Script,Attributes |
| Device data saved | Callhome Data,Graphs and Maps | Device,Data Converter,Rule-chain Script,Device AuthToken |
| Partners can see referred customer data | Graphs and Maps,PAYG Credit,PAYG Customer | Data Chart,Customer Group,Entity View Group |
| Technicians update devices | Technician,ProvisionDevice,DFU,Service Swap,Debug Data | DFU,Gateway,Device,Device AuthToken,User Group,Data Converter,Integration,Asset,Asset Group |
| Simusolar operates in several countries with inter-country asset movement | Centralized IT | Asset Group,Asset,User Group |
| Simusolar franchises payg functionality | Distributor,PAYG Credit,Graphs and Maps,Token Automation,Debug Data | Customer Hierarchy,Customer Group,Multi-tenancy |

### Test entities

We encourage creating test entities to learn about Thingsboard, that way production entities can be easily kept separate. Every entity can be grouped, so creating a test group for each type of entity is an easy way to do testing. Entities can be added to a test group by selecting one or more entities from the 'All' catch-all group, and adding to a specific group.

![Screen Shot 2021-11-14 at 3.42.53 PM.png](AirLink%20Server/Screen_Shot_2021-11-14_at_3.42.53_PM.png)

![Screen Shot 2021-11-14 at 3.42.44 PM.png](AirLink%20Server/Screen_Shot_2021-11-14_at_3.42.44_PM.png)

![Screen Shot 2021-11-14 at 3.42.30 PM.png](AirLink%20Server/Screen_Shot_2021-11-14_at_3.42.30_PM.png)

## Tenant Configuration

### How to get started with your AirLink Server tenant

Here is a step by step setup to your own tenancy in the AirLink server. Alternatively, if you end up installing your own [Thingsboard.io](http://Thingsboard.io) server, this guide can also help you right past the end of the installation steps detailed on Thingsboard.io.

1. Assumption: You have a “Tenant Administrator” email login provided by EnAccess for the first AirLink server, or one that you made for your own server
2. Setup Device Profiles
    
    ![Screen Shot 2022-01-26 at 9.20.24 PM.png](AirLink%20Server/Screen_Shot_2022-01-26_at_9.20.24_PM.png)
    
    1. Setup a “Gateways” profile and enable the “Allow provisioning...” option. To do this, you need to tap the pencil button and then remember to save by pressing the tick-mark button.
        
        ![Screen Shot 2022-01-26 at 9.20.13 PM.png](AirLink%20Server/Screen_Shot_2022-01-26_at_9.20.13_PM.png)
        
    2. Setup a “Devices” Profile, and enable the “Default” checkbox as in the figure above. Also enable the “Allow provisioning...” option as in the previous step
    3. Copy the Provisioning Keys and Secrets, you will need to input these in the AirLink app!
3. Import the rule chains: All data that flows to the thingsboard server goes to the root rule chain, and any other rule chain that the root chain hands off to. To process AirLink data, especially to enable PAYG token generation as well as the Neighborhood watch function, we customized this rule chain and saved it as a JSON file in the [AirLink Server repository](https://github.com/EnAccess/AirLink-Server). To use functionality beyond just the core AirLink functionality, we created another “Business Logic” rule chain which gets handed off all the data from the Root rule chain.
    1. First import the “Business Logic”, “Unknown Device Piggyback” and “PAYG Software Providers” rule chains JSON file by going to Rule Chain → + → Import Rule Chain
        
        ![Screen Shot 2022-01-26 at 9.15.41 PM.png](AirLink%20Server/Screen_Shot_2022-01-26_at_9.15.41_PM.png)
        
    2. Next, Import the “Root Advertisements and Telemetry” Rule chain. Your rule chain setup should look like this with no errors now:
        
        ![Screen Shot 2022-01-26 at 9.27.48 PM.png](AirLink%20Server/Screen_Shot_2022-01-26_at_9.27.48_PM.png)
        
        ![Screenshot 2023-01-30 at 1.48.06 PM.png](AirLink%20Server/Screenshot_2023-01-30_at_1.48.06_PM.png)
        
    3. Mark this rule chain as “Root” using the ‘flag’ button
        
        ![Screen Shot 2022-01-26 at 9.16.36 PM.png](AirLink%20Server/Screen_Shot_2022-01-26_at_9.16.36_PM.png)
        
4. Setup Test Devices, Customers, Users, Assets etc as shown in test entities above to assign devices, test the “Relationships” property and so on to build a digital model of your IoT business model. As you can see, each screenshot above has our own Test entities for good measure!
5. That’s it for the minimum required configuration! Next, configure your AirLink App to talk to your server, and your set to test with real devices!

The following sections show a few details of the other elements of the server, the latest documentation for which can be found on [thingsboard.io](http://thingsboard.io).

### User Roles

Two main roles are defined, Tenant Admin (first assigned along with tenant) who has full privileges within the platform including controlling other users access, and Technician who has full device privileges including re-provisioning and assigning to customers. Customer administration is presumed to be done via API integration by the business applications server, hence there is no third role regarding customer administration. 

![Screen Shot 2022-01-26 at 9.29.42 PM.png](AirLink%20Server/Screen_Shot_2022-01-26_at_9.29.42_PM.png)

### Device Provisioning Flow in AirLink Server

| Device State | Gateway Action |
| --- | --- |
| No Serial # | Program Serial # via BLE to Device |
| Has Serial #, but not Provisioned | Act as Application Server: using Tenant Admin or Customer User credentials (login + password)
1. Generate Server Auth Token (SAT) and Airlink ID (aid)
2. Provision Device to Devices Profile* in Server and get DeviceUUID
3. Generate PAYG Token Secret (PTS)
4. Write PTS to Server Side Attributes using DeviceUUID in Thingsboard server
5. Forget DeviceUUID

using BLE, 
1. write (SAT), (PTS) to device |
| Has Serial #, SAT, PTS | Act as application server: 
Request PAYG Token generation using user credentials / token generation credentials

Act as regular gateway: 
1. Request PAYG Attributes for Device using SAT
2. Write PAYG Token to device using BLE |
| Has Serial#, SAT, PTS and test token | Read device telemetry and post to server |

*Device profiles can be considered as the equivalent of 'class definitions' in object oriented programming, with each device then being an instance of a particular profile. We have two main device profiles, an edge device and a gateway. These could potentially be merged, however Thingsboard does make a differentiation between a gateway and non-gateway with a checkbox as well as requirements on data format, hence we define two profiles.

### Attributes and Time Series Data

Data exchanged with the device or with the application server in the context of a device are termed attributes. 

In the AirLink server (based on Thingsboard), Attributes are Device properties that are only stored as current values, while Timeseries data are properties tracked over time. Attributes and Timeseries keys can be created during provisioning or are automatically created in the Airlink server when first posted, allowing for flexibility in growing resource models over time without requiring reconfiguration of the server. The core AirLink resource models are registered in the [Nexus Resource Models Registry](https://angaza.github.io/nexus-channel-models/resource_type_registry.html).

[Working with IoT device attributes](https://thingsboard.io/docs/user-guide/attributes/)

The following are the major attribute types and their scopes in a basic AirLink setup.

**Server Side:** Attributes only seen by the server and application server integrations

**Shared by Server:** Attributes written to by the server and application server integrations, and available to the Device to read only

**Device Side:** Attributes written to by the device, and by application server integrations. Time series data also behaves this way.

![Screenshot from AirLink server showing Attributes and Telemetry. Telemetry is always client-scope or 'device side'](AirLink%20Server/Screen_Shot_2021-11-14_at_3.36.07_PM.png)

Screenshot from AirLink server showing Attributes and Telemetry. Telemetry is always client-scope or 'device side'

[Attribute Scopes for AirLink resource properties](AirLink%20Server/Attribute%20Scopes%20for%20AirLink%20resource%20properties%2081cd9ab605c54348a6c03bbef738dbd2.csv)

CBOR data types are defined here:

[https://datatracker.ietf.org/doc/html/rfc7049#section-2.1](https://datatracker.ietf.org/doc/html/rfc7049#section-2.1)

| NX resource | rtr | Resource Property | key | rtr_key | Qualifiers | CBOR Type | Description |
| --- | --- | --- | --- | --- | --- | --- | --- |
| AirLink Device Provisioning 1.0 | prd | Server Auth Token | sat | prd_sat | String,Mandatory,Scope: Shared | 3 | http://thinsboard.io has a 20-char device authentication token unique to each device. During device provisioning, this token is written to the device, permanently attaching the device to the server. The token is never transmitted again. |
| AirLink Device Provisioning 1.0 | prd | Provisioning Status | pst | prd_pst | Mandatory,Scope: Shared,Integer (uint8_t) | 0 | Reflected in Advt packet also. It can be unprovisioned, disabled, recall, stolen, Cash, Loan. The range is from 1-9. If not supported then 0 |
| AirLink Device Provisioning 1.0 | prd | PayG Unit | pu | prd_pu | Mandatory,String,Scope: Shared | 3 | 36^1  The unit of the PayG update, it can be minutes, hours, days, months and years. [m-minutes, h-hours, d- days, M-months, Y-years] |
| AirLink Device Provisioning 1.0 | prd | PayG Token starting code | psc | prd_psc | Scope: Shared,String | 3 | 1-day token, https://github.com/EnAccess/OpenPAYGO-HW |
| AirLink Device Provisioning 1.0 | prd | PayG Units accepted | pul | prd_pul | Mandatory,String,Scope: Device | 3 | CSV list of acceptable Units e.g. "l" for liters, "h,d" for hours and days |
| AirLink Client Provisioning 1.0 | prc | Provisioning Status | pst | prc_pst | Mandatory,Integer (uint8_t),Scope: Shared | 0 | Reflected in Advt packet also. It can be unprovisioned, disabled, recall, stolen, Cash, Loan. The range is from 1-9. If not supported then 0 |
| AirLink Client Provisioning 1.0 | prc | Readable ID + Cbor header 2 bytes | rid | prc_rid | Mandatory,Integer (uint32_t),Scope: Shared | 26 | 2^(8*4) = 4,294,967,296 numeric device ids or payment reference or any number that device should display |
| AirLink Client Provisioning 1.0 | prc | Customer's Phone | cp | prc_cp | String,Optional,Scope: Shared | 3 | Requested by customers for stolen device reporting (needs a workflow to collect this number explicitly from client in addition to regular lead number). Assign the mobile number of the customer to a device. With maximum of 16 character including + and country code number. This is for security purpose |
| AirLink Client Provisioning 1.0 | prc | Customer Name | cn | prc_cn | String,Optional,Scope: Shared | 3 | Requested by customers for lost device reporting. This writes the customer name to a device with the maximum of 16 characters with space and special characters inclusive. |
| AirLink Nexus Command 1.0 | nxc | Nexus COSE command | cmd | nxc_cmd | Scope: Shared | 3 | Upto 120 bytes for Nexus Channel Passthrough commands |
| AirLink PAYG 1.0 | pyg | Current Server Time | lt | pyg_lt | Optional,Scope: Device |  | Linux epoch format, expires in Y2035. The current time when updating the device with PayG update. We do not recommend using this to calculate PAYG use, because it could be used to trick the device into more tokens. This is for non-PAYG purposes eg client experience |
| AirLink PAYG 1.0 | pyg | Timestamp of last PAYG Update to device | lts | pyg_lts | Optional,Scope: Device |  | Linux epoch format, expires in Y2035, readonly - Historical last PayG update Timestamp |
| AirLink PAYG 1.0 | pyg | Timestamp at which PayG remaining was calculated | ts | pyg_ts | Optional,Scope: Device |  | Linux epoch format, expires in Y2035. The Last date and time when the PayG update was fetched from the Server to client [Mobile phone or other communication device] |
| AirLink PAYG 1.0 | pyg | Last Added PayG Credit | lcr | pyg_lcr | Optional,Scope: Device |  | Historical last PayG credit update duration. Range is from 01-9999 |
| AirLink PAYG 1.0 | pyg | PayG Token | tkn | pyg_tkn | Scope: Shared |  | SipHash token. Accepted by device only if valid. No read token to ensure unsecured gateways cannot act maliciously.  |
| PAYG Credit 1.0 | pyg | Mode | mo | pyg_mo | Not Implemented,Scope: Shared |  | mode of device i.e. leading/following etc

For Write, a Nexus Channel Link must be established otherwise read-only, updated via token. AirLink 1.0 does not implement Nexus Channel, which was in development at the time of release of AirLink 1.0 |
| PAYG Credit 1.0 | pyg | Device PayG Credit Remaining | re | pyg_re | Mandatory,Scope: Time Series |  | should be The value  remaining for the device to OFF. 

For Write, a Nexus Channel Link must be established otherwise read-only, updated via token. AirLink 1.0 does not implement Nexus Channel, which was in development at the time of release of AirLink 1.0 |
| PAYG Credit 1.0 | pyg | Payg Token Secret | pts | pyg_pts | Mandatory,Scope: Server |  | On first release, this is the Nexus Keycode secret |
| PAYG Credit 1.0 | pyg | Payg Token Message ID | msg | pyg_msg | Mandatory,Scope: Server |  | On first release, this is the Nexus Keycode message ID |

Posting of device data to the server for off-edge devices is done via gateway by sharing their device access tokens with the gateway using the application server. For Smartphone gateways, this can be done via a separate channel to the application server. For 'thing' gateways, this must be done via a 'disappearing' shared server attribute for that gateway, so that tokens are not saved in the insecure data space for too long. The application server then would update the attribute to transfer tokens to the gateway, and then blank it out once the gateway receives the tokens or after a certain timeout. 

### Authentication and Access types

AirLink server controls IoT interactions and can connect with the business applications server via REST API. The Business Applications server must authenticate itself as a User or Customer using JWT authentication, or have access keys to a custom integration as specified in the authentication flow. Note that only Custom Integration configurations are visible in the UI, the built-in telemetry, admin etc endpoints are only visible in the Swagger documentation but all events from each endpoint are posted to the root rule chain, enabling customized business logic for all types of data.

![AirLink Server Device Auth Flows](AirLink%20Server/IoT_Communications_and_Components_spec_-_Thingsboard.io_Architecture-2.png)

AirLink Server Device Auth Flows

Full API reference is available as live Swagger documentation here after you have a tenant login: 

[Swagger UI](https://airlink.enaccess.org/swagger-ui.html)

### Data Transport

Device-initiated or gateway-initiated communications posting time-series data and accepting a PAYG update response are expected to form the bulk of IoT traffic in PAYG use cases. Considering the Auth flows available for posting data, AirLink recommends four types of transport:

1. Individual devices equipped with GSM send data directly ***using their device token*** e.g. water pump control boxes
2. Gateways bundled with a sale ***register as MQTT gateways*** in the AirLink server to be able to post data from multiple downstream devices while minimizing bandwidth use. This is relevant because such IoT gateways often use data-thrifty 'Global-SIM' cards which can rack up high data costs e.g. solar panel with GSM chip bundled with 3 batteries that it charges
3. Phone apps acting as gateways post data ***as the device*** and get PAYG updates from the server, ***using the individual device tokens*** downloaded during the sales and service flows. This needs to be enabled by the business applications server and is useful because several phone gateways may be used to operate the same device and a one-device multi-gateway scenario with offline access is not well served by MQTT. PAYG security is still ensured by the fact that the token is still only decode-able to the server and the device and not the intervening gateways. e.g. equipment owner could operate the device, several equipment technicians could operate the device etc. 
4. Phone apps and gateways post advertisement data for ***unknown*** AirLink devices to facilitate lost-and-found using a ***special property within the gateway's telemetry***  which is then processed by the root rule chain with the necessary validations to ensure that data gets send to the correct recipient and so that it is not used for posting non-advertising telemetry or attributes for the device.

AirLink currently only supports HTTP transport, CoAP will be enabled in the future. CBOR formatting of data is not currently supported.

| Concept | MQTT | HTTP/CoAP ✅ |
| --- | --- | --- |
| Application Server + IoT Server model for value-added services | ⚠️ Can only be used for IoT comms, not business app comms | Needed by phone app for comms to application server, but not by non-phone gateways |
| Bandwidth | Better than HTTP for persistent connections - not expected in AirLink | ✅ CoAP is better than MQTT, more so when connections are sporadic - as is expected in AirLink |
| IoT Gateway functionality | ✅ Thingsboard supports MQTT as gateway paired with customer devices, majority use case
✅ Single connection can report multiple devices' data
❌ If multiple gateways need to own devices, they would need to be transferred between devices e.g. Field service agent's phone, customer's phone, farm boys' phone etc by online transactions with server - may not be feasible in the field | ⚠️ Credential of each device would need to be known to gateway (additional thingsboard workflow), and list of gateways that can control device wouldn't be registered with Airlink server (more potential for spoofing), requiring credentials to be refreshed or other security measures
⚠️ Each device would need to be reported separately, increasing number of HTTP required connections
✅ Could support arbitrary number of gateways |

### KeyCode generation

![Nexus Keycode generation integrated into the Root Rule Chain](AirLink%20Server/Token_Generation_in_Rule_Chain.png)

Nexus Keycode generation integrated into the Root Rule Chain

Nexus Keycode as well as OpenPAYGO Token use 'SipHash' to generate the key, and have Python/Java libraries available. However Thingsboard only runs single-file JavaScript in it's rule chains and custom Java in it's rule nodes, hence we decided to create a Java rule node based on Nexus Keycode. External keycodes could also be used by swapping that rule node with an External REST component in the AirLink server that points to a client's server running code generation, and response sent as token via AirLink to the device. 

Since Keycode generation is not a telemetry-time operation but rather account-payment time operation, the number of requests will scale with the number of devices and payment frequency rather than the number or frequency of telemetry data. 

The provided KeyCode node

1. Understands incoming business request as adding credit, setting credit or unlocking the device - POST REST requests to the rule-engine, authenticated using role-based access control (login) are used for the same.
2. Uses a per-device secret stored in the AirLink server db and the SipHash algorithm to generate the actual keycode
3. Returns this keycode to the rule chain for saving in the database to serve future GET requests from devices, and potentially sends it to a business server if required for SMS communications or saving in the business application server database

### KeyCode Generator Test Results

Here is a test sequence that can verify that the PAYG Token chain is working end to end from credit request to device function.

| KeyCode Node Function | msg_id, saved in server side attributes | Credit Request Packet from Postman POST mimicking loan management server - note the knowledge of ‘Device ID’, which is the UUID of the IoT device on the AirLink Server | Input Key to KeyCode node, visible in node “Events” metadata with Debug enabled on AirLink Server | Output Message from KeyCode node sent to Device via Shared Attributes sync’d through the AirLink gateway App, visible in node “Events” metadata with Debug enabled on AirLink Server | Decoded Output within AirLink Device implementing Nexus Keycode |
| --- | --- | --- | --- | --- | --- |
| Added 6 Days | 1 | {
    “pay_g_tkn”:”6”
} | “pay_g_tkn”:”6”, | *010 050 135 981 34# | - Received tkn *01005013598134#
- PayG update received
- Keycode is valid.
- Credit remaining: 86400 seconds
- PayG update received |
| Set Device to exactly 10 Days | 2 | {
    “set_tkn”:”11”
} | “set_tkn”:”11” | *123 026 694 078 81# | - Received tkn *12302669407881#
- PayG update received
- Keycode is valid.
- Credit remaining: 950100 seconds
- PayG update received |
| Unlock the Device | 3 | {
    “unlock_tkn”:”1”
} |  “unlock_tkn”:”1” | *336 153 083 439 44# | - Received tkn *33615308343944#
- PayG update received
- Keycode is valid.
- The device is unlocked
- PayG update received |

### Lost asset location tracking

A significant benefit of interoperability is the ability across vendors to track lost and stolen items. Given the distributed and rural nature of PAYG distribution, this becomes particularly relevant if all wireless-enabled devices can report their current location to any AirLink gateway whether paired with the device or not. The gateway then needs to be able to post this data to Thingsboard without knowing the device's security token. To facilitate this process, the gateway posts device data one at a time as it's own timeseries property which is processed by the Rule chain modification shown below. We then host a 'Lost and Found Tenant' in the server as shown in the architecture diagram, where un-secured device locations can be stored by gateways registered to other tenants. The process then is that if a gateway chances upon a device it doesn't have access to, it reports the advertising packet along with it's own location to the 'neighborhood watch' tenant, which then passes on the information to the tenant that owns the device using the device's manufacturer code, and automated rule-chain code passes this unregistered device onto the lost and found tenant where it can be available for access by the tenant who may have lost the device. If the tenant owning the device is the same as that of the gateway, then MQTT can also be leveraged for posting advertisement data without any change required to the server. However for devices belonging to other tenants, since a gateway cannot claim them, this flow of posting via the /timeseries/ endpoint for the gateway itself as a piggyback device is valid. Unfortunately [thingsboard.io](http://thingsboard.io) does not provide an easy method to post several devices from the gateway within the same transmission, hence the gateway will see one transmission per reported device. This should be considered in the data limits of each device, and alternate flows employed if the data flow is a bottleneck. Data-rich gateways such as Smartphones should afford virtually unlimited device reporting per day.

![Gateway Telemetry with a Piggyback Device](AirLink%20Server/Screen_Shot_2021-11-14_at_2.51.22_PM.png)

Gateway Telemetry with a Piggyback Device

[Connecting to Solaris or Angaza](AirLink%20Server/Connecting%20to%20Solaris%20or%20Angaza%20583f4651d258432b995c6e79fd468c48.md)