# SAP HANA VM deployments using Azure Marketplace Images
This Repository can be used with Azure DevOps to deploy a SAP HANA DB 2.0 with the following features:

* SLES 12 & 15
* RHEL 7 & 8 
* VM sizes from 128GB to 12TB
* OS Preparation with required patches and configurations according to relevant SAP notes
* HANA 2.0 DB Installation 
* Backup Integration into an Azure Recovery Service Vault including execution of initial backups
* Execution of HANA Clound Measurement Tool (HCMT)
* Removal of the complete deployment 

Note: Eds_v4 Series use premium disk without write accellerations, therefore this is recommended for Non-PRD envrionments only

## VM Sizes and Storage Configurations
<table>
	<tr>
		<th>Size</th>
		<th>HANA VM</th>
		<th>HANA VM Storage (EXE + DATA + LOG + SHARE + BACKUP)</th>
	</tr>
	<tr>
		<th>128_GB</th>
		<td>E16ds_v4</td>
		<td>1xP6(64GB) + 3xP6(64GB) + 3xP10(128GB) + 1xP20(512GB) + 1xP20(512GB)</td>
	</tr>
	<tr>
		<th>160_GB</th>
		<td>E20ds_v4</td>
		<td>1xP6(64GB) + 4xP6(64GB) + 3xP10(128GB) + 1xP20(512GB) + 1xP20(512GB)</td>
	</tr>
	<tr>
		<th>192_GB</th>
		<td>M32ts</td>
		<td>1xP6(64GB) + 4xP6(64GB) + 3xP10(128GB) + 1xP20(512GB) + 1xP20(512GB)</td>
	</tr>
	<tr>
		<th>256_GB</th>
		<td>M32ls</td>
		<td>1xP6(64GB) + 4xP6(64GB) + 3xP10(128GB) + 1xP20(512GB) + 1xP20(512GB)</td>
	</tr>
	<tr>
		<th>512_GB</th>
		<td>M64ls</td>
		<td>1xP6(64GB) + 4xP10(128GB) + 3xP10(128GB) + 1xP20(512GB) + 1xP20(512GB)</td>
	</tr>
	<tr>
		<th>1.000_GB</th>
		<td>M64s</td>
		<td>1xP6(64GB) + 4xP15(256GB) + 3xP15(256GB) + 1xP30(1TB) + 1xP30(1TB)</td>
	</tr>
	<tr>
		<th>1.792_GB</th>
		<td>M64ms</td>
		<td>1xP6(64GB) + 4xP20(512GB) + 3xP15(256GB) + 1xP30(1TB) + 1xP30(1TB)</td>
	</tr>
	<tr>
		<th>2.000_GB</th>
		<td>M128s</td>
		<td>1xP10(128GB) + 4xP20(512GB) + 3xP15(256GB) + 1xP30(1TB) + 1xP30(1TB)</td>
	</tr>
	<tr>
		<th>2.850_GB</th>
		<td>M208sv2</td>
		<td>1xP10(128GB) + 4xP30(1024GB) + 3xP15(256GB) + 1xP30(1TB) + 1xP30(1TB)</td>
	</tr>
	<tr>
		<th>3.892_GB</th>
		<td>M128ms</td>
		<td>1xP10(128GB) + 5xP30(1024GB) + 3xP15(256GB) + 1xP30(1TB) + 1xP30(1TB)</td>
	</tr>
	<tr>
		<th>5.700_GB</th>
		<td>M416sv2</td>
		<td>1xP10(128GB) + 4xP40(2048GB) + 3xP15(256GB) + 1xP30(1TB) + 1xP30(1TB)</td>
	</tr>
	<tr>
		<th>11.400_GB</th>
		<td>M416msv2</td>
		<td>1xP10(128GB) + 4xP50(4096GB) + 3xP15(256GB) + 1xP30(1TB) + 1xP30(1TB)</td>
	</tr>
</table>


## Prerequesites
1. [Azure Subscription](https://portal.azure.com/) 
2. [Azure DevOps](http://dev.azure.com/) and [Github](http://github.com/) account 
3. S-User for SAP [Software Downloads](https://launchpad.support.sap.com/)
4. Basic Resources
	* VNET + Subnet
	* Recovery Service Vault with 2 Policies named "HANA-Non-PRD" and "HANA-PRD"
	* Storage Account (For SAP binaries, Scripts & Boot Diagnostics)
	* Private DNS Zone (Makes everything easier)
	* For green field deployments and especially production workloads please consider using the [Microsoft Cloud Adoption Framework for SAP on Azure](https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/scenarios/sap/enterprise-scale-landing-zone)
5. Setup your own DevOps Deployment Agent within the same or peered VNET 
    * Deploy an Ubuntu 18.04 VM
	* Install [PowerShell](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-core-on-linux?view=powershell-7.1#ubuntu-1804)
	* Install [Ansible 2.10.*](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html#installing-ansible-on-ubuntu)
	* Setup an [Azure DevOps Deployment Agent](https://docs.microsoft.com/en-us/azure/devops/pipelines/agents/v2-linux?view=azure-devops) in your landing zone
		* Use this [tested agent version 2.184.2](https://vstsagentpackage.azureedge.net/agent/2.184.2/vsts-agent-linux-x64-2.184.2.tar.gz) as the latest version doesn't handel SLES 15 SP2 correctly
	* Add your private ssh key to the os user on the agent (.ssh/id_rsa)
	* Install Azure CLI: `curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash` and perform `az login --use-device-code`. Preferable for a permanent login [create a service principle](https://docs.microsoft.com/en-us/cli/azure/authenticate-azure-cli#sign-in-with-a-service-principal)


## Deployment via Azure DevOps
1. Fork this repository in Github or create your own new Repository based on this template
2. Create a Project in Azure DevOps
3. In the DevOps Pipeline Area
	* Create a "New Pipeline" 
	* Where is your code? => "GitHub" 
	* Select a repository => "<git-user>/sap-hana-vm" 
	* Configure your pipeline => "Existing Azure Pipeline YAML file"
	* Branch "Main" 
	* Path "/DevOpsPipeline/azure-pipelines.yml" 
	* Continue and Click on the right side of the Run button to "Save" 
	* Optionally change the name in the Pipeline overview
	* In the process you will need to connect your Github Repository with Azure DevOps [details here](https://docs.microsoft.com/en-us/azure/devops/boards/github/connect-to-github?view=azure-devops)
4. Enter your required variables to the pipeline configuration, [example here](./Documentation/Images/variables.jpg)
5. Add the [Ansible Extension](https://marketplace.visualstudio.com/items?itemName=ms-vscs-rm.vss-services-ansible) to your DevOps Project
6. Download the SAP Binaries IMDB_SERVER*, HCMT* & SAPCAR* and store them in a storage container. Get the new URLs from for the files and update the variables `url_sapcar`, `url_hdbserver`, `url_hcmt` in `Ansible/vars/defaults.yml` 
7. Place [diskConfig.sh](https://raw.githubusercontent.com/mimergel/sap-hana-vm/main/Scripts/diskConfig.sh) in the container and adapt variables `url-disk-cfg` in the Pipeline
8. Upload [msawb-plugin-config-com-sap-hana.sh](https://aka.ms/ScriptForPermsOnHANA?clcid=0x0409) to the container and adapt variable `url_msawb_plugin` in `Ansible/vars/defaults.yml` 
9. Adapt Target Subnet parameter, section: `- name: vnet_subnet` in the pipeline to match your landing zone target
10. Setup the [Service Connection to Azure](https://docs.microsoft.com/en-us/azure/devops/pipelines/library/connect-to-azure)
11. Run the pipeline


### Todo in future releases
* selective disk backup (exclude HANA Data and LOG from OS Backups) 
* Include Quality Checks when available for SSH login
* Optionally setup basic resources (VNET, Subnet, RSV, Storage Account, DNS, ...)
* Check OS NW Settings: https://launchpad.support.sap.com/#/notes/2382421
* SAP Monitoring Agent
* automatic deployment of the agent
