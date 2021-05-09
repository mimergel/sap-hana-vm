<#
.SYNOPSIS
    This script activates the SAP HANA Backups
.DESCRIPTION
	This script activates the SAP HANA Backups by registering the SAP HANA Instance, 
    enable protection and finally running the backups for the systemdb and tenant db.
	The script requires as prerequesite a successfully finished pre-registration script from here:
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

    ./hanaBackupEnable.ps1 -RGV $RGV -RSV $RSV -VM $VM -VMRG $VMRG -POL $POL -ITEMSYS $ITEMSYS -ITEMTEN $ITEMTEN -CONTAINER $CONTAINER

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
Write-Host "$VMID" -ForegroundColor Red
Write-Host "-----------------------------------------------------"
Write-Host ""

Write-Host "-----------------------------------------------------" 
Write-Host "---------------List protectable items----------------" 
Write-Host "az backup protectable-item  list -c '$CONTAINER' -g $RGV -v $RSV --workload-type SAPHANA --output tsv" 
$PROTECT=az backup protectable-item  list -c "$CONTAINER" -g $RGV -v $RSV --workload-type SAPHANA --output tsv
Write-Host $PROTECT
Write-Host "-----------------------------------------------------" 
Write-Host ""

Write-Host "-----------------------------------------------------"
Write-Host "-----Register the container if not yet in place -----" 

    if ([string]::IsNullOrEmpty($PROTECT)) {
        Write-Host "--------Container will be registered-----------------" 
        Write-Host "az backup container register -g $RGV -v $RSV --backup-management-type AzureWorkload --workload-type SAPHanaDatabase --resource-id $VMID" 
        az backup container register -g $RGV -v $RSV --backup-management-type AzureWorkload --workload-type SAPHanaDatabase --resource-id $VMID
    }
    else {
        Write-Host "--------Container is already in place----------------" 
    }

Write-Host "-----------------------------------------------------"
Write-Host ""

Write-Host "-----------------------------------------------------"
Write-Host "-------------------Discovery-------------------------" 
Write-Host "az backup protectable-item initialize -g $RGV -v $RSV --workload-type SAPHanaDatabase -c '$CONTAINER'" 
az backup protectable-item initialize -g $RGV -v $RSV --workload-type SAPHanaDatabase -c "$CONTAINER"
Write-Host "-----------------------------------------------------"
Write-Host ""

Write-Host "-----------------------------------------------------"
Write-Host "---------------List protectable items----------------"  
Write-Host "az backup protectable-item  list -c '$CONTAINER' -g $RGV -v $RSV --workload-type SAPHanaDatabase --output tsv" 
az backup protectable-item  list -c "$CONTAINER" -g $RGV -v $RSV --workload-type SAPHanaDatabase --output tsv
Write-Host "-----------------------------------------------------"
Write-Host ""

Write-Host "-----------------------------------------------------"
Write-Host "------------Enable SYSTEM DB Backups-----------------"  
Write-Host "az backup protection enable-for-azurewl -g $RGV -v $RSV --policy-name $POL --protectable-item-name '$ITEMSYS' --protectable-item-type SAPHANADatabase --server-name $VM --workload-type SAPHanaDatabase" 
az backup protection enable-for-azurewl -g $RGV -v $RSV --policy-name $POL --protectable-item-name "$ITEMSYS" --protectable-item-type SAPHANADatabase --server-name $VM --workload-type SAPHanaDatabase
Write-Host ""
Write-Host "------------Enable TENANT DB Backups-----------------"  
Write-Host "az backup protection enable-for-azurewl -g $RGV -v $RSV --policy-name $POL --protectable-item-name '$ITEMTEN' --protectable-item-type SAPHANADatabase --server-name $VM --workload-type SAPHanaDatabase" 
az backup protection enable-for-azurewl -g $RGV -v $RSV --policy-name $POL --protectable-item-name "$ITEMTEN" --protectable-item-type SAPHANADatabase --server-name $VM --workload-type SAPHanaDatabase
Write-Host ""

Write-Host "Uncomment following lines to activate immediate initial HANA backups"
# Write-Host "-----------------------------------------------------"
# Write-Host "-------------------Run Backups-----------------------" 
# Write-Host "az backup protection backup-now -g $RGV -v $RSV --item-name '$ITEMSYS' --container-name '$CONTAINER' --backup-type full" 
# az backup protection backup-now -g $RGV -v $RSV --item-name "$ITEMSYS" --container-name "$CONTAINER" --backup-type full
# Write-Host "az backup protection backup-now -g $RGV -v $RSV --item-name '$ITEMTEN' --container-name '$CONTAINER' --backup-type full" 
# az backup protection backup-now -g $RGV -v $RSV --item-name "$ITEMTEN" --container-name "$CONTAINER" --backup-type full
# Write-Host ""
