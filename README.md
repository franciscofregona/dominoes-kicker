Technical Test
=========

subtitles

Please write down responses for the following questions:

1) What is the difference between Virtual Machines and Containers?
------------

While both technologies aim to add an abstraction layer between the application and the hardware that supports it, they do so in different ways.
A virtual machine (VM) emulates a full machine or server, with a fully fledged operative system, but also a complete and working set of hardware.
The system calls the virtual operative system will make to its virtual hardware (in order to make use of the resources it thinks it has) will then be translated to real system calls to the real hardware that hosts the whole stack by the Hypervisor software.
Virtual machines do not know, by definition, that they are running on virtual hardware, and the frontier between its sisters VMs and the host that shelters them is strict (although violations to this principle prove to be quite useful. Examples of this come in the form of Virtual Machine Tool Packages for the different hypervisors, with improvements of performance and features; or the addition of a pass-through technology to allow a virtual machine to access a physical device that would not be possible to share or assign, such as a tape library).

A container, on the other hand, is a leaner approach to the same need: Containers run by a host use the same kernel the Host is running, by use of special separation of concerns included in the kernel.
This limits severely the choice of operating system for the container (practically: it has to run Linux), as it has to run the same kernel the Host runs, but it also comes at the greatly discounted cost of not having to emulate a full stack of hardware and operative system. Provisions to overcome this limitation have been made and some options have appeared recently to run Windows hosts and containers.

While a typical VM comes with a tax/overhead of a few hundreds MB of ram, a typical container would only insume a few tens of MB. Alpine, a container image known for its small size, starts at around 5 MB. And if additional container instances are to be run from the same image, none or minimal additional space/memory is needed.

Lastly: containers should be considered inherently less secure than virtual machines (which in turn should be considered less secure than bare-metal) but both are, pretty much, standard use in the market.

2) For which purpose would you decide to use a virtual machine instead of a container?
------------

3) Which would be benefits of running containers systems like Docker or LXC?
------------

4) Which limitations does a container have on a Linux-based host system?
------------

5) Would you be able to mention at least one software solution for load-balancing that supports dynamic load-balancing with mostly zero-conf? How would it work?
------------

Optional: more than one solution is described
Consul.

6) Please explain the difference between a software-based RAID system and a hardware-based RAID system. Is one better than the other? If so, why?
------------

7) In a Perfect World, how should hardware resource management look like for you in modern DevOps Culture working environment?
------------

8) What does automation and Infrastructure as Code mean to you?
------------
 Please construct your answer as a list of topics, listing concepts, possible applications, advantages, and tooling.
 
Optional: add a quick explanation how the tooling mentioned would work on a real system


Requirements
------------

Any pre-requisites that may not be covered by Ansible itself or the role should be mentioned here. For instance, if the role uses the EC2 module, it may be a good idea to mention in this section that the boto package is required.

Role Variables
--------------

A description of the settable variables for this role should go here, including any variables that are in defaults/main.yml, vars/main.yml, and any variables that can/should be set via parameters to the role. Any variables that are read from other roles and/or the global scope (ie. hostvars, group vars, etc.) should be mentioned here as well.

Dependencies
------------

A list of other roles hosted on Galaxy should go here, plus any details in regards to parameters that may need to be set for other roles, or variables that are used from other roles.

Example Playbook
----------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

    - hosts: servers
      roles:
         - { role: username.rolename, x: 42 }

License
-------

BSD

Author Information
------------------

An optional section for the role authors to include contact information, or a website (HTML is not allowed).
