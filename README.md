# SAP HANA VM deployments using Azure Marketplace images

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fmimergel%2Fsap-hana-vm%2Fmain%2Fazuredeploy.json) 

This template takes a minimum amount of parameters and deploys a VM that is customized for use with SAP NetWeaver and HANA DB, using the latest patched version of the selected operating system. This is a template for a 2-tier configuration and it deploys 1 server on Premium Storage with Managed Disks. Filesystems are created via custom script. Where multiple disks are used for the filesystem the logical volume is setup with striping for optimal performance.

<table>
	<tr>
		<th>Size</th>
		<th>HANA VM</th>
		<th>HANA VM Storage (EXE + DATA + LOG + SHARE)</th>
	</tr>
	<tr>
		<th>Small</th>
		<td>M32ls (256GB)</td>
		<td>1xP6(64GB) + 4xP6(64GB) + 3xP10(128GB) + 1xP20(512GB)</td>
	</tr>
	<tr>
		<th>Medium</th>
		<td>M64ls (512GB)</td>
		<td>1xP6(64GB) + 4xP10(128GB) + 3xP10(128GB) + 1xP20(512GB)</td>
	</tr>
	<tr>
		<th>Large</th>
		<td>M64s (1TB)</td>
		<td>1xP6(64GB) + 4xP15(256GB) + 3xP15(256GB) + 1xP30(1TB)</td>
	</tr>
</table>


# Deployment via Azure DevOps
Steps:
1. Fork this repository 
2. Connect Azure DevOps with your forked repository (https://docs.microsoft.com/en-us/azure/devops/boards/github/connect-to-github?view=azure-devops)
3. Create a pipeline similar to the example in this repository (azure-pipelines.yml) by adapting to your Azure envrionment

# Deployments in an Azure environment without internet access 
There might be multiple solutions to handle this situation which is most common for SAP environments. 
The challenge here is that the deployed HANA VM has no access to Github to download the diskConfig.sh script. 
Furthermore you might want to keep the provided details like subscription and subnetId from the azuredeployparamfile.json file private. 
For me the following solution works fine.

1. Create your own deployment agent in Azure (https://docs.microsoft.com/en-us/azure/devops/pipelines/agents/agents)
2. Create a storage account with a private endpoint on selected networks (SAP subnets) in your Azure subscription
3. Create a container with read access in this storage account 
4. Upload the diskConfig.sh and the azuredeployparamfile.json files here
5. Get the URL and update the URL of diskConfig.sh in the file: azuredeploy.json of your forked repository
6. Update the parameters in azuredeployparamfile.json according to your needs and upload it to the storage container
7. Get the URL and use it in the parameter csmParametersFileLink of the Azure DevOps Pipeline

# Note
When this works as planned pay attention to changes of the GitHub repository and deployments! 
Whenever you change the Github repository an automatic deployment will create a SAP HANA VM on Azure which creates costs in your subscription.

