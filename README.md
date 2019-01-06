README.md

This whole repository is hosted on [my github repo](https://github.com/franciscofregona/dominoes-kicker.git).

# Structure of the solution and justification on some choices

## 3rd party roles

I chose to use a 3rd party made role (ansible-softwareraid) because both I wanted to save some time; and I wanted to test myself and prove to you guys that the usage of 3rd party roles as building blocks is quite useful.

I did not use more than that one role because, also, I wanted to prove I can take care of everything I took care here. But that mechanism can certainly be exploited more, there are tons of roles to call in the ansible-galaxy and github spaces. In fact, it eases the adoption of the tool because a company can have role users, on one hand, and role developers on the other, with a more in depth knowledge of the tool but not necesarily of the global en result and status.

## Virtualization

Some or all of I've done should be also possible be made strictly with containers. But in part out of comfort, and part because of the wording of the tasks, I chose VMs for the NFS servers and the docker hosts (as opposed as containers for all that on the same machine you provided)

Also, for ease of development, I hosted the docker hosts on separate machines from the nfs servers (for a total 4 VMs instead of 2). While I recon this choice was made for my own confort and quality of life, I gather it also serves right the microservice mantra of *more, smaller machines, doing less each*.

As for the choice of virtualizing technology, in speed of development and utility, theres no much better than Virtualbox+Vagrant.

## High Availability tooling

I chose linux-ha's heartbeat because I used quite some time ago with decent results. If the tasks would have involved an HA setup based on DNS names as opposed to just IP addresses, perhaps the tale would have been different. Docker would (AFAIK) support the configuration of a swarm and a service within, that would keep services up no matter the fate of the hosts that run them, but I could not find such facilities for a more classic floating IP setup.

For the sake of simplicity (and out of memory of previous experiences) I stood by the *haresources* method of configuration (the other being by the use of Pacemaker). This simplicity comes at a price: the *heartbeat* would not detect if the service components are up and running. If I make some time and finish other tasks, I'll migrate it to a Pacemaker solution.

On the file server backend, again, DRBD has treated me well in simple setups. But both tools gave me a headache but I managed to stabilize them up to what I'd deem as stable.

The other downside of using the haresources method is that in its simplicity and lack of features, some things would not work or do so badly:

* the drbd detection scripts are now deprecated, still works but thats not great looking forward in time. The Pacemaker method would have solved this with the [ocf:linbit:drbd resource agent](http://linux-ha.org/wiki/Resource_agents).
* the NFS shares would simply not stay up, and the exports would not auto-publish on server startup or HA transfer. I solved it by creating my own ha manage service script, **exportffs**; in a way expanding Heartbeat's capabilities =).
* the same happened with the docker start up and teardown of the container, for which I scripted the **dockermon** resource (shell) script.

## Additional tools to install

A basic set of tools to install on any server must be

* minimal, and in a clear contradiction
* complete.

We need it to be minimal in order to avoid opening any possibility for an attacker to gain access, keeping disks lean, libraries installed (besides what the server needs to serve its purpose) to the minimum and the least impact on the memory and cpu possible.

At the same time, if anything goes wrong, it's the worst time to try to install tools that were not there before: we might need to keep the disk untouched (ie: deleted files or partitions), libraries that could conflict with the service the server gives, the parts in place to perform the installations could not work...

So, by definition, every list is wrong, but here's an attempt:

* Openssh-server and Fail2ban
* netstat
* iftop
* tcpdump
* iotop
* htop
* saidar
* atop
* and (maybe) a firewall

Frankly, I haven't used this tools (except for tcpdump and the iptables firewall) in many years or at all, so won't comment on how good they are; suffice to say they are in use in the infrastructure I work with, over a sizeable number of machines and services, and has worked well enough for years.

## Testing

In our previous interview I mentioned I had done some testing for infrastructure and Ansible with the aid of a tool I could not remember the name of. That tool is Goss, and it is what I used here.

Goss allows the tests to be both specified in YAML (with the additional possibility of using the template mechanism) and automatically created from a known to be working correctly server, interactively adding services and ports and files to be checked on.

Since NFS and WEB servers would need to check con different things, I set up a (group) variable with the name of the test file to send to the servers.

In order to run the tests and show the results within the Ansible run that set them up, we have to install the Goss Ansible module. The setup and provisioning of the Control Host should take care of it.

The added benefit of specifying the tests in a YAML file is that it can be composed by a Q&A department. Ansible already provides quick and "fail fast" feedback on the status of the tasks done while they run. The big added value comes by virtue of having those tests written by a coworker or even another department! (And therefore becoming "product acceptance tests".)

## Benchmarking

I plan to add benchmarks in separate files that document my findings, but haven't been able to actually do them yet.

NFS Servers will be benchmarked with the *fio* tool. Scaffolding is already in place (there's a playbook that would run the benchmark already in place.)
I'd/plan to test:
* Memory size of the VM. More memory is "more better", as Linux cache tools would cover more (or all) of the files published.
* CPU count. Don't really expect to see an improvement, but it is easy enough to try. This test and the memory size one are to be run by simply altering the vagrant file (in case of the memory and CPU)
* Filesystem format. Ext2 should have marginally better write performance (journalling takes its tax), but we are not interested in that as of now (since the consumers, web servers, are not writing). I don't know what other options will be supported, but I'd try BTRFS, XFS, JFS, EXT3.

Filesystem is to be modified in the "Create a filesystem on the DRBD device" on the *roles/drbd/tasks/main.yml* file. And it should be a variable if it was to be modified frequently or there would be a difference between different fileservers.
In either case, machines will have to be tore-down and brought up anew (quite easily, too: *vagrant destroy* and *vagrant up* again!)

* NFS options. Still have to read up on the subject.
* I've done in the past an automated RAM disk along with a service for start and update from disk (as everything here, with Ansible) to accelerate things even further. I won't be exploring that way here for time constraints, but it is doable and I should have some code laying around to show how to. Either way, It's not something I'd expect to use on a filesystem of a real world size, but it may have its uses and definitely scores cool-ness points. (I developed it for a PXE server to beat hard disk speed constraints... only to be halted 1 step further with network card speed ¯\\\_(ツ)\_/¯)

Before finding the *fio* utility, I developed a few scripts and tryed my hand at manually finding some figures. To no avail (I was probably hitting my head against the Linux caching facilities). In the resources/scripts directory I enclose the scripts/one-liners to generate thousands of files, remove them and a generator of a random list of files contained.

I still don't know how to test the speed of access from the web servers end of the stick. As of now, I know I can provide some figures by *wget*ing a list of random files and clocking it. I'll continue reading and looking for a better solution.

## The solution

1. Find the answer to the questions in the Questions.md file.
2. The NFS servers will pop up in their own virtual machines by running the *vagrant up* command on the vagrant/nfsServer directory.
3. In the same line, the WEB servers will start after another *vagrant up* on the vagrant/webServer directory.

# The Ansible approach

Ansible is basically an ssh wrapper. It allows us to hit any server via ssh, and leverage the server's Python installation (and it can be installed with some special provisioning) to create complex configurations. The most prominent "downside" of Ansible is that it embodies a *push* model, but provisions can be made to use a *pull* mode.

The code states the order of operations to reach a certain state, and the operations are mostly idempotent. Ansible supports YAML files, that are both human and machine readable.

In order to guarantee that idempotence, we must use ansible **modules**. For example, the **copy** module will, well, copy a file from the control computer to the target server. But won't copy it again on a second run if the file is already there.

Ansible supports the use of encrypted files for sensitive information to be stored in, but I did not felt the need to use them in this test. Encrypted files are decrypted on the fly and their contents are never written to disk for added security.

Most operations needed in every day administration will be covered by some modules. In those rare cases we need something else, we could program our own modules or resort to the *command* and *shell* modules to perform raw shell commands on the host (but it can't and won't assure idempotence, caveat emptor).

Ansible proposes a separation of code and values (variables). That way we can reuse the same code in different servers, environments and uses. Its ingredients are:

###### Inventory:

An inventory is in its simplest form a list of target hosts. Those hosts can be then grouped up in any configuration we want and then apply changes only to certain groups. Groups in Ansible are not exclusive.

The inventory is also a good place to store variables that are associated to the hosts or the groups of those hosts.

###### Roles:

Roles are a gathering of code, instructions to be applied to (some) hosts.

They consist of a folder with some known possible subfolders within. Roles support dependency through the contents of its *meta* subdirectory.

The origin of this Role name and concept comes from the need to put some blocks together a functioning server. For example:

A server fills in the role of being a 'file server'.

In order to construct that "role", we must supply the target server with a set of building blocks: an ssh configuration, a monitoring client, some logging client or federation configuration, a set of configurations for, say, a samba service...

###### Playbook: ties both together.

So, we have hosts and variables (inventory), and code to apply to hosts.

A playbook is a set of instructions that help tying all that together: which servers get to be what, by the application on them of which roles.

###### The Control Host

This inventory and roles are to be hosted on a computer. This computer will have the Ansible tool installed and will translate the mesh of this YAML files into instructions to be run on the hosts. The server you provided for me to work on will then run the tool against the virtual machines configured within itself.

The catch is that I also used Ansible to configure that Control Host from my home PC (as a Control Host of its own).

This YAML text is, then, code, which can easily represent Infrastructure state, therefore IaC.

## Automate even the control host
Since I'm developing from a PC to a host you provided, I automated the configuration of that too.
Ansible needs only ssh access and a python interpreter on the target host, so the first run of configuration (installing Ansible, so it can itself hit on the virtual machines locally, vagrant and virtualbox to set up those machines) I'll do it from my PC with an ansible-playbook command (see below).

Further configurations to the control host can be made either way: remotely (from my machine to the control host), or leveraging the now installed Ansible client, locally from the control host onto itself (with a specially crafted inventory file, HomeServerPLocal.yml, defining the ansible_connection variable to "local"), and getting the latest revision of my code with a **git pull**.

The host can be "pinged" to check for connectivity (in the Ansible "way" of pinging) then, either with

```bash
ansible PHomeServer -m ping -i inventory/homeserver/hostsProd.yml -K
```

(Using the public IP to access the host, either from within itself or from outside of the machine. The "-K" flag asks for the sudo password of the account)
or using

```bash
ansible HomeServerPLocal -m ping -i inventory/homeserver/hostsProd.yml -K
```

which will hit on the localhost address.

# Summary of operations

Once the host has been set up properly, adjusting its configuration and further readjusting the virtual machines is an easy task.

The virtual machines are set up with vagrant, and I include the Ansible playbooks as means of provisioning them from within the same Vagrant file. So in order to get a test infrastructure with all I was asked to provide we only need to vagrant up those servers.

###### Get the latest version of this repo:

```bash
git clone https://github.com/franciscofregona/dominoes-kicker.git
```

(or git pull if already cloned. The server you provided has already cloned it.)

cd into the repo folder (you must be seing this file along with Questions.md).

```bash
cd dominoes-kicker
```

(I renamed this folder to TechnicalTest on the provided server)

###### Set up the control host with (again, already done)

```bash
ansible-playbook playbooks/localDownload.yml
ansible-galaxy install -r requirements.yml
ansible-playbook playbooks/ProvisionHomeServer.yml -i inventory/homeserver/hostsProd.yml -l PHomeServer -K
```

(If instead we want to run it against itself, use 
ansible-playbook playbooks/ProvisionHomeServer.yml -i inventory/homeserver/hostsProd.yml -l **HomeServerPLocal** -K)

###### Deploy the nfs servers with:

```bash
cd vagrant/nfsServers
vagrant up
```

The servers automatically pop up and provision themselves with the contents of the ProvisionNFSServer.yml playbook. They should be running in a short while (4 minutes or so) and in a High Availability configuration.

The last task executed by the provisioner is the run for the tests. If at any point we want to re run those tests, we can simply **cd back to the root directory of the repo** and run:

```bash
ansible-playbook playbook/ProvisionNFSServer --tags goss
```

###### To run a benchmark test, **cd back to the root directory of the repo** and run:

```bash
cd ../..
ansible-playbook playbooks/TestNFSServer.yml
```

A file with the results, timestamped, will popup in the *testResults* directory.

###### Launch the web servers:

```bash
cd vagrant/webServers
vagrant up
```

The servers launch and self provision with the instructions set in the ProvisionWebServer.yml playbook.
Through the magic of port redirections, webServer1's dockerized apache port is redirected to the virtual machine's 8080 port, in turn redirected to the Home Server's 8081 port. The same thing it's done with the dockerized apache on webServer2, that ends up on the Home Server's 8082 port.

So, in order to find the web page we can simply *wget localhost:8081* (or *8082*).

The benchmarking tests I run are documented on the *web benchmarking.md* file.

# Some of the links I used as reference.

* [Vagrant - Adding a second hard drive - EverythingShouldBeVirtual](https://everythingshouldbevirtual.com/virtualization/vagrant-adding-a-second-hard-drive/)
* [Vagrant with extra disks · GitHub](https://gist.github.com/djoreilly/e75e4e1e7e6ed371ef98)
* [Vagrant Tricks: Add extra disk to box – real world IT](https://realworlditblog.wordpress.com/2016/09/23/vagrant-tricks-add-extra-disk-to-box/)
* [Longest man page you&#39;ve seen? / GNU/Linux Discussion / Arch Linux Forums](https://bbs.archlinux.org/viewtopic.php?id=60019)
* [bash - How to split a large text file into smaller files with equal number of lines? - Stack Overflow](https://stackoverflow.com/questions/2016894/how-to-split-a-large-text-file-into-smaller-files-with-equal-number-of-lines)
* [5. Optimizing NFS Performance](http://nfs.sourceforge.net/nfs-howto/ar01s05.html)
* [How to do Linux NFS Performance Tuning and Optimization](https://www.slashroot.in/how-do-linux-nfs-performance-tuning-and-optimization)
* [Slow NFS transfer performance of small files - Server Fault](https://serverfault.com/questions/31628/slow-nfs-transfer-performance-of-small-files)
* [Highly Available NFS Storage with DRBD and Pacemaker | SUSE Linux Enterprise High Availability Extension 12 SP4](https://www.suse.com/documentation/sle-ha-12/singlehtml/book_sleha_techguides/book_sleha_techguides.html)
* [NFS Cluster - Setup Corosync and Pacemaker](https://www.capside.com/es/labs/highly-available-nfs-cluster-setup-corosync-pacemaker/)
* [SystemMonitoring - Debian Wiki](https://wiki.debian.org/SystemMonitoring)
* [Collect Docker metrics with Prometheus | Docker Documentation](https://docs.docker.com/config/thirdparty/prometheus/#use-prometheus)
* [simonmcc/vagrant-bond: example of using a bond0 inside vbox under vagrant](https://github.com/simonmcc/vagrant-bond)
* [HighlyAvailableNFS - Community Help Wiki](https://help.ubuntu.com/community/HighlyAvailableNFS)
* [Recreating a RAID Array Using mdadm and drbd](https://www.ossramblings.com/using_drbd_to_mirror_servers)
* [Calculating DRBD Meta Size - Server Fault](https://serverfault.com/questions/433999/calculating-drbd-meta-size)
* [Initial ramdisk - Wikipedia](https://en.wikipedia.org/wiki/Initial_ramdisk)
* [mdadm - Wikipedia](https://en.wikipedia.org/wiki/Mdadm)
* [Chapter 8. VBoxManage](https://www.virtualbox.org/manual/ch08.html#vboxmanage-list)
* [How To Create a High Availability Setup with Corosync, Pacemaker, and Floating IPs on Ubuntu 14.04 | DigitalOcean](https://www.digitalocean.com/community/tutorials/how-to-create-a-high-availability-setup-with-corosync-pacemaker-and-floating-ips-on-ubuntu-14-04)
* [How To Create a High Availability HAProxy Setup on Ubuntu 14.04](https://vexxhost.com/resources/tutorials/how-to-create-a-high-availability-haproxy-setup-with-corosync-pacemaker-and-floating-ips-on-ubuntu-14-04/)
* [Odd Bits - Four ways to connect a docker container to a local network](http://blog.oddbit.com/2014/08/11/four-ways-to-connect-a-docker/)
* [HighlyAvailableNFS - Community Help Wiki](https://help.ubuntu.com/community/HighlyAvailableNFS#Create_bonded_network_interface)
* [How to unit test.. a server with goss - Dots and Brackets: Code Blog](https://codeblog.dotsandbrackets.com/unit-test-server-goss/)
* [Mounting NFS on a Linux Client](https://mapr.com/docs/51/DevelopmentGuide/c-mount-nfs-on-linux.html)
* [How can I select random files from a directory in bash? - Stack Overflow](https://stackoverflow.com/questions/414164/how-can-i-select-random-files-from-a-directory-in-bash)
* [Printing the output of a bash script executed by a goss test · Issue #243 · aelsabbahy/goss](https://github.com/aelsabbahy/goss/issues/243)
* [Getting Started with Heartbeat | Linux Journal](https://www.linuxjournal.com/article/9838)
* [Deleting tons of files in Linux (Argument list too long) | SteveKamerman.com](http://www.stevekamerman.com/2008/03/deleting-tons-of-files-in-linux-argument-list-too-long/)
* [indusbox/goss-ansible: Ansible module for Goss](https://github.com/indusbox/goss-ansible)
* [aelsabbahy/goss: Quick and Easy server testing/validation](https://github.com/aelsabbahy/goss)
* [include_role - Load and execute a role — Ansible Documentation](https://docs.ansible.com/ansible/latest/modules/include_role_module.html)
* [Using Variables — Ansible Documentation](https://docs.ansible.com/ansible/latest/user_guide/playbooks_variables.html#id15)
* [bash - How can I time a pipe? - Unix &amp; Linux Stack Exchange](https://unix.stackexchange.com/questions/364156/how-can-i-time-a-pipe)
* [httpd - Docker Hub](https://hub.docker.com/_/httpd/)