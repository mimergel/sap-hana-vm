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

$RGV=HANABackups
$RSV=hanabackupvault
$VM=hanatest06
$VMRG=rg-HANA-MM6
$POL=Non-PRD
$ITEMSYS=saphanadatabase;mm6;systemdb
$ITEMTEN=saphanadatabase;mm6;mm6
$CONTAINER=VMAppContainer;Compute;$VMRG;$VM

# IaasVMContainer;iaasvmcontainerv2;rg-HANA-MM6;hanatest06
# az backup protectable-item list -g HANABackups -v hanabackupvault --workload-type SAPHANA  --output table
# az backup container list -g HANABackups -v hanabackupvault --backup-management-type AzureIaasVM --output tsv

#>

#Requires -Modules Az.Compute
#Requires -Version 5.1

param(
    [Parameter(Mandatory = $true)][string]$SubscriptionName,
    [Parameter(Mandatory = $true)][string]$RGV, 
    [Parameter(Mandatory = $true)][string]$RSV,
    [Parameter(Mandatory = $true)][string]$VM,
    [Parameter(Mandatory = $true)][string]$VMRG,
    [Parameter(Mandatory = $true)][string]$POL,
    [Parameter(Mandatory = $true)][string]$ITEMSYS,
    [Parameter(Mandatory = $true)][string]$ITEMTEN,
    [Parameter(Mandatory = $true)][string]$CONTAINER
)

# select subscription
Write-Verbose "setting azure subscription"
$Subscription = Get-AzSubscription -SubscriptionName $SubscriptionName
if (-Not $Subscription) {
    Write-Host -ForegroundColor Red -BackgroundColor White "Sorry, it seems you are not connected to Azure or don't have access to the subscription. Please use Connect-AzAccount to connect."
    exit
}
Select-AzSubscription -Subscription $SubscriptionName -Force

$VMID = az vm show -g VMRG -n $VM --query id --output tsv

az backup container register -g $RGV -v $RSV --backup-management-type AzureWorkload --workload-type SAPHANA --resource-id $VMID
az backup protection enable-for-azurewl -g $RGV -v $RSV --policy-name $POL --protectable-item-name $ITEMSYS --protectable-item-type SAPHANADatabase --server-name $VM --workload-type SAPHANA
az backup protection enable-for-azurewl -g $RGV -v $RSV --policy-name $POL --protectable-item-name $ITEMTEN --protectable-item-type SAPHANADatabase --server-name $VM --workload-type SAPHANA
az backup protection backup-now -g $RGV -v $RSV --item-name $ITEMSYS --container-name $CONTAINER --backup-type full
az backup protection backup-now -g $RGV -v $RSV --item-name $ITEMTEN --container-name $CONTAINER --backup-type full

