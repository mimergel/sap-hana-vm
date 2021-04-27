# SAP HANA VM deployments using Azure Marketplace Images

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fmimergel%2Fsap-hana-vm%2Fmain%2Fazuredeploy.json) 

The "Deploy to Azure" button deploys the VM and handles the disks setup. For the full functionality including HANA DB installation, Backup Integration and Performance Testing an Azure DevOps Pipeline can be used.

This template takes a minimum amount of parameters and deploys an Azure VM that is customized for use with SAP HANA DB, using the latest patched version of the selected operating system. 
The template deploys the chosen VM size with the recommended Premium Managed Disks configuration. 
Filesystems are created via a custom script and will use logical volumes with striping wherevery multiple disks are used. 

Options: 
	- The DB can be integrated into an Azure Recovery Service Vault including OS and HANA Backup Setup for different Policies (PRD or Non-PRD).
	- Hana Performance Checks (HCMT) can be triggered.
	- The whole deployment can be removed at the end.


Eds_v4 Series use premium disk without write accellerations, therefore this is recommended for Non-PRD envrionments only.

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
		<td>1xP6(64GB) + 4xP15(256GB) + 3xP15(256GB) + 1xP30(1TB) + 1xP30(1024GB)</td>
	</tr>
	<tr>
		<th>1.792_GB</th>
		<td>M64ms</td>
		<td>1xP6(64GB) + 4xP20(512GB) + 3xP15(256GB) + 1xP30(1TB) + 1xP30(1024GB)</td>
	</tr>
	<tr>
		<th>2.000_GB</th>
		<td>M128s</td>
		<td>1xP10(128GB) + 4xP20(512GB) + 3xP15(256GB) + 1xP30(1TB) + 1xP30(1024GB)</td>
	</tr>
	<tr>
		<th>2.850_GB</th>
		<td>M208sv2</td>
		<td>1xP10(128GB) + 4xP30(1024GB) + 3xP15(256GB) + 1xP30(1TB) + 1xP30(1024GB)</td>
	</tr>
	<tr>
		<th>3.892_GB</th>
		<td>M128ms</td>
		<td>1xP10(128GB) + 5xP30(1024GB) + 3xP15(256GB) + 1xP30(1TB) + 1xP30(1024GB) + 1xP30(1024GB)</td>
	</tr>
	<tr>
		<th>5.700_GB</th>
		<td>M416sv2</td>
		<td>1xP10(128GB) + 4xP40(2048GB) + 3xP15(256GB) + 1xP30(1TB) + 1xP30(1024GB)</td>
	</tr>
	<tr>
		<th>11.400_GB</th>
		<td>M416msv2</td>
		<td>1xP10(128GB) + 4xP50(4096GB) + 3xP15(256GB) + 1xP30(1TB) + 1xP30(1024GB)</td>
	</tr>
</table>

# Prerequesites
1. Azure Subscription 
2. Azure DevOps and Github account
3. Basic Resources
	- VNET + Subnet
	- KeyVault (For OS ssh key and DB password)
	- Recovery Service Vault (For OS + DB Backups)
	- Storage Account (For SAP binaries and Scripts)
	- Private DNS Zone (Makes everything easier)
4. Linux VM as deployment agent within the same or peered VNET 
   See: https://docs.microsoft.com/en-us/azure/devops/pipelines/agents/v2-linux?view=azure-devops 
   ansible & pwsh installed

# Deployment via Azure DevOps
Steps:
1. Fork this repository 
2. Connect Azure DevOps with your forked repository (https://docs.microsoft.com/en-us/azure/devops/boards/github/connect-to-github?view=azure-devops)
3. Create a pipeline similar to the example in this repository (azure-pipelines.yml) by adapting to your Azure envrionment
4. Enter required variables to the pipeline configuration
5. Download sapbits and store in storage account, update urls in vars/default.yml

# Deployments into a SAP landing zone where the target VNETs/subnets cannot access the internet 
In this typical situation downloads from github or SAP won't work. Therefore the following files need to be placed into a storage container that is reachable from the SAP subnets. 
Files: IMDB_SERVER*, HCMT*, SAPCAR, diskConfig.sh and msawb-plugin-config-com-sap-hana.sh

1. Create a storage account with a private endpoint on relevant subnets in your Azure subscription
2. Create a container with read access in this storage account 
3. Upload the files into the container
4. Get the URLs update the links in vars/defaults.yml. The URL to diskConfig.sh must be adapted in the azuredeploy.json.
5. Preferable let the pipeline only run manually to avoid automatic deployments during every repository change
