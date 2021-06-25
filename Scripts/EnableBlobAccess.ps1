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

Write-Host "BlobId= WIP"
# $BlobId= /subscriptions/35b67b4c-4fd4-4f0b-997c-bbb82032d45d/resourceGroups/  RG  /providers/Microsoft.Storage/storageAccounts/ Storage Accnt /blobServices/default/containers/   container

Write-Host "az role assignment create --role "Storage Blob Data Reader"  --assignee $spID --scope $BlobId"
# az role assignment create --role "Storage Blob Data Reader"  --assignee $spID --scope $BlobId

Write-Host "Last exit code: $LASTEXITCODE"
