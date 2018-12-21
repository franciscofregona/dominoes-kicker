# Technical Test. Questions.

## 1) What is the difference between Virtual Machines and Containers?

While both technologies aim to add an abstraction layer between the application and the hardware that supports it, they do so in different ways.

A virtual machine (VM) emulates a full machine or server, with a fully fledged operative system, but also a complete and working set of hardware.  
The system calls the virtual operative system will make to its virtual hardware (in order to make use of the resources it thinks it has) will then be translated to real system calls to the real hardware that hosts the whole stack by the Hypervisor software.  
Virtual machines do not know, by definition, that they are running on virtual hardware, and the frontier between its sisters VMs and the host that shelters them is strict (although violations to this principle prove to be quite useful. Examples of this come in the form of Virtual Machine Tool Packages for the different hypervisors, with improvements of performance and features; or the addition of a pass-through technology to allow a virtual machine to access a physical device that would not be possible to share or assign, such as a tape library).

A container, on the other hand, is a leaner approach to the same end: Containers run by a host run sepparate instances of the binaries and libraries it chooses to use, but using the same kernel the Host is running, by leveraging a special kernel-sharing application isolation technology.  
This limits severely the choice of operating system for the container, as it has to run the same kernel the Host runs, but it also comes at the greatly discounted cost of not having to emulate a full stack of hardware and operative system. Provisions to overcome this limitation have been made and some options have appeared recently to run Windows hosts and containers (most likely by running a host... ON A Virtual Machine!).

While a typical VM comes with a tax/overhead of a few hundreds MB of ram, a typical container would only insume a few tens of MB. Alpine, a container image known for its small size, starts at around 5 MB. And if additional container instances are to be run from the same image, none or minimal additional space/memory is needed.

Lastly: containers should be considered inherently less secure than virtual machines (which in turn should be considered less secure than bare-metal) but both are, pretty much, standard use in the market.

## 2) For which purpose would you decide to use a virtual machine instead of a container?

I'd choose to use a VM instead of a container to be able to:
1. fully customize the operative system and hardware that will run an application,
2. better constrain an ill-behaving application by means of sizing of memory, disk and number of CPUs,
3. test an application that is later to be deployed on bare-metal (using application in the broadest of meanings),
4. keep running legacy applications, Virtualizing (P2V) them out of obsolete hardware, legacy operating systems, without support or in need of isolation,
5. run applications developed in a monolithic paradigm (vs a micro-service paradigm, more suitable for containers). I'm not sure but the size of service (ie: databases) might set a case against containers as well,
6. running third-party applications, wired to be run as appliances (VM) and not to be as trusted as in-house developed ones.
7. Finally: While containers are being improved every-day, they are not yet as mature and proven as VMs are. Thus: in certain business environments and loads, mission critical applications are better of in VMs.


## 3) Which would be benefits of running containers systems like Docker or LXC?

Docker, have not read much about LXC yet) provide tools that:

1. ease the development of services with multiple parts, providing a separation between them (ie: separate containers for frontend, back-end, db...),
2. connectivity for those parts, in the form of software defined networks and port redirections
3. support for different versions of the dependencies of each part, by the means of the encapsulation provided,
4. less errors arise from differences in configuration between the development (the programmer's PC!), testing and production environments. Every container comes with its dependencies.
5. ease of deployment (by load balancing or switching those software defined networks) allowing blue-green or canary schemes,


## 4) Which limitations does a container have on a Linux-based host system?

The most important limitation I can think of is security.

On an individual scope, you are still exposing an application that shares a kernel with other applications. Exploits are found every day on much more mature technologies. Yet, with adequate risk mitigation policies it should be manageable.

On a collective scope: what used to be a single VM on the server farm can now be (probably is) tens or hundreds of containers. Monitoring and auditing a dynamic, moving object gets only worse the more of them you have. Again: technologies exists to ease this task, but they must be on point.

The other big limitation of containers is graphical interfaces. Containers are simply not designed to support them.


## 5) Would you be able to mention at least one software solution for load-balancing that supports dynamic load-balancing with mostly zero-conf? How would it work?

HAProxy (and probably Nginx and LVS too) will allow to load balance among servers that have close to no configuration to that task in them. That is: the load balancing specific configuration is concentrated in the load balancer. But adding servers behind it imply that that configuration must change.

Another approach would be by leveraging service-discovery services.

Once set-up and running, new services that are created on demand get registered in the service discovery server's inner database and allow clients to query it for other services they need.

The one I've read and used in a small task before is **Consul**. Other examples could be **Zookeeper** and **Eureka**.

## 6) Please explain the difference between a software-based RAID system and a hardware-based RAID system. Is one better than the other? If so, why?

###### Principle: Both have the same principle guiding them: splitting data among multiple disks to provide reliability, security and sometimes speed.
###### Technology: Hardware-based RAID systems work through a raid controller device, where disks attach to. Software RAIDs need nothing more than a regular disk controller device (included in most computers today) and special software (included or easily installed on most Linuxes)
###### Performance: Hardware > Software, specially in more complicated configurations. On simpler configurations (RAID 0, 1), the performance hit can be negligible. Hardware controllers can have cache memories that greatly improve small to medium loads performances, both on write and on read.
###### Cost: RAID Controllers can be QUITE expensive. And if faster drives are used, that cost skyrockets. Software based RAIDS don't cost that much, and usually are designed to use (or have to make by with) commodity disks.
###### Scalability: Storage units are an implementation of Hardware RAID that scale into the hundreds of disks. Software RAIDs won't (shouldn't) exceed the enclosure of the server that hosts them.
###### Reliability: Hardware RAID controllers that carry a cache memory include batteries to guarantee data consistency in case of a power failure. Software based RAIDs must rely on the filesystem's tools for that kind of reliability (a function Hardware RAIDs will also use, too)

If the application demands the performance or added reliability, (or the cost is of no issue), a Hardware-based RAID is the only way to go.

## 7) In a Perfect World, how should hardware resource management look like for you in modern DevOps Culture working environment?

I understand this question as in asking how the hardware the company owns will be managed after the DevOps revolution.

In a Perfect World, "*friends don't let friends build Datacenters*."

In the current DevOps Culture and dynamic demands of computing power and storage, a sane and rational use of the cloud providers is the way to go. The easiest management is the one that somebody else does for you.

Now, in a more real world, one where the GDPR exists, the scenario is different.
The next best thing is, IMO, to leverage software tools to automate everything that can be automated. And then some more.
The cost on the human resources is higher. The alternative is to out-source which, again, not feasible on some cases.


###### 8) What does automation and Infrastructure as Code mean to you?

Please construct your answer as a list of topics, listing concepts, possible applications, advantages, and tooling.

Optional: add a quick explanation how the tooling mentioned would work on a real system
