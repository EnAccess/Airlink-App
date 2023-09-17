# AirLink Docs

> AirLink is an open source framework ([MIT License](https://opensource.org/licenses/MIT)) for Pay-As-You-Go (PAYG) IoT devices to connect to compatible servers via Bluetooth® gateways. The protocol provides an interoperable communication standard and example code for wire-free communication between PAYG devices and an IoT server using smartphones as gateways.
> 
This is technical documentation for AirLink. If you are looking for an overview instead:
[https://enaccess.org/airlink/](https://enaccess.org/airlink/)

Here is a helpful guide for AirLink adopters: [Quick-start guide](AirLink%20Docs/Quick-start%20guide.md)

And adopter demos: [AirLink device provisioning and access demo](https://youtu.be/OAEcQaUBIao)


---

### AirLink Components
![Screenshot 2023-01-19 at 11.58.05 AM.png](AirLink%20Docs/Screenshot_2023-01-19_at_11.58.05_AM.png)

<div class="columns" style="column-count: 3;">

*[AirLink Devices](AirLink%20Docs/AirLink%20Devices.md)*

Nordic nRF firmware
- *Open-source on [GitHub](https://github.com/EnAccess/AirLink-Devices)*
<div class="column-break"></div>

[AirLink App](AirLink%20Docs/AirLink%20App.md)

Flutter app
- *Open-source on [GitHub](https://github.com/EnAccess/Airlink-App)*

<div class="column-break"></div>

#### [AirLink Server](AirLink%20Docs/AirLink%20Server.md)
Demo server 
- *Hosted by EnAccess*, based on [Thingsboard.io](http://thingsboard.io)

</div>





---

### AirLink Use

#### AirLink Data transfer flow
AirLink leverages Bluetooth and GSM to flow data from the device to the server via the app, and vice versa.
![AirLink Data transfer flow](AirLink%20Docs/Simusolar_Architecture_Diagram_-_IoT_Data_Flow.png)

#### AirLink devices during manufacture, provisioning and use
AirLink covers the full device lifecycle, with a complete path to get devices registered in the server, exchange data and control PAYGo functionality.
![AirLink interactions during device manufacture, provisioning and use](AirLink%20Docs/IoT_Communications_and_Components_spec_-_App_Architecture.png)

#### AirLink Lost/Stolen Devices Flow
Leveraging the RF connectivity, AirLink 'community-sources' device security, where anyone with an AirLink app can help find lost devices without sharing private data or compromising device PAYGo
![**AirLink Lost/Stolen Devices Flow**](AirLink%20Docs/AirLink_Unknown_Device_Flow.png)

---

### Related Resources
[Nexus Channel: Angaza's Inter-operability initiative](https://angaza.github.io/nexus-channel-models/resource_type_spec.html)

[OCF: Open source connectivity standards that AirLink derives from](https://www.google.com/url?sa=t&rct=j&q=&esrc=s&source=web&cd=&cad=rja&uact=8&ved=2ahUKEwionv_ev7zyAhXM8uAKHbRED4oQFnoECAgQAQ&url=https%3A%2F%2Fopenconnectivity.org%2Fdeveloper%2Fspecifications%2F&usg=AOvVaw1qzAFKPKuOt-Sv9a1-V_jA)

[OpenPAYGO Link: Wired inter-operability from Solaris/ EnAccess](https://github.com/EnAccess/OpenPAYGO-Link/tree/main/Documentation)

[OpenPAYGO Metrics: GSM inter-operability from Solaris](https://github.com/openpaygo/metrics)

[OpenPAYGO Token: Open Source PAYGO token reference design from Solaris/EnAccess](https://github.com/EnAccess/OpenPAYGO-Token)

[CBOR: Memory-Efficient data arrays](http://cbor.io)


---
**AirLink was developed by [Simusolar Inc](https://www.simusolar.com) 
![https://www.simusolar.com](AirLink%20Docs/Simusolar_logo.png)**

**with support from [EnAccess](http://enaccess.org)**
![ https://enaccess.org](AirLink%20Docs/logo.png)

