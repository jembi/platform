---
description: A tool that enables infrastructure as code for provision of the servers.
---

# Ansible

## Platform Deploy

### Prerequisites

* Linux OS to run commands
* Install Ansible (as per [https://docs.ansible.com/ansible/latest/installation\_guide/intro\_installation.html](https://docs.ansible.com/ansible/latest/installation\_guide/intro\_installation.html))
* Ansible Docker Community Collection installed
* ```bash
  ansible-galaxy collection install community.docker
  ```

### Infrastructure and Servers

Please see the `/inventories/{ENVIRONMENT}/hosts` file for IP details of the designated servers. Set these to the server that you created via Terraform or to an on-premises server.

### Ansible

#### SSH Access

To authenticate yourself on the remote servers your ssh key will need to be added to the `sudoers` var in the _/inventories/{ENVIRONMENT}/group\_vars/all.yml_.

To have docker access you need to add your ssh key to the `docker_users` var in the _/inventories/{ENVIRONMENT}/group\_vars/all.yml file_.

An authorised user will need to run the `provision_servers.yml` playbook to add the SSH key of the person who will run the Ansible scripts to the servers.

#### Configuration

Before running the ansible script add the server to your `known_hosts` file else ansible will throw an error, for each server run:

```
ssh-keyscan -H <host> >> ~/.ssh/known_hosts
```

To run a playbook you can use:

```bash
ansible-playbook \
  --ask-vault-pass \
  --become \
  --inventory=inventories/<INVENTORY> \
  --user=ubuntu \
  playbooks/<PLAYBOOK>.yml
```

**Alternatively**, to run all provisioning playbooks with the development inventory (most common for setting up a dev server), use:

```bash
ansible-playbook \
  --ask-vault-pass \
  --become \
  --inventory=inventories/development \
  --user=ubuntu \
  playbooks/provision.yml
```

#### Vault

The vault password required for running the playbooks can be found in the `database.kdbx` KeePass file.

To encrypt a new secret with the Ansible vault run:

```bash
echo -n '<YOUR SECRET>' | ansible-vault encrypt_string
```

> The **New password** is the original Ansible Vault password.

### Keepass

Copies of all the passwords used here are kept in the encrypted `database.kdbx` file.

{% hint style="info" %}
Please ask your admin for the decryption password of the database.kdbx file.
{% endhint %}
