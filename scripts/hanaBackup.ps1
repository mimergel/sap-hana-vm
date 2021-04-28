<#
.SYNOPSIS
    This script activates the SAP HANA Backups
.DESCRIPTION
	This script activates the SAP HANA Backups by registering the SAP HANA Instance, 
    enable protection and finally running the backups for the systemdb and tenant db.
	The script requires as prerequesite a successfully finished pre-registration script from here:
.EXAMPLE
	./hanaBackup.ps1 -SubscriptionName "Azure Subscription Name" `
	-ResourceGroupNameVault SAP01 `
	-RecoveryServiceVault SAP02 `
	-VirtualMachineName sapdemo01 `
	-VirtualMachineNameRG sapdemo02 `
.LINKs
    https://docs.microsoft.com/en-us/azure/backup/tutorial-sap-hana-backup-cli
	https://docs.microsoft.com/en-us/azure/backup/backup-azure-sap-hana-database 
.NOTES
    v0.1 - Initial version

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
$VMID=az vm show -g $VMRG -n $VM --query id --output tsv
# Discovery
az backup protectable-item initialize --container-name $CONTAINER -g $RGV -v $RSV --workload-type SAPHANA
# Register
az backup container register -g $RGV -v $RSV --backup-management-type AzureWorkload --workload-type SAPHANA --resource-id $VMID
# List protectable items
az backup protectable-item  list --container-name $CONTAINER -g $RGV -v $RSV --workload-type SAPHANA --output tsv
# Enable Backups
az backup protection enable-for-azurewl -g $RGV -v $RSV --policy-name $POL --protectable-item-name $ITEMSYS --protectable-item-type SAPHANADatabase --server-name $VM --workload-type SAPHANA
az backup protection enable-for-azurewl -g $RGV -v $RSV --policy-name $POL --protectable-item-name $ITEMTEN --protectable-item-type SAPHANADatabase --server-name $VM --workload-type SAPHANA
# Run Backups
az backup protection backup-now -g $RGV -v $RSV --item-name $ITEMSYS --container-name $CONTAINER --backup-type full
az backup protection backup-now -g $RGV -v $RSV --item-name $ITEMTEN --container-name $CONTAINER --backup-type full
