DRBD
=========

Created following (and adapting) https://help.ubuntu.com/community/HighlyAvailableNFS

* Ignoring bonded networking. No use for a vagrant environment.
* If meant for production: create bond interfaces (in another rol?)


Requirements
------------

Hosts involved in the DRBD array must be able to resolve with each other. The role _hosts_ is used for that.

Role Variables
--------------

The following variables must be defined, there are no defaults configured.

Hostnames of the parties involved:

* primary_host
* secondary_host

* drbd_protocol (A|B|C)

Options for the DRBD created filesystem

* drbd_mount_options
* drbd_dump
* drbd_passno

TODO
----

Create variables for the drbd device file (/dev/drbd0) and the filesystem device file (/dev/md0 in our example) where the drbd partition will land.

Create variables for behavior, ports and performance present in the template that lands on  the drbd.conf file.


Example Playbook
----------------

    - hosts: servers
      roles:
         - { role: drbd }

Author Information
------------------

Francisco Fregona
