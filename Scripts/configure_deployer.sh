#!/bin/bash

#
# configure_deployer.sh
#
# This script is intended to perform all the necessary initial
# setup of a node so that it can act as a deployer for use with
# Azure SAP Automated Deployment.
#
# As part of doing so it will:
#
#   * Installs the specifed version of terraform so that it
#     is available for all users.
#
#   * Installs the Azure CLI using the provided installer
#     script, making it available for all users.
#
#   * Create a Python virtualenv, which can be used by all
#     users, with the specified Ansible version and related
#     tools, and associated Python dependencies, installed.
#
#   * Create a /etc/profile.d file that will setup a users
#     interactive session appropriately to use these tools.
#
# This script does not modify the system's Python environment,
# instead using a Python virtualenv to host the installed Python
# packages, meaning that standard system updates can be safely
# installed.
#
# The script can be run again to re-install/update the required
# tools if needed. Note that doing so will re-generate the
# /etc/profile.d file, so any local changes will be lost.
#

#
# Setup some useful shell options
#
green="\e[1;32m" 
blue="\e[0;34m"
boldred="\e[1;31m"
reset="\e[0m"


#
# Terraform Version settings
#

if [ -z "${TF_VERSION}" ]; then
  TF_VERSION="1.0.11"
fi


# Fail if attempting to access and unset variable or parameter
set -o nounset

tfversion=$TF_VERSION

#
# Ansible Version settings
#
ansible_version="${ansible_version:-2.9}"
ansible_major="${ansible_version%%.*}"
ansible_minor=$(echo "${ansible_version}." | cut -d . -f 2)

#
# Utility Functions
#
distro_name=""
distro_version=""
distro_name_version=""
error()
{
    echo 1>&2 "ERROR: ${@}"
}

get_distro_name()
{
    typeset -g distro_name

    if [[ -z "${distro_name:-}" ]]; then
        distro_name="$(. /etc/os-release; echo "${ID,,}")"
    fi

    echo "${distro_name}"
}

get_distro_version()
{
    typeset -g distro_version

    if [[ -z "${distro_version:-}" ]]; then
        distro_version="$(. /etc/os-release; echo "${VERSION_ID,,}")"
    fi

    echo "${distro_version}"
}

get_distro_name_version()
{
    typeset -g distro_name_version

    if [[ -z "${distro_name_version:-}" ]]; then
        distro_name_version="$(get_distro_name)_$(get_distro_version)"
    fi

    echo "${distro_name_version}"
}

#
# Package Management Functions
#
pkg_mgr_init()
{
    typeset -g pkg_mgr

    case "$(get_distro_name)" in
    (ubuntu|debian)
        pkg_mgr="apt-get"
        pkg_type="deb"
        ;;
    (sles|opensuse*)
        pkg_mgr="zypper"
        pkg_type="rpm"
        ;;
    (*)
        error "Unsupported distibution: '${distro_name}'"
        exit 1
        ;;
    esac
}

pkg_mgr_refresh()
{
    typeset -g pkg_mgr pkg_mgr_refreshed

    if [[ -z "${pkg_mgr:-}" ]]; then
        pkg_mgr_init
    fi

    if [[ -n "${pkg_mgr_refreshed:-}" ]]; then
        return
    fi

    case "${pkg_mgr}" in
    (apt-get)
        sudo ${pkg_mgr} update --quiet
        ;;
    (zypper)
        sudo ${pkg_mgr} --gpg-auto-import-keys --quiet refresh 
        ;;
    esac

    pkg_mgr_refreshed=true
}


pkg_mgr_upgrade()
{
    typeset -g pkg_mgr pkg_mgr_upgraded

    if [[ -z "${pkg_mgr:-}" ]]; then
        pkg_mgr_init
    fi

    if [[ -n "${pkg_mgr_upgraded:-}" ]]; then
        return
    fi

    case "${pkg_mgr}" in
    (apt-get)
        sudo ${pkg_mgr} upgrade --quiet -y
        ;;
    (zypper)
        sudo ${pkg_mgr} --gpg-auto-import-keys --quiet upgrade 
        ;;
    esac

    pkg_mgr_upgraded=true
}

pkg_mgr_install()
{
    typeset -g pkg_mgr

    pkg_mgr_refresh

    case "${pkg_mgr}" in
    (apt-get)
        sudo env DEBIAN_FRONTEND=noninteractive ${pkg_mgr} --quiet --yes install "${@}"
        ;;
    (zypper)
        sudo ${pkg_mgr} --gpg-auto-import-keys --quiet --non-interactive install --no-confirm "${@}"
        ;;
    esac
}


#
# Directories and paths
#

# Ansible installation directories
ansible_base=/opt/ansible
ansible_bin=${ansible_base}/bin
ansible_venv=${ansible_base}/venv/${ansible_version}
ansible_venv_bin=${ansible_venv}/bin
ansible_collections=${ansible_base}/collections
ansible_pip3=${ansible_venv_bin}/pip3

# Terraform installation directories
tf_base=/opt/terraform
tf_dir=${tf_base}/terraform_${tfversion}
tf_bin=${tf_base}/bin
tf_zip=terraform_${tfversion}_linux_amd64.zip

#
# Main body of script
#

# Check for supported distro
case "$(get_distro_name_version)" in
(sles_12*)
    error "Unsupported distro: ${distro_name_version} doesn't provide virtualenv in standard repos."
    exit 1
    ;;
(ubuntu*|sles*)
    echo "${distro_name_version} is supported."
    ;;
(*)
    error "Unsupported distro: ${distro_name_version} not currently supported."
    exit 1
    ;;
esac

# List of required packages whose names are common to all supported distros
required_pkgs=(
    jq
    unzip
    ca-certificates
    curl
    apt-transport-https
    lsb-release
    gnupg
    sshpass
    dos2unix
)

cli_pkgs=(
    azure-cli
)

# Include distro version agnostic packages into required packages list
case "$(get_distro_name)" in
(ubuntu|sles)
    required_pkgs+=(
        python3-pip
        python3-virtualenv
    )
    ;;
esac

# Include distro version specific packages into required packages list
case "$(get_distro_name_version)" in
(ubuntu_18.04)
    required_pkgs+=(
        virtualenv
    )
    ;;
esac

# Ensure our package metadata cache is up to date
pkg_mgr_refresh

# Install required packages as determined above
pkg_mgr_install "${required_pkgs[@]}"


#
# Install terraform for all users
#
sudo mkdir -p \
    ${tf_dir} \
    ${tf_bin}
wget -nv -O /tmp/${tf_zip} https://releases.hashicorp.com/terraform/${tfversion}/${tf_zip}
sudo unzip -o /tmp/${tf_zip} -d ${tf_dir}
sudo ln -vfs ../$(basename ${tf_dir})/terraform ${tf_bin}/terraform

rel=$(lsb_release -a | grep Release | cut -d':' -f2 | xargs)
# Ubuntu 20.04 (Focal Fossa) and 20.10 (Groovy Gorilla) include an azure-cli package with version 2.0.81 provided by the universe repository. 
# This package is outdated and not recommended. If this package is installed, remove the package
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

# Ensure our package metadata cache is up to date
pkg_mgr_refresh

pkg_mgr_upgrade

#
# Install latest Ansible revision of specified version for all users.
#
sudo mkdir -p \
    ${ansible_bin} \
    ${ansible_collections}
    
# Create a Python3 based venv into which we will install Ansible.
if [[ ! -e "${ansible_venv_bin}/activate" ]]; then
    sudo rm -rf ${ansible_venv}
    sudo virtualenv --python python3 ${ansible_venv}
fi

# Fail if pip3 doesn't exist in the venv
if [[ ! -x "${ansible_venv_bin}/pip3" ]]; then
    echo "Using the wrong pip3: '${found_pip3}' != '${ansible_venv_bin}/pip3'"
    exit 1
fi

# Ensure that standard tools are up to date
sudo ${ansible_venv_bin}/pip3 install --upgrade \
    pip \
    wheel \
    setuptools

# Install latest MicroSoft Authentication Library
# TODO(rtamalin): Do we need this? In particular do we expect to integrated
# Rust based tools with the Python/Ansible envs that we are using?
sudo ${ansible_venv_bin}/pip3 install \
    setuptools-rust

# Install latest revision of target Ansible version, along with additional
# useful/supporting Python packages such as ansible-lint, yamllint,
# argcomplete, pywinrm.
sudo ${ansible_venv_bin}/pip3 install \
    "ansible>=${ansible_major}.${ansible_minor},<${ansible_major}.$((ansible_minor + 1))" \
    ansible-lint \
    argcomplete \
    'pywinrm>=0.3.0' \
    yamllint \
    msal

# Create symlinks for all relevant commands that were installed in the Ansible
# venv's bin so that they are available in the /opt/ansible/bin directory, which
# will be added to the system PATH. This ensures that we expose only those tools
# that we need from the Ansible venv bin directory without superceding standard
# system versions of the commands that are also found there, e.g. python3.
ansible_venv_commands=(
    # Ansible 2.9 command set
    ansible
    ansible-config
    ansible-connection
    ansible-console
    ansible-doc
    ansible-galaxy
    ansible-inventory
    ansible-playbook
    ansible-pull
    ansible-test
    ansible-vault

    # ansible-lint
    ansible-lint

    # argcomplete
    activate-global-python-argcomplete

    # yamllint
    yamllint
)

relative_path="$(realpath --relative-to ${ansible_bin} ${ansible_venv_bin})"
for vcmd in "${ansible_venv_commands[@]}"
do
    sudo ln -vfs ${relative_path}/${vcmd} ${ansible_bin}/${vcmd}
done

# Ensure that Python argcomplete is enabled for all users interactive shell sessions
sudo ${ansible_bin}/activate-global-python-argcomplete


# Install Ansible collections under the ANSIBLE_COLLECTIONS_PATHS for all users.
sudo mkdir -p ${ansible_collections}
sudo -H ${ansible_venv_bin}/ansible-galaxy collection install azure.azcollection --force --collections-path ${ansible_collections}

# Install the Python requirements associated with the Ansible Azure collection
# that was just installed into the Ansible venv.
azure_azcollection_version=$(jq -r '.collection_info.version' ${ansible_collections}/ansible_collections/azure/azcollection/MANIFEST.json)
wget -nv -O /tmp/requirements-azure.txt https://raw.githubusercontent.com/ansible-collections/azure/v${azure_azcollection_version}/requirements-azure.txt  || :
if [ -f /tmp/requirements-azure.txt ]; then
  sudo ${ansible_venv_bin}/pip3 install  -r /tmp/requirements-azure.txt 
fi

curl -H Metadata:true --noproxy "*" "http://169.254.169.254/metadata/instance?api-version=2021-02-01" -s | jq . > vm.json

rg_name=$(jq --raw-output .compute.resourceGroupName vm.json )
subscription_id=$(jq --raw-output .compute.subscriptionId vm.json)

rm vm.json


# Install DevOps Agent in the home directory of the adminuser
su - $@ -c 'wget https://vstsagentpackage.azureedge.net/agent/2.198.3/vsts-agent-linux-x64-2.198.3.tar.gz'
su - $@ -c 'mkdir devopsagent && cd devopsagent ; tar zxvf ~/vsts-agent-linux-x64-2.198.3.tar.gz'

# Clone some scripts
git clone https://github.com/Azure/SAP-on-Azure-Scripts-and-Utilities.git

echo "$blue ##################################################################################"
echo "$blue #########   Complete the DevOps Deployment Agent Setup with 2 manual steps   #####"
echo "$blue ##################################################################################"
echo "$blue 1."
echo "$blue DevOps Agent configuration, connection, install the service and start the deamon"
echo "$blue Before running the config.sh script get a PAT: personal access token from'      "
echo "$blue Azure DevOps to enable the connection                                           "
echo "$blue ./config.sh        $red  not as root!!! "
echo "$blue sudo ./svc.sh install"
echo "$blue sudo ./svc.sh start"
echo "$blue ##################################################################################"
echo "$blue To Do 2."
echo "$blue put your private ssh-key in ~.ssh/id_rsa with 600 file permissions"
echo "$blue ##################################################################################"


exit 0