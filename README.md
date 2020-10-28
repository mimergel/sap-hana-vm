# SAP HANA VM deployments using Azure Marketplace images

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fmimergel%2Fsap-hana-vm%2Fmain%2Fazuredeploy.json) [![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fmimergel%2Fsap-hana-vm%2Fmain%2Fazuredeploy.json)

This template takes a minimum amount of parameters and deploys a VM that is customized for use with SAP NetWeaver with Oracle or HANA DB, using the latest patched version of the selected operating system. This is a template for a 2-tier configuration and it deploys 1 server on Premium Storage with Managed Disks.

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