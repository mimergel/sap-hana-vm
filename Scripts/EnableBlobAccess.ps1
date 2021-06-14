<#
.DESCRIPTION
    This script activates Blob Container Access 
    
.EXAMPLE
    Test the script:
    $VM="hanatestxsa"
    $VMRG="rg-HANA-XSA"

    ./Scripts/EnableBlobAccess.ps1 -VM $VM -VMRG $VMRG

.NOTES
    v0.1 - Initial version
#>

param(
    [Parameter(Mandatory = $true)][string]$VM,
    [Parameter(Mandatory = $true)][string]$VMRG
)

Write-Host "-----------------------------------------------------"
Write-Host "--Allow the Managed Identity to access to the Blob---"

Write-Host "az vm identity assign -g $VMRG -n $VM"
az vm identity assign -g $VMRG -n $VM

Write-Host "spID=az resource show -g $VMRG -n $VM --query identity.principalId --out tsv --resource-type Microsoft.Compute/virtualMachines"
$spID=az resource show -g $VMRG -n $VM --query identity.principalId --out tsv --resource-type Microsoft.Compute/virtualMachines

Write-Host "BlobId=                    az group show -g $VMRG --query id --out tsv"
$BlobId=az group show -g $VMRG --query id --out tsv

Write-Host "az role assignment create --assignee $spID --role 'Reader' --scope $rgId"
az role assignment create --role "Storage Blob Data Reader"  --assignee $spID --scope

az role assignment create --assignee $spID --role 'Reader' --scope $rgId

exit 0