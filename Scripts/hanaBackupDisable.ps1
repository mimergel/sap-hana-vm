<#
.SYNOPSIS
    This script disables the SAP HANA Backups
.DESCRIPTION
	This script disables the SAP HANA Backups including all required cleanup activities
.EXAMPLE
    Test the script:
    $RGV="HANABackups"
    $RSV="hanabackupvault"
    $VM="hanatest06"
    $VMRG="rg-HANA-MM6"
    $POL="HANA-Non-PRD"
    $ITEMSYS="saphanadatabase;mm6;systemdb"
    $ITEMTEN="saphanadatabase;mm6;mm6"
    $CONTAINER="VMAppContainer;Compute;$VMRG;$VM"

    ./Scripts/hanaBackupDisable.ps1 -RGV $RGV -RSV $RSV -VM $VM -VMRG $VMRG -POL $POL -ITEMSYS $ITEMSYS -ITEMTEN $ITEMTEN -CONTAINER $CONTAINER

    some helpful commands:
    az backup protectable-item list -g HANABackups -v hanabackupvault --workload-type SAPHANA  --output table
    az backup container list -g HANABackups -v hanabackupvault --backup-management-type AzureIaasVM --output tsv
    az backup container list -g HANABackups -v hanabackupvault --backup-management-type AzureWorkload  --output tsv
.LINKs
    https://docs.microsoft.com/en-us/azure/backup/tutorial-sap-hana-backup-cli
	https://docs.microsoft.com/en-us/azure/backup/backup-azure-sap-hana-database 
.NOTES
    v0.1 - Initial version
#>

param(
    [Parameter(Mandatory = $true)][string]$RGV, 
    [Parameter(Mandatory = $true)][string]$RSV,
    [Parameter(Mandatory = $true)][string]$VM,
    [Parameter(Mandatory = $true)][string]$VMRG,
    [Parameter(Mandatory = $true)][string]$POL,
    [Parameter(Mandatory = $true)][string]$ITEMSYS,
    [Parameter(Mandatory = $true)][string]$ITEMTEN,
    [Parameter(Mandatory = $true)][string]$CONTAINER
)

Write-Host "-----------------------------------------------------"
Write-Host "----------Remove only an existing container----------" -ForegroundColor DarkBlue
Write-Host "az backup protectable-item  list -c '$CONTAINER' -g $RGV -v $RSV --workload-type SAPHANA --output tsv" -ForegroundColor DarkGreen
$PROTECT=az backup protectable-item  list -c "$CONTAINER" -g $RGV -v $RSV --workload-type SAPHANA --output tsv
if([string]::IsNullOrEmpty($PROTECT)){
   Write-Host "----------------No Container for disabling-----------" -ForegroundColor DarkGree
}else {
   Write-Host "-------------Container will be disabled--------------" -ForegroundColor DarkGree
   Write-Host "az backup protection disable -c '$CONTAINER' --delete-backup-data true --item-name '$ITEMSYS' -g $RGV -v $RSV --yes" -ForegroundColor DarkGreen
   az backup protection disable -c "$CONTAINER" --delete-backup-data true --item-name "$ITEMSYS" -g $RGV -v $RSV --yes
}
Write-Host "-----------------------------------------------------"
Write-Host ""

Write-Host "-----------------------------------------------------" -ForegroundColor DarkBlue
Write-Host "-----------------Disable Backups---------------------" -ForegroundColor DarkBlue
Write-Host "az backup protection disable -c '$CONTAINER' --delete-backup-data true --item-name '$ITEMSYS' -g $RGV -v $RSV --yes" -ForegroundColor DarkGreen
az backup protection disable -c "$CONTAINER" --delete-backup-data true --item-name "$ITEMSYS" -g $RGV -v $RSV --yes
Write-Host ""

Write-Host "az backup protection disable -c '$CONTAINER' --delete-backup-data true --item-name '$ITEMTEN' -g $RGV -v $RSV --yes" -ForegroundColor DarkGreen
az backup protection disable -c "$CONTAINER" --delete-backup-data true --item-name "$ITEMTEN" -g $RGV -v $RSV --yes
Write-Host "-----------------------------------------------------" -ForegroundColor DarkBlue
Write-Host ""

Write-Host "-----------------------------------------------------" -ForegroundColor DarkBlue
Write-Host "----------------Unregister Container-----------------" -ForegroundColor DarkBlue
Write-Host "az backup container unregister -c '$CONTAINER' -g $RGV -v $RSV --backup-management-type AzureWorkload --yes" -ForegroundColor DarkGreen
az backup container unregister -c "$CONTAINER" -g $RGV -v $RSV --backup-management-type AzureWorkload --yes
Write-Host "-----------------------------------------------------" -ForegroundColor DarkBlue
Write-Host ""

Write-Host "-----------------------------------------------------" -ForegroundColor DarkBlue
Write-Host "---------------List protectable items----------------" -ForegroundColor DarkBlue
Write-Host "az backup protectable-item  list -c '$CONTAINER' -g $RGV -v $RSV --workload-type SAPHANA --output tsv" -ForegroundColor DarkGreen
az backup protectable-item  list -c "$CONTAINER" -g $RGV -v $RSV --workload-type SAPHANA --output tsv
Write-Host "-----------------------------------------------------" -ForegroundColor DarkBlue
Write-Host ""
