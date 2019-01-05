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
7. Finally: While containers are being improved every-day, they are not yet as mature and proven as VMs are. Thus: in certain business environments and loads, mission critical applications are better off in VMs.

## 3) Which would be benefits of running containers systems like Docker or LXC?

Docker, (I have not read much about LXC yet) provide tools that:

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

* __Principle__: Both have the same principle guiding them: splitting data among multiple disks to provide reliability, security and, sometimes, speed.
* __Technology__: Hardware-based RAID systems work through a raid controller device, to whom disks attach to. Software RAIDs need nothing more than a regular disk controller device (included in **most** computers today, bare some SoC devices such as the Raspberry Pi) and special software (included or easily installed on most Linuxes) such as *mdadm*.
* __Performance__: Hardware > Software, specially in more complicated configurations. On simpler configurations (RAID 0, 1), the performance hit can be negligible. Hardware controllers usually have cache memories that greatly improve small to medium loads performances, both on write and on read.
* __Cost__: RAID Controllers can be QUITE expensive. And if faster drives are used (and hardware raid controllers tend to demand those, while at it), that cost skyrockets. Software based RAIDS don't cost that much, and usually are designed to use (or have to make by with) commodity disks.
* __Scalability__: Storage units are an implementation of Hardware RAID that scale into the hundreds of disks. Software RAIDs won't (shouldn't) exceed the enclosure of the server that hosts them.
* __Reliability__: Hardware RAID controllers that carry a cache memory include batteries to guarantee data consistency in case of a power failure. Software based RAIDs must rely on the filesystem's tools for that kind of reliability (a function Hardware RAIDs will also use, too)

High cost, high stakes enterprise storage solutions tend to be all hardware-based RAID solutions.

But old this is the classic way of looking at things: this definitions are likely to change slightly:

For example, we just recently bought a pair of Dell EMC 7020 units: 250 disks on at least 3 different disks technologies (SSD, 7500 and 10000 RPM disks, SAS and NL-SAS), 6 slotted tiering, over a dozen expansion boxes, connected via 6/12Gb SAS cables. Redundant controllers, virtual ports for Fiber connectivity redundance, redundant SAS cable daisychaining between boxes, ... and a plethora of goods and options. A modern version of the classic standard enterprise storage solution.

Now, for the surprise: As of its latest update (couple of months maybe), the unit performs it's RAID stripping and redundancy and spares on the block level, not on the disk level anymore, effectively setting its redundancy level lower, on 2MB partitions of the disks it is using (which kind of makes sense, once we understand the principles of wear and usage that modern SSD drives inherently have.)

And for the software side of enterprise storage, CEPH is a seemingly strong contender to that (and it's FOSS, too!). While it forgoes the RAID technology, it embraces the principles of added redundancy on the *server* level. This time, the expendable device moves up from the disk to the whole server.
Joining servers with storage well into the Petabyte range, it also scales up in performance, all of this with commodity hardware.

## 7) In a Perfect World, how should hardware resource management look like for you in modern DevOps Culture working environment?

I understand this question as in asking how the hardware the company owns will be managed after the DevOps revolution.

In a Perfect World, "*friends don't let friends build Datacenters*."

In the current DevOps Culture and, specially, with **higly changing/dynamic demands of compute and storage**, a sane and rational use of the cloud providers is the way to go. The easiest (hardware) management is the one somebody else does for you.

Now, in a more real world, one where the GDPR exists, the scenario probably won't be as simple.

The next best thing is, IMO, owning lean, clean and secure datacenters, and leverage software tools to automate everything that can be automated. And then some more.

Managing hardware, as with all assets, comes at added costs:

* Warranty and support contracts need to be tracked down and renewed.
* Hardware is ~~likely~~ **surely** to be replaced on regular basis, anywhere from 2 to 5 years.
* Human resources enter yet another spiral of learning, implementing, monitoring, buying its replacement, keeping up with what vendors offer
* Support tends to be more expense than utility. Nevertheless, it's hard to go without it. Specially when assurance of operations is required regulatory entities.
* Back up and Disaster Recovery gets **significantly** more difficult.

There are software tools that would aid in this: ITOP comes to mind.

The tax on the human resources is higher. The alternative is to out-source which, again, not feasible on some cases.

## 8) What does automation and Infrastructure as Code mean to you?

Please construct your answer as a list of topics, listing concepts, possible applications, advantages, and tooling.

Optional: add a quick explanation how the tooling mentioned would work on a real system

### Definitions

Not long ago, Virtualization brought a series of real advantages over bare-metal solutions. Within that bundle came a few very special ones: software defined components, such as servers (CPU, memory and storage) and networks for those servers.

Infrastructure as Code is, to me, expressing those principles in human-readable, machine procesable code, along with the use of specialized tools to create whole infrastructures out of it. 

This **set of practices** opens up the operations trade to a whole new set of tools used by the developers, such as automated testing, versioning and collaboration; along with new ways of automation and scaling of the labor, shortening of the developing cycles, shortening of the time to deploy, etc.

### Criteria for a best practices
There is a lot to read on the subject but this are the criteria that I gathered and stuck with me the most. Most of the best practices I've found (and remember right now) derive from this and thus it's the way I've summarized it:

* Everything must be automated. Cattle, not pets.

Automation comes at the hidden ~cost~ benefit of forcing the convergence of the artifacts used to the bare minimum. Less special cases allow to, as the saying goes, start treating servers as cattle, not as pets.
Automation helps remove the fear of commiting changes to production, because it also helps by (automatically!) testing those changes in test environments. Automation removes sources of human error.

Automation brings continuous integration to the table, along with continuous delivery. Nice to have things that are increasingly pushing companies out of business.

* Tools need to accept automated input, have a command line interface. And they need to provide exits that can be chewed by other tools.

There are some ways to work around this limitation, but they are not pretty nor sustainable in time. Tools **must lend themselves to automation**, and this fact alone is enough to accept or reject a tool right from the start.

* Code needs to be human-readable.

Human-readable code can be stored in code versioning. And tends to be self documenting.
In that regard, YAML is better than JSON, but too much YAML is almost useless too.

* Visibility.

Artifacts need to fail fast and loudly (to the engineer developing them and monitoring team). Monitoring should help pinpoint the issue and a clear log of commits to the code versioning system will help find and revert the conflicting code or making a new fix. Clear versions for the configuration are nice too.

* Test infrastructures.

Having an automated infrastructure means it is easier than ever to spin up a new complete infrastructure (or a reduced version of it, to cut down on costs and time) to test the actual code to be deployed on a mock up, that can easily be destroyed upon completion.

* Configuration drift vs Inmutable servers.

One of the worst scenarios in the operations world is dealing with a legacy server no-one knows how to configure, let alone fix if broken. And to make matters worse, documentation tends to be missing too.
It should be a practice to forbid the direct configuration of a server and, instead, make the appropiate changes in the code that creates it.
Once this practice is embraced, we can even talk about *inmutable servers*, where configuration changes are simply not made to it, since it is quite easy to simply test the changes in a test environment, destroy the actual production server and replace it with a new one with the configuration change already set in place.

* Technical debt and the cost of automation.

Borrowing from the developers world: Rewrite often. Commit often. Integrate all the time.

Rewrite often, because it allows us to keep technical debt on check. Also: set time to rewriting (improving!) tasks, Commit often, because commiting leads to testing, which leads to production. Features reach sooner to the customer, bringing in more customers and money. Integrate all the time: avoid the high integration costs (and fear) that come from integrating too far apart in time.  

The cost of automation: While it's nice to solve problems with the tools we can craft, like with any other piece of code, maintenance becomes an issue sooner or later. Every project must be evaluated with this in mind.

### Advantages of IaC
speed of delivery. Lessens costs.
opens up to the posibility of offloading the infrastructure costs to providers.
Dynamic response to load.
Free (human) resources now can work on better tools, which in term are applied to the infrastructure, further improving the infrastructure.

### Tools

* Code versioning. Also: documentation.

Git is the market standard and for good reason. While there's value in other versioning solutions, there's no going wrong with Git.

* Virtualization technology and choice of vendors. To cloud or not to cloud.

This section deserves a lot more explaining.

The first choice will be VMs vs containers. Both are great tools but they don't solve exactly the same problem in the exact same manner, so I believe there's room for both in most scenarios and companies.

On the virtualization side, VMware, XenServer and Proxmox/KVM are viable solutions, in order of commercial to open source status, support, IT HRs involvement and corporative track record. Bigger tools are emerging, more on the hyperconvergence side of the spectrum: VMware appears again, Nutanix, Openstack are a few names of weight.

On the containers side of the street, LXD and Docker dominate the market AFAIK, with special mention to Kubernetes as an orchestration solution.

At the end of the day, all this tools aim to solve a somewhat similar issue: putting code into production. Docker+Kubernetes is, again, AFAIK, in the lead for the agile race.

Another thing to consider is where and how to host those solutions. Companies with a sizable investion up-front can cost a datacenter (or 2 o 3), others will prefer to offset that cost to a hosted cloud solution on some major brand name's servers (Amazon's AWS, Google's GCP, Microsoft's Azure) or other smaller IaS providers (Digital Ocean comes to mind). IBM is coming to the fray too, with it's newly aquired Red Hat weaponry.

Finally, I'd like to touch on yet another piece of future that is coming: Serverless compute on demand in the form of (the one I know) AWS's Lambda. In some scenarios, best value solution for processing.

* Image creation.

Images to be deployed on a VM Hypervisor or a container orchestration solution need to be authored, revised, versioned, tracked...

When talking about VM's, I'm familiar with Packer. It takes a piece of code and outputs an image ready to be deployed to some of the most popular hypervisors, aiding in the hunt for the elusive IaC ideal.

In the case of a container orchestration such as Docker, the Dockerfile already stands up for most of this functionality. The only thing missing is a docker registry to host those images, which can be paid to and hosted by 3rd parties or set up in-house (AFAIK) with free tools.

* Provisioning.

Once the image is instantiated, it needs to be tailored to suit its final form and destination.

The line that divides provisioning from the base image creation is thin and there is some overlap, but the tools are different. The old standards are Cheff and Puppet, and are likely to be the choice of older shops and more seasoned pros.
The new contenders are Salt and Ansible. The latter, my provisioner of choice, beats somehow the rest by not needing an agent running on the host, which greatly easies its adoption. But at the same time, the only reason keeping more than one provisioning solution in use is the complexity of managing them and learning them. 

* Deployment

IMHO the clearest winner in this category is Terraform, with Amazon's cloudformation at close second.

Terraform is the tool that helps define IaC, by taking a text file as input and interacting with Artifact hosting solution of choice and creating the objects in that text file. VMs, Containers and networks, credentials and ACLs. And it can 'talk' to multiple cloud providers and hypervisors too.

The price to pay is a reduced tool set to play with, since some features will not be supported by all providers.

I'm calling cloudformation a close since I'm finding some sorts of support of the tool for OpenStack and KVM.  

* Testing.

As with all code, it needs to be tested.

Most tools provide a syntax check for the code inputed. My choice of workflow is to deploy the code at test to a test infrastructure and run automated tests that check for the results. Ideally, after the test is succesful, an automated pipeline would push the changes to production, but that is still some distance down the road for my current office so I don't have it ironed out yet.

I was put in contact with Goss, as a tool for automated testing of infrastructure. I don't think it's perfect but it gets things done, and test files can be generated by a Q&A department as a test of approval.

* Monitoring.

Zabbix, Icinga, Nagios... lots of choices. My personal experience is with Zabbix, with some minor Grafana glitter put on top of its database.
I think most of them are fine (IME), as long as they allow with some (but not so much) effort to introduce custom tests and detection for special situations.

* CI/CD

This chapter is the one I'm missing the most. I know the idea is to automatically test and validate code and further deploying it to production, with some help of special tools. Jenkins comes to mind as the industry standar.

* Logs management.

Keeping track of a dynamic infrastructure can be quite a challenge, definitely not a thing for static tools.

Basically: logs can not be hosted on the machine that produces them, if that server is not long for this world. They need to be collected, filtered and actioned on on a central service.
ELK and Splunk are 2 of the biggest solutions in the market right now, but there a lot more!

* Load Balancing and service discovery.

As I said earlier in the 5th question, HAProxy, Nginx. Consul.

The need is services to be up, no matter the hosts that run them.
"dejar de apuntar a servidores que no se caen y trabajar para aprender, arreglar y relanzar ágilmente."

### A day in the life of an IaC practitioner.