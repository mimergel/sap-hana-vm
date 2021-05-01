# SAP HANA VM deployments using Azure Marketplace Images
This Repository can be used with Azure DevOps to deploy a SAP HANA DB 2.0 with the following features:

	* SLES 12 & 15
	* RHEL 7 & 8 
	* VM sizes from 128GB to 12TB
	* Preparation of the OS with required patches and configurations according to relevant SAP notes
	* HANA 2.0 DB Installation 
	* Backup Integration into an Azure Recovery Service Vault including execution of initial backups
	* Execution of HANA Clound Measurement Tool (HCMT)
	* Removal of the complete deployment 

Note: Eds_v4 Series use premium disk without write accellerations, therefore this is recommended for Non-PRD envrionments only

# VM Sizes and Storage Configurations
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

# Prerequesites
1. Azure Subscription 
2. Azure DevOps and Github account
3. S-User for SAP Software Downloads
4. Basic Resources
	- VNET + Subnet
	- Recovery Service Vault (For OS + DB Backups)
	- Storage Account (For SAP binaries and Scripts)
	- Private DNS Zone (Makes everything easier)
5. Linux VM as deployment agent within the same or peered VNET 
   See: https://docs.microsoft.com/en-us/azure/devops/pipelines/agents/v2-linux?view=azure-devops 
	- Install ansible & pwsh 
	- Set Parameter allow_world_readable_tmpfiles = True in /etc/ansible/ansible.cfg

# Deployment via Azure DevOps
Steps:
1. Fork this repository in Github or create your own new Repository based on this template
2. Connect your Github Repository with Azure DevOps (https://docs.microsoft.com/en-us/azure/devops/boards/github/connect-to-github?view=azure-devops)
3. Create a pipeline similar in DevOps based on the example azure-pipelines.yml, choose manual trigger as a start
4. Enter your required variables to the pipeline configuration
5. Download sapbits and store in storage account, update urls in vars/default.yml

# Deployments into a SAP landing zone where the target VNETs/subnets cannot access the internet 
In this typical situation downloads from github or SAP won't work. Therefore the following files need to be placed into a storage container that is reachable from the SAP subnets. 
Files: IMDB_SERVER*, HCMT*, SAPCAR, diskConfig.sh and msawb-plugin-config-com-sap-hana.sh

1. Create a storage account with a private endpoint on relevant subnets in your Azure subscription
2. Create a container with read access in this storage account 
3. Upload the files into the container
4. Get the URLs update the links in Ansible/vars/defaults.yml. The URL to diskConfig.sh must be adapted in the ARM-Template/azuredeploy.json.
5. Adapt the csmFileLink variable in the DevOpsPipeline/azure-pipeline.yml to point to the ARM template location of your git repo. 
