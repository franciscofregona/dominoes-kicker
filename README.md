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

# Summary of operations
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
ansible-playbook playbooks/ProvisionHomeServer.yml -i inventory/homeserver/hostsProd.yml
```

Deploy the nfs servers

```bash
cd vagrant/nfsServers
vagrant up
```

The servers automatically pop up and provision themselves with the contents of the ProvisionNFSServer.yml playbook. They should be running now and load balancing between them.
If you want to run a benchmark test, back in the root directory of the repo:
ansible-playbook TestNFSServer.yml -i inventory/techtest/hostsProd.yml
A file with the results, timestamped, will popup in the testResults directory.
If instead you want to populate the server with some files, for the web servers to have something to server:
ansible-playbook PopulateNFSServer.yml -i inventory/techtest/hostsProd.yml
Then, to launch the web servers:

```bash
cd vagrant/webServers
vagrant up
```

The servers launch and self provision with the instructions set in the ProvisionWebServer.yml playbook.

I have not done any benchmarking on the web servers yet.
