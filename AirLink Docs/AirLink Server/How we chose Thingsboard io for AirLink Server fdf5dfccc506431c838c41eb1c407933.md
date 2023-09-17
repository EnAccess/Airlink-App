# How we chose Thingsboard.io for AirLink Server

## Decision Context

PAYG devices fall under the IoT 'edge device' umbrella. A small set of SaaS companies are currently offering integrated loan management and device management services to PAYG-IoT distributors, primarily focused on token-based GSM home-system devices with some extensions for data feedback. Companies like Angaza have proprietary hardware+software IoT stacks that offer API-integration at some levels while companies like Solaris offer more open source codebases for device firmware and token software. Neither offer an open-source provisioning or analytics platform, although both have SaaS offerings for analytics and PAYG control, integrated with their custom loan platform. Both have a per-end-user-per-month revenue model which is consistent with contemporary SaaS - their revenues scale directly with their customer's customer bases.

Simusolar would like to build or buy a PAYG + IoT Data system that has API integration, configurable analytics, cost-effective implementation, ability to serve partners as well as ability to aggregate data over BLE / GSM / Keypad / Wired systems. EnAccess has provided a $50,000 grant to Simusolar to build an open-source multi-medium IoT communication protocol and data format to support these goals in 2021, with a focus on a deliverable that can enable upstart companies in this area to easily overcome the PAYG-IoT technology barrier. Simusolar currently has pumps and fishing lights that will be modified to meet this standard.

---

We need to decide on the best alternative approach to building this IoT database and related tools. Simusolar has recently adopted several managed and no-code tools to enable speed of secure and scalable business process automation with low overhead costs. We believe this approach has long term value and hence we give priority to options which have managed or no-code cores. We consider two high-level options 
a. custom database with open source dashboarding tools (no-code device/partner management can follow alternate no-code/code analysis)
b. open source IoT platforms

### a. Custom db + Dashboard Options

(IaaS, e.g. managed Redis on DigitalOcean + custom droplet with code)

[The Best 9 Free and Open Source Dashboard Software](https://www.goodfirms.co/blog/best-free-open-source-dashboard-software)

[freeboard](https://freeboard.io/#pricing)

[Redash Reviews - GoodFirms](https://www.goodfirms.co/software/redash)

[Dashbuilder - Home](https://www.dashbuilder.org)

Pros of a custom db+dashboard approach

Freedom to adopt managed or self-managed databases without lock-in

Completely custom server code i.e. process triggers and PAYG responses

The communication layer ends at the database, cleanly separating the application layer which can be full-custom

A central database managed by one entity e.g. EnAccess would only require to handle communication layer while application layer would be handed off, making the central db more easily viable compared to a solution with an application layer 

Cons of a custom db+dashboard approach

Requires coding competence to pre-process incoming IoT data stream

Requires domain-expert skill for building of device provisioning and basic analytics flows

Requires a full-time administrator to manage IoT connection to rest of business apps platform

New workflow features require coding and hence take weeks to develop

Initial adoption by business takes longer due to coding requirements

### b. IoT Platform Options

(PaaS if managed or IaaS+PaaS in case of self-managed, includes closed-source options for reference)

[Guide to IOT Dashboards and Platforms](http://www.steves-internet-guide.com/iot-mqtt-dashboards/)

[IoT Analytics - ThingSpeak Internet of Things](https://thingspeak.com)

[ThingsBoard - Open-source IoT Platform](https://thingsboard.io)

[Homepage - Thingstream by u-blox IoT Communication-as-a-Service](https://thingstream.io)

[➤ Kaa Demo | Kaa IoT Platform](https://www.kaaproject.org/demo)

[OpenRemote | The 100% Open Source IoT Platform](https://openremote.io)

[Google Cloud IoT - Fully Managed IoT Services](https://cloud.google.com/solutions/iot)

[dweet™ - Bug Labs Enteprise IoT Platform](https://dweetpro.io/pricing.html)

[SQL Database for IoT & Sensor Data | CrateDB](https://crate.io/use-cases/iot-sensor-data/)

[Particle Company News and Updates | Particle](https://particle.io)

[Learn More - ThingSpeak IoT](https://thingspeak.com/pages/commercial_learn_more)

[itead/IoTgo](https://github.com/itead/IoTgo)

[Introduction to the Azure Internet of Things (IoT)](https://docs.microsoft.com/en-us/azure/iot-fundamentals/iot-introduction)

[AWS IoT - Amazon Web Services](https://aws.amazon.com/iot/)

Pros of an open-source IoT Platform approach

Leverages a pre-built best-practices approach to managing incoming IoT data-stream

Leverages a device provisioning and basic analytics platform that is ready to go, reducing the startup-building burden

New workflows can be built quickly as many of these platforms offer drag and drop UIs for process triggers based on incoming IoT connections

Companies can choose a managed or SaaS model for the same service if their business model supports that choice better than a self-managed PaaS

Cons of an open-source IoT Platform approach

Adopters would be initially oblivious to implementation details before they can study the large amount of platform source code in the specific programming language

The Application layer comes with presumptions about IoT management that may not apply across all businesses

Any central entity such as EnAccess who manages a common db might need to provide application-level client-management/API as well as database management and communication layer level API

---

### Perspectives on Approach

Simusolar has experienced the often hidden time-cost and domain-knowledge complexity of building device-provisioning/onboarding flows for IoT systems, and considers provisioning an important complement to the IoT data/PAYG flow when considering approaches facilitating new ventures in this field. Standardizing this while considering privacy best-practices could reduce a big barrier, further abstracting away the technical details for integrating PAYG IoT with other business applications. 

Data Retention management and Analytics is another natural feature desired of GSM IoT collections. We conjecture that most IoT analysis usually pivots on a single plotted variable for a particular device class e.g. power used by time of day for energy products, along with some standard status variables e.g. location, error state. PAYG control also has common requirements e.g. on/off control or use-metered control. 

Hence there are opportunities to design a platform that has pre-built, privacy-enabled standard features for device provisioning, single-variable control and single-variable graphing with map and status indicators and a built in retention policy. Such a platform could enable adopters of the project to incorporate standard IoT outcomes easily into their business operations.

Lock-in risks as well as the central role of EnAccess in enabling upstarts points to the importance of open source, modular approaches that allow the scaling of individual components as managed or self-managed entities, such as front end databases and servers that run data processing code.

### Culling the options

AWS/Azure/IBM IoT offerings were not considered the right cost-value tradeoff due to the complexity of adoption and the fact that the dataset of most adopters of this project will be limited in size and will manage with smaller IT teams i.e. not tens of millions of devices/interactions per day managed by a specialist IT team, but hundreds of thousands at most managed by a multi-tasking IT team. The caveat is potentially losing out on AI integration which could be useful for predictive tasks. In the PAYG-IoT business case, learning and prediction requirements are as yet not well defined as business differentiators and hence AI was not considered a prime factor.

The alternatives list was further limited by the following parameter choices: Open source, Free/freemium versions and no per-device fees. Per-devices services are roughly $2/month/device (in addition to any network/SIM card fees), which adds up quickly when selling a large number of smart devices and can be margin-limiting in low-cost markets. This consideration discounted dweetpro.io, [thingstream.io](http://thingstream.io), particle.io and thingspeak.com

*Baseline: SaaS + PaaS + IaaS + Support-vendor costs for Simusolar are $86,658/yr projected to reduce to $52,100/yr by December 2021 by using no-code platforms and internal support*

[Last Round Alternatives](How%20we%20chose%20Thingsboard%20io%20for%20AirLink%20Server%20fdf5dfccc506431c838c41eb1c407933/Last%20Round%20Alternatives%200ab7b7c54fa646a9ae62f45fe89de548.csv)

## Proposed Solution: [thingsboard.io](http://thingsboard.io) docker monolithic

Scale Architecture

![How%20we%20chose%20Thingsboard%20io%20for%20AirLink%20Server%20fdf5dfccc506431c838c41eb1c407933/Screen_Shot_2021-04-11_at_11.20.51_PM.png](How%20we%20chose%20Thingsboard%20io%20for%20AirLink%20Server%20fdf5dfccc506431c838c41eb1c407933/Screen_Shot_2021-04-11_at_11.20.51_PM.png)

Deployment proposal: Lock-in mitigation is by using a managed database for Cassandra/PostgreSQL

![How%20we%20chose%20Thingsboard%20io%20for%20AirLink%20Server%20fdf5dfccc506431c838c41eb1c407933/Screen_Shot_2021-04-12_at_12.10.41_PM.png](How%20we%20chose%20Thingsboard%20io%20for%20AirLink%20Server%20fdf5dfccc506431c838c41eb1c407933/Screen_Shot_2021-04-12_at_12.10.41_PM.png)

Multi-vendor management from a single central db

![How%20we%20chose%20Thingsboard%20io%20for%20AirLink%20Server%20fdf5dfccc506431c838c41eb1c407933/Screen_Shot_2021-04-12_at_12.07.11_PM.png](How%20we%20chose%20Thingsboard%20io%20for%20AirLink%20Server%20fdf5dfccc506431c838c41eb1c407933/Screen_Shot_2021-04-12_at_12.07.11_PM.png)

Private devices and dashboards via tenancy

![How%20we%20chose%20Thingsboard%20io%20for%20AirLink%20Server%20fdf5dfccc506431c838c41eb1c407933/Untitled.png](How%20we%20chose%20Thingsboard%20io%20for%20AirLink%20Server%20fdf5dfccc506431c838c41eb1c407933/Untitled.png)

PAYG control

![How%20we%20chose%20Thingsboard%20io%20for%20AirLink%20Server%20fdf5dfccc506431c838c41eb1c407933/Screen_Shot_2021-04-12_at_12.15.02_PM.png](How%20we%20chose%20Thingsboard%20io%20for%20AirLink%20Server%20fdf5dfccc506431c838c41eb1c407933/Screen_Shot_2021-04-12_at_12.15.02_PM.png)

Self-Provisioning

![How%20we%20chose%20Thingsboard%20io%20for%20AirLink%20Server%20fdf5dfccc506431c838c41eb1c407933/Screen_Shot_2021-04-12_at_12.14.02_PM.png](How%20we%20chose%20Thingsboard%20io%20for%20AirLink%20Server%20fdf5dfccc506431c838c41eb1c407933/Screen_Shot_2021-04-12_at_12.14.02_PM.png)

Plotting the primary variable by device type

![How%20we%20chose%20Thingsboard%20io%20for%20AirLink%20Server%20fdf5dfccc506431c838c41eb1c407933/Screen_Shot_2021-04-12_at_12.16.29_PM.png](How%20we%20chose%20Thingsboard%20io%20for%20AirLink%20Server%20fdf5dfccc506431c838c41eb1c407933/Screen_Shot_2021-04-12_at_12.16.29_PM.png)

### Feasible Implementation Plan

- Setup DigitalOcean Ubuntu droplet
- Setup [Thingsboard.io](http://thingsboard.io) docker image
- Test custom protocol integration, write connector if required
    - Test VPN integration with Aeris
- Buy managed PostGreSQL db on DigitalOcean
    - Reconfigure Thingsboard configuration-database connection
- Buy managed Cassandra droplet on DigitalOcean from Aiven
    - Reconfigure Thingsboard timeseries-database connection
- Setup administration for EnAccess and tenancy for Simusolar and Tulima Solar
    - Setup tenant profile including dashboard template
    - Setup provisioning flow on Simusolar servers to attach to Simusolar tenant
- Configure phone app to act as MQTT gateway for protocol-compliant devices, including claiming flow

### Stakeholder validation (R.A.C.I.)

Were the responsible (implementers) persons consulted for feasibility? 

Are the accountable (project manager) persons committed to the outcome? 

Have the consulted (change recipients) people indicated their support? 

Will the Informed (all other impacted) people receive the information in time? 

## Final Choice:

Date: 

Decider (Proof):