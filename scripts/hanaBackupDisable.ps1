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

    ./hanaBackup.ps1 -RGV $RGV -RSV $RSV -VM $VM -VMRG $VMRG -POL $POL -ITEMSYS $ITEMSYS -ITEMTEN $ITEMTEN -CONTAINER $CONTAINER

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


# Get VM ID
# $VMID=az vm show -g $VMRG -n $VM --query id --output tsv

# Disable Backups
az backup protection disable --container-name $CONTAINER --delete-backup-data true --item-name $ITEMSYS -g $RGV -v $RSV --yes
az backup protection disable --container-name $CONTAINER --delete-backup-data true --item-name $ITEMTEN -g $RGV -v $RSV --yes

# Unregister Container
az backup container unregister -c $CONTAINER -g $RGV -v $RSV --backup-management-type AzureWorkload -yes

# List protectable items
az backup protectable-item  list --container-name $CONTAINER -g $RGV -v $RSV --workload-type SAPHANA --output tsv

