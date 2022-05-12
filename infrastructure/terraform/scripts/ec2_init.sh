#!/usr/bin/env bash

sudo apt update
sudo apt upgrade -y

sudo apt install -y keepalived
sudo apt install -y python3.7
sudo update-alternatives --install /usr/bin/python python /usr/bin/python3.6 1

sudo apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release
