<#
.SYNOPSIS
    This script excludes HANA Data and Log related disks from the OS Backup
.DESCRIPTION
    The scripts searchs Luns based on naming '*data*' or '*log*' and will then exclude the luns from the OS backup
.EXAMPLE
    Test the script:
    $RGV="HANABackups"
    $RSV="hanabackupvault"
    $VM="hanatest06"
    $VMRG="rg-HANA-MM6"
    $POL="HANA-Non-PRD"
    $ITEMSYS="saphanadatabase;mm6;systemdb"
    $ITEMTEN="saphanadatabase;mm6;mm6"
    $CONTAINER="IaasVMContainer;iaasvmcontainerv2;$VMRG;$VM"

    ./selectivediskbackup.ps1 -RGV $RGV -RSV $RSV -VM $VM -VMRG $VMRG -POL $POL -CONTAINER $CONTAINER

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

$VMID = ""

Write-Host "-----------------------------------------------------"
Write-Host "-----------Get VM ID---------------------------------" 
Write-Host "VMID=az vm show -g $VMRG -n $VM --query id --output tsv" 
$VMID=az vm show -g $VMRG -n $VM --query id --output tsv
Write-Host "$VMID" 
Write-Host "-----------------------------------------------------"
Write-Host ""

Write-Host "-----------------------------------------------------"
Write-Host "---------------Select Luns for exclusion-------------"

Write-Host "-----------------------------------------------------"
Write-Host ""

Write-Host "-----------------------------------------------------"
Write-Host "---------------Exclude relevant LUNs-----------------"
Write-Host "az backup protection update-for-vm --resource-group $RGV --vault-name $RSV -c '$CONTAINER' -i $VM --disk-list-setting exclude --diskslist $LUNS"
az backup protection update-for-vm --resource-group $RGV --vault-name $RSV -c $CONTAINER -i $VM --disk-list-setting exclude --diskslist $LUNS
Write-Host "-----------------------------------------------------"
Write-Host ""

