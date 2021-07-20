#!/bin/bash

# Install Powershell and other Tools

# Update the list of packages
sudo apt-get update -y
# Install pre-requisite packages.
sudo apt-get install -y wget apt-transport-https software-properties-common
# Download the Microsoft repository GPG keys
wget -q https://packages.microsoft.com/config/ubuntu/18.04/packages-microsoft-prod.deb
# Register the Microsoft repository GPG keys
sudo dpkg -i packages-microsoft-prod.deb
# Update the list of products
sudo apt-get update -y
# Enable the "universe" repositories
sudo add-apt-repository universe
# Install PowerShell
sudo apt-get install -y powershell

# Install unzip
sudo apt install unzip -y

# Install command-line JSON processor
sudo apt install jq -y

# Install terraform
wget https://releases.hashicorp.com/terraform/0.15.5/terraform_0.15.5_linux_amd64.zip
unzip terraform_0.15.5_linux_amd64.zip
sudo mv terraform /bin/

# Install Ansible
sudo apt update -y
sudo apt install -y software-properties-common
sudo apt-add-repository --yes --update ppa:ansible/ansible
sudo apt install -y ansible

# This Ansible setting is required to prevent ssh prompts during first logins
# host_key_checking = False
sed -i 's/#host_key_checking = False/host_key_checking = False/g' /etc/ansible/ansible.cfg

# This Ansible setting is required to prevent the error
# Failed to set permissions on the temporary files Ansible needs to create when becoming an unprivileged user
# allow_world_readable_tmpfiles = True
sed -i 's/#allow_world_readable_tmpfiles = False/allow_world_readable_tmpfiles = True/g' /etc/ansible/ansible.cfg 

# Install Azure CLI
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
# create a service principle and perform az login

# Download Github Repos
mkdir ~/Azure_SAP_Automated_Deployment; cd $_
git clone https://github.com/Azure/sap-hana.git
git clone https://github.com/mimergel/sap-hana-vm.git

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
echo "Create a service principle or login via az login"
echo "##################################################################################"
echo "To Do 3."
echo "put your private ssh-key in ~.ssh/id_rsa with 600 file permissions"
echo "##################################################################################"

exit
