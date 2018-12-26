README.md

This whole repository is hosted on [my github repo](https://github.com/franciscofregona/dominoes-kicker.git).

# Structure of the solution
## The Ansible approach
separation of code and values (variables). Ingredients
* inventory
* roles
* playbook: ties both together.
* the control host

## Automate even the control host
Since I'm developing from a PC to a host you provided, I automated the configuration of that too.
Ansible needs only ssh access and a python interpreter on the target host, so the first run of configuration (installing Ansible, so it can itself hit on the virtual machines locally, vagrant and virtualbox to set up those machines) I'll do it from my PC with an ansible-playbook command (see below).

Further configurations to the control host can be made either way: remotely (from my machine to the control host), or leveraging the now installed Ansible client, locally from the control host onto itself (with a specially crafted inventory file, HomeServerPLocal.yml, defining the ansible_connection variable to "local".)

The host can be "pinged" to check for connectivity (in the Ansible way of pinging) then, either with

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

Get the latest version of this repo:

```bash
git clone https://github.com/franciscofregona/dominoes-kicker.git
```

(or git pull if already cloned)
cd into the repo folder (you must be seing this file along with Questions.md).

```bash
cd dominoes-kicker
```

Set up the control host with

```bash
ansible-playbook playbooks/localDownload.yml
ansible-galaxy install -r requirements.yml
ansible-playbook playbooks/ProvisionHomeServer.yml -i inventory/homeserver/hostsProd.yml -l PHomeServer -K
```

Deploy the nfs servers

```bash
cd vagrant/nfsServers
vagrant up
```

The servers automatically pop up and provision themselves with the contents of the ProvisionNFSServer.yml playbook. They should be running now and load balancing between them.

If you want to run a benchmark test, back in the root directory of the repo:

```bash
ansible-playbook TestNFSServer.yml -i inventory/techtest/hostsProd.yml
```

A file with the results, timestamped, will popup in the testResults directory.

If instead you want to populate the server with some files, for the web servers to have something to server:

```bash
ansible-playbook PopulateNFSServer.yml -i inventory/techtest/hostsProd.yml
```

Then, to launch the web servers:

```bash
cd vagrant/webServers
vagrant up
```

The servers launch and self provision with the instructions set in the ProvisionWebServer.yml playbook.

I have not done any benchmarking on the web servers yet.

# Links I used.

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