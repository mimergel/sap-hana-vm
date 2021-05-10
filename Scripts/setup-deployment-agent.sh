#!/bin/bash

# Install Powershell
# Update the list of packages
sudo apt-get update
# Install pre-requisite packages.
sudo apt-get install -y wget apt-transport-https software-properties-common
# Download the Microsoft repository GPG keys
wget -q https://packages.microsoft.com/config/ubuntu/18.04/packages-microsoft-prod.deb
# Register the Microsoft repository GPG keys
sudo dpkg -i packages-microsoft-prod.deb
# Update the list of products
sudo apt-get update
# Enable the "universe" repositories
sudo add-apt-repository universe
# Install PowerShell
sudo apt-get install -y powershell
# Start PowerShell via pwsh
# pwsh


# Install Ansible
sudo apt update
sudo apt install software-properties-common
sudo apt-add-repository --yes --update ppa:ansible/ansible
sudo apt install ansible

# Install Azure CLI
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
# create a service principle and perform az login

# Install DevOps Agent in the home directory of the adminuser
su - $@ -c 'wget https://vstsagentpackage.azureedge.net/agent/2.184.2/vsts-agent-linux-x64-2.184.2.tar.gz'
su - $@ -c 'mkdir devopsagent && cd devopsagent ; tar zxvf ~/vsts-agent-linux-x64-2.184.2.tar.gz'

echo "##################################################################################"
echo "#########   Complete the DevOps Deployment Agent Setup with 3 manual steps   #####"
echo "##################################################################################"
echo "To Do 1."
echo "DevOps Agent configuration, connection, install the service and start the deamon"
echo "./config.sh"
echo "sudo ./svc.sh install"
echo "sudo ./svc.sh start"
echo "##################################################################################"
echo "To Do 2."
echo "Create a service principle and login via az login"
echo "##################################################################################"
echo "To Do 3."
echo "put your private ssh-key in ~.ssh/id_rsa with 600 file permissions"
echo "##################################################################################"

exit
