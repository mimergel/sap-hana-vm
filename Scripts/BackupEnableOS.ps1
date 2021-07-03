<#
.SYNOPSIS
    This script activates OS Backups

.DESCRIPTION
	Protection will be enabled 


.EXAMPLE
    Test the script:

    $RGV="SAPonAzureFrance"
    $RSV="rsv-sap-francecentral-001"
    $VM="SAPTESTSID"
    $SERVER="saptestsid"
    $VMRG="RG-SAP-SID"
    $POL="Non-PRD"

    ./Scripts/BackupEnableOS.ps1 -RGV $RGV -RSV $RSV -VM $VM -SERVER $SERVER -VMRG $VMRG -POL $POL

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
    [Parameter(Mandatory = $true)][string]$SERVER,
    [Parameter(Mandatory = $true)][string]$VMRG,
    [Parameter(Mandatory = $true)][string]$POL
)

$CONTAINER1="IaasVMContainer;iaasvmcontainerv2;$VMRG;$VM"
$pol=$POL.ToLower()
$OSPOL="pol-sapos-$pol"

Write-Host "-----------------------------------------------------"
Write-Host "-----------Get VM ID---------------------------------" 
Write-Host "VMID=az vm show -g $VMRG -n $VM --query id --output tsv" 
$VMID=az vm show -g $VMRG -n $VM --query id --output tsv
Write-Host "$VMID" 
Write-Host "-----------------------------------------------------"
Write-Host ""

Write-Host "-----------------------------------------------------"
Write-Host "-----------Check if VM is OS backup enabled----------"  
Write-Host "az backup protection check-vm --vm $VMID" 
$PROTECT1=az backup protection check-vm --vm $VMID
Write-Host "-----------------------------------------------------"
Write-Host ""

    if ([string]::IsNullOrEmpty($PROTECT1)) {
        Write-Host "--------VM Backup will be enabled----------------" 
        Write-Host "az backup protection enable-for-vm -g $RGV -v $RSV --vm $VMID --policy-name $OSPOL"
        az backup protection enable-for-vm -g $RGV -v $RSV --vm $VMID --policy-name $OSPOL
        Write-Host "-----------------------------------------------------"
    }
    else {
        Write-Host ""
        Write-Host "--------VM Backup is already enabled-------------" 
        Write-Host ""
    }

Write-Host "-----------------------------------------------------"
Write-Host "-----------------Running OS Backups------------------" 
Write-Host "az backup protection backup-now -g $RGV -v $RSV -c $CONTAINER1 --item-name $VM"
az backup protection backup-now -g $RGV -v $RSV -c $CONTAINER1 --item-name $VM
Write-Host ""
Write-Host "-----------------------------------------------------"

Write-Host "Last exit code: $LASTEXITCODE"
