# Platform Deploy

## Prerequisites

- Linux OS to run commands
- Install Ansible
- Ansible Docker Community Collection installed

  ```bash
  ansible-galaxy collection install community.docker
  ```

## Infrastructure and Servers

Please see the `/inventories/{ENVIRONMENT}/hosts` file for IP details of the designated services. Set these to the server's domain name/s that you created via terraform.

## Ansible

### SSH Access

To authenticate users and to allow them to have sudo access on the remote servers your ssh key will need to be added to the `sudoers` var in the _/inventories/{ENVIRONMENT}/group_vars/all.yml_.

To authenticate users and to allow them to have docker access you need to add your ssh key to the  `docker_users` var in the _/inventories/{ENVIRONMENT}/group_vars/all.yml_.

Ensure that you remove all users that you don't want to have access. The default development files have a bunch of Jembi staff's user credentials.

An pre-authorised user will need to run the `provision_servers.yml` playbook the first time to add your ssh key to the servers.

### Configuration

Before running the ansible script add the server to your known hosts file else ansible might complains, for each server run:

```sh
ssh-keyscan -H <host> >> ~/.ssh/known_hosts
```

Next, ensure that you configure the `firewall_subnet_restriction` property of the _/inventories/{ENVIRONMENT}/group_vars/all.yml_ file if you are setting up multiple nodes in a Docker swarm. Docker swarm nodes need to communicate with each other, this property adds a restriction on the software firewall on each node (UFW) which only allow that communication to happen on the particular subset specified by this property.

To run a playbook you should do:

```bash
ansible-playbook \
  --become \
  --inventory=inventories/<INVENTORY> \
  --user=ubuntu \
  playbooks/<PLAYBOOK>.yml
```

OR to run all provisioning playbooks with the development inventory (most common for setting up dev server), use:

```bash
ansible-playbook \
  --become \
  --inventory=inventories/development \
  --user=ubuntu \
  playbooks/provision.yml
```
