#!/bin/bash

# Install Powershell and other Tools

# Update the list of packages
sudo apt-get update
# Install pre-requisite packages.
sudo apt-get install -y wget apt-transport-https software-properties-common
# Download the Microsoft repository GPG keys
wget -q https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb
# Register the Microsoft repository GPG keys
sudo dpkg -i packages-microsoft-prod.deb
# Update the list of packages after we added packages.microsoft.com
sudo apt-get update
# Install PowerShell
sudo apt-get install -y powershell
# Start PowerShell
# pwsh

# Install az cli using provided scripting
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash > /dev/null 2>&1
/usr/bin/az extension add --name storage-blob-preview > /dev/null 2>&1
/usr/bin/az extension add --name azure-devops > /dev/null 2>&1

# Install some modules which are required for quality checks
/usr/bin/pwsh -c "Install-Module Az -Force" > /dev/null 2>&1
/usr/bin/pwsh -c "Install-Module Az.NetAppFiles -Force" > /dev/null 2>&1
/usr/bin/pwsh -c "Install-Module Posh-SSH -Force" > /dev/null 2>&1

# Installations
sudo apt update 
sudo apt install jq -y
sudo apt install unzip -y
sudo apt install ca-certificates -y
sudo apt install curl -y
sudo apt install apt-transport-https -y
sudo apt install lsb-release -y
sudo apt install gnupg -y
sudo apt install sshpass -y
sudo apt install dos2unix -y
sudo apt install python3-pip -y 
sudo apt install expect -y

# Install Ansible
sudo apt update -y
sudo apt install -y software-properties-common
sudo apt-add-repository --yes --update ppa:ansible/ansible
# sudo apt install -y ansible
sudo pip install ansible==2.9.27

# Install terraform
# https://www.terraform.io/cli/install/apt
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=$(dpkg --print-architecture)] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt install terraform -y

# Some Ansible settings
if [ -e /etc/ansible/ansible.cfg  ]
then
  sed -i 's/#host_key_checking = True/host_key_checking = False/g' /etc/ansible/ansible.cfg 
  sed -i 's/#allow_world_readable_tmpfiles = False/allow_world_readable_tmpfiles = True/g' /etc/ansible/ansible.cfg 
else
  mkdir -p /etc/ansible
  echo "[defaults]"                            >  /etc/ansible/ansible.cfg 
  echo "host_key_checking = False"             >> /etc/ansible/ansible.cfg 
  echo "allow_world_readable_tmpfiles = True"  >> /etc/ansible/ansible.cfg 
fi

# Ubuntu 20.04 (Focal Fossa) and 20.10 (Groovy Gorilla) include an azure-cli package with version 2.0.81 provided by the universe repository. 
# This package is outdated and not recommended. If this package is installed, remove the package
rel=$(lsb_release -a | grep Release | cut -d':' -f2 | xargs)

if [ "$rel" == "20.04" ]; then
  if [ ! -f /etc/az_removed ]; then
    echo "Removing Azure CLI"
    sudo apt remove azure-cli -y 
    sudo apt autoremove -y
    sudo apt update -y
    sudo touch /etc/az_removed
  fi
fi
#
# Install az cli using provided scripting
#
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash > /dev/null
/usr/bin/az extension add --name storage-blob-preview > /dev/null
# create a service principle and perform az login

# Install DevOps Agent in the home directory of the adminuser
su - $@ -c 'wget https://vstsagentpackage.azureedge.net/agent/2.198.3/vsts-agent-linux-x64-2.198.3.tar.gz'
su - $@ -c 'mkdir devopsagent && cd devopsagent ; tar zxvf ~/vsts-agent-linux-x64-2.198.3.tar.gz'

# Clone some scripts
su - $@ -c 'git clone -q https://github.com/Azure/SAP-on-Azure-Scripts-and-Utilities.git > /dev/null 2>&1'

echo "##################################################################################"
echo "#########   Complete the DevOps Deployment Agent Setup with 2 manual steps   #####"
echo "##################################################################################"
echo "To Do 1."
echo "DevOps Agent configuration, connection, install the service and start the deamon  "
echo "Before running the config.sh script get a PAT: personal access token from'        "
echo "Azure DevOps to enable the connection                                             "
echo "as user $@  and NOT as root !                                                     "
echo "./config.sh                                                                       "
echo "sudo ./svc.sh install                                                             "
echo "sudo ./svc.sh start                                                               "
echo "##################################################################################"
echo "To Do 2.                                                                          "
echo "put your private ssh-key in ~.ssh/id_rsa with 600 file permissions                "
echo "##################################################################################"

exit 0