# Platform Deploy

## Prerequisites

- Linux OS to run commands
- Install Ansible
- Ansible Docker Community Collection installed

  ```bash
  ansible-galaxy collection install community.docker
  ```

## Infrastructure and Servers

Please see the `/inventories/{ENVIRONMENT}/hosts` file for IP details of the designated services. Set these to the server that you created via terraform.

## Ansible

### SSH Access

To authenticate yourself on the remote servers your ssh key will need to be added to the `sudoers` var in the _/inventories/{ENVIRONMENT}/group_vars/all.yml_.

To have docker access you need to add your ssh key to the  `docker_users` var in the _/inventories/{ENVIRONMENT}/group_vars/all.yml_.

An authorised user will need to run the `provision_servers.yml` playbook to add your ssh key to the servers.

### Configuration

Before running the ansible script add the server to your known hosts file else ansible might complains, for each server run:

```sh
ssh-keyscan -H <host> >> ~/.ssh/known_hosts
```

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
