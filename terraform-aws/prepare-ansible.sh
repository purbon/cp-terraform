#!/usr/bin/env bash

apt-get update
apt-get upgrade -y

apt-get install python3 -y

apt update
apt install software-properties-common
apt-add-repository --yes --update ppa:ansible/ansible
apt install ansible
