<#
.DESCRIPTION
    This script activates the Azure Monitoring Extension for SAP
    
.EXAMPLE
    Test the script:
    $VM="hanatestxsa"
    $VMRG="rg-HANA-XSA"

    ./Scripts/SAPonAzureMonitoringExtension.ps1 -VM $VM -VMRG $VMRG

.NOTES
    v0.1 - Initial version
#>

param(
    [Parameter(Mandatory = $true)][string]$VM,
    [Parameter(Mandatory = $true)][string]$VMRG
)

Write-Host "-----------------------------------------------------"
Write-Host "----Assign the Managed Identity access to the RG-----"

Write-Host "az vm identity assign -g $VMRG -n $VM"
az vm identity assign -g $VMRG -n $VM

Write-Host "spID=az resource show -g $VMRG -n $VM --query identity.principalId --out tsv --resource-type Microsoft.Compute/virtualMachines"
$spID=az resource show -g $VMRG -n $VM --query identity.principalId --out tsv --resource-type Microsoft.Compute/virtualMachines

Write-Host "rgId=az group show -g $VMRG --query id --out tsv"
$rgId=az group show -g $VMRG --query id --out tsv

Write-Host "az role assignment create --assignee $spID --role 'Reader' --scope $rgId"
az role assignment create --assignee $spID --role 'Reader' --scope $rgId

$EXT=az vm extension list -g $VMRG --vm-name $VM --query [].name --out tsv | grep MonitorX64Linux

if ([string]::IsNullOrEmpty($EXT)) {
    Write-Host "-------Install the Azure Extension for SAP-----------" 
    Write-Host "az vm extension set --publisher Microsoft.AzureCAT.AzureEnhancedMonitoring --name MonitorX64Linux --version 1.0 -g $VMRG --vm-name $VM --settings '{\"system\":\"SAP\"}'"
    az vm extension set --publisher Microsoft.AzureCAT.AzureEnhancedMonitoring --name MonitorX64Linux --version 1.0 -g $VMRG --vm-name $VM --settings '{\"system\":\"SAP\"}' 
    Write-Host "-----------------------------------------------------"
}
else {
    Write-Host ""
    Write-Host "------Azure Extension for SAP already installed------" 
    Write-Host ""
}

Write-Host "Last exit code: $LASTEXITCODE"
