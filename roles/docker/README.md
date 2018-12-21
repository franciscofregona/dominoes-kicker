docker
=========

Installs docker-ce on the host. Afterwards, it copies a dockerfile to the host.

Requirements
------------

No external requirements.

Role Variables
--------------

Taken directly from the docker installation manual, the following variables are defined and these are the default values.

* docker_repo_key_url: https://download.docker.com/linux/debian/gpg
* docker_apt_repo_url: "deb [arch=amd64] https://download.docker.com/linux/debian stretch stable"

Dependencies
------------

No external dependencies.

Example Playbook
----------------

    - hosts: servers
      roles:
         - { role: docker }

Author Information
------------------

Francisco Fregona