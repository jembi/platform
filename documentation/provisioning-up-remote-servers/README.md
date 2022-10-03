---
description: A package for deployment tools.
---

# Provisioning up remote servers

This package contains two folders: ansible and terraform.

## Ansible&#x20;

It is used for:&#x20;

* Adding users to the remote servers
* Provision of the remote servers in single and cluster mode: user and firewall configurations, docker installation, docker authentication and docker swarm provision.

All the passwords are saved securely using Keepass.

In the inventories, there is different environment configuration (development, production and staging) that contains: users and their ssh keys list, docker credentials and definition of the hosts.

## Terraform

It is used to create and set AWS servers.
