# AirLink Docs

> AirLink is an open source framework ([MIT License](https://opensource.org/licenses/MIT)) to manage IoT devices connecting to compatible servers via Bluetooth® gateways. The protocol provides an interoperable communication standard and example code for wire-free communication between related devices and an IoT server, using smartphones as gateways. 
> 
> It also comes with a flow for tracking lost devices via crowd-sourced detection, and 'PAYGO' functionality to support use cases for financed devices.
>
> AirLink was developed to help entrepreneurs get over the main IoT development hurdles quickly and focus on their unique application

This is the technical documentation for AirLink. If you are looking for an overview instead:
[https://enaccess.org/airlink/](https://enaccess.org/airlink/)

Here is a helpful guide for AirLink adopters: [Quick-start guide](AirLink%20Docs/Quick-start%20guide.md)

And an end to end demo on how to get started in minutes: [AirLink demo video](https://youtu.be/OAEcQaUBIao)


---

### AirLink Components
AirLink is mainly a communication methodology, and proposes three components of which two are required at any given time. Each component has an open source library to get started with. Click each link to learn more.
![Screenshot 2023-01-19 at 11.58.05 AM.png](AirLink%20Docs/Screenshot_2023-01-19_at_11.58.05_AM.png)

<div class="columns" style="column-count: 3;">

**[AirLink Devices](AirLink%20Docs/AirLink%20Devices.md)**: *Nordic nRF firmware on [GitHub](https://github.com/EnAccess/AirLink-Devices)*

<div class="column-break"></div>

**[AirLink App](AirLink%20Docs/AirLink%20App.md)**: *a Flutter app on [GitHub](https://github.com/EnAccess/Airlink-App)*

<div class="column-break"></div>

**[AirLink Server](AirLink%20Docs/AirLink%20Server.md)**: A *[Demo server](https://airlink.enaccess.org) Hosted by EnAccess.org*
</div>


---

### AirLink Functional Highlights
Smartphone-gateway connectivity, an opinionated device lifecycle, a flow for lost/stolen devices and built-in PAYGO functionality are what set AirLink apart from open-source IoT solutions.

#### AirLink Data flow
AirLink leverages Bluetooth and GSM to flow data from the device to the server via the app, and vice versa. Data is structured for minimum overhead for devices and plug-and-play adding of new device types without server/app redos.
![AirLink Data flow](AirLink%20Docs/Simusolar_Architecture_Diagram_-_IoT_Data_Flow.png)

#### AirLink devices during manufacture, provisioning and use
AirLink covers the full device lifecycle, with a complete path to get devices registered in the server, exchange data and control PAYGo functionality.
![AirLink interactions during device manufacture, provisioning and use](AirLink%20Docs/IoT_Communications_and_Components_spec_-_App_Architecture.png)

#### AirLink Lost/Stolen Devices
Leveraging the RF connectivity, AirLink 'community-sources' device security, where anyone with an AirLink app can help find lost devices without sharing private data or compromising device PAYGo
![**AirLink Lost/Stolen Devices Flow**](AirLink%20Docs/AirLink_Unknown_Device_Flow.png)

#### Integration with Solaris and Angaza
AirLink devices can exchange tokens with Angaza and Solaris servers. The AirLink server recognizes the type of provider based on a configuration setting, and connects with Angaza or Solaris servers to get the latest PAYGo token. This provides out-of-the-box integration for those devices that support Nexus Token or OpenPAYGO Token.
>[Connecting to Solaris or Angaza](AirLink%20Docs/Connecting%20to%20Solaris%20or%20Angaza.md)

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
![](#ffffff)
![https://www.simusolar.com](AirLink%20Docs/Simusolar_logo.png)**

**with support from [EnAccess](http://enaccess.org)**
![ https://enaccess.org](AirLink%20Docs/logo.png)

