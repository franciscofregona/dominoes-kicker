Ansible
=========

Installs Ansible on the host.

Requirements
------------

No external requirements.

Role Variables
--------------

Taken directly from the ansible installation manual, the following variables are defined and these are the default values.

* ansible_keyserver: keyserver.ubuntu.com
* ansible_key_id: 93C4A3FD7BB9C367 

Dependencies
------------

No external dependencies.

Example Playbook
----------------

    - hosts: servers
      roles:
         - { role: ansible }

Author Information
------------------

Francisco Fregona