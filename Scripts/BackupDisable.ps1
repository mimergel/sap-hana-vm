<#
.SYNOPSIS
    Disable OS & HANA Backups
.DESCRIPTION
	This script disables the OS & HANA Backups for a specific VM and HANA DB when relavant configuration can be found
.EXAMPLE
    Test the script:
    $SID="MM6"
    $RGV="HANABackups"
    $RSV="hanabackupvault"
    $VM="hanatest06"
    $VMRG="rg-HANA-MM6"
    $POL="Non-PRD"

    ./Scripts/BackupDisable.ps1 -SID $SID -RGV $RGV -RSV $RSV -VM $VM -VMRG $VMRG -POL $POL

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
    [Parameter(Mandatory = $true)][string]$SID,     
    [Parameter(Mandatory = $true)][string]$RGV, 
    [Parameter(Mandatory = $true)][string]$RSV,
    [Parameter(Mandatory = $true)][string]$VM,
    [Parameter(Mandatory = $true)][string]$VMRG,
    [Parameter(Mandatory = $true)][string]$POL
)

$vmrg=$VMRG.ToLower()
$vm=$VM.ToLower()
$CONTAINER1="IaasVMContainer;iaasvmcontainerv2;$vmrg;$vm"
$CONTAINER2="VMAppContainer;Compute;$vmrg;$vm"
$ITEMSYS="saphanadatabase;$SID;systemdb"
$ITEMTEN="saphanadatabase;$SID;$SID"


Write-Host "-----------------------------------------------------"
Write-Host "----------Disable existing HANA backup items---------"
Write-Host "az backup protectable-item  list -c '$CONTAINER2' -g $RGV -v $RSV --workload-type SAPHANA --output tsv"
$PROTECT=az backup protectable-item  list -c "$CONTAINER2" -g $RGV -v $RSV --workload-type SAPHANA --output tsv
Write-Host $PROTECT

    if([string]::IsNullOrEmpty($PROTECT)){
        Write-Host "----------------No Container for disabling-----------"
    }
    else {
        Write-Host "---------Found items will be disabled----------------"
        Write-Host "az backup protection disable -c '$CONTAINER2' --delete-backup-data true --item-name '$ITEMSYS' -g $RGV -v $RSV --yes"
        az backup protection disable -c "$CONTAINER2" --delete-backup-data true --item-name "$ITEMSYS" -g $RGV -v $RSV --yes
        Write-Host "az backup protection disable -c '$CONTAINER2' --delete-backup-data true --item-name '$ITEMSTEN' -g $RGV -v $RSV --yes"
        az backup protection disable -c "$CONTAINER2" --delete-backup-data true --item-name "$ITEMTEN" -g $RGV -v $RSV --yes
        Write-Host "-----------------------------------------------------"
        Write-Host ""
    }

Write-Host "-----------------------------------------------------"
Write-Host "----------------Unregister Container-----------------"
$CONTDIS2=az backup container list -g $RGV -v $RSV --backup-management-type AzureWorkload --query "[?name=='$CONTAINER2']" --output tsv
Write-Host $CONTDIS2

    if([string]::IsNullOrEmpty($CONTDIS2)){
        Write-Host "-------------No Container for disabling--------------"
    }
    else {
        Write-Host "-------------Container will be disabled--------------"
        Write-Host "az backup container unregister -c '$CONTAINER2' -g $RGV -v $RSV --backup-management-type AzureWorkload --yes"
        az backup container unregister -c "$CONTAINER2" -g $RGV -v $RSV --backup-management-type AzureWorkload --yes
    }   

Write-Host "-----------------------------------------------------"
Write-Host ""

Write-Host "-----------------------------------------------------"
Write-Host "---------------Checking results----------------------"
Write-Host "az backup container list -g $RGV -v $RSV --backup-management-type AzureWorkload --query '[?name=='$CONTAINER2']' --output tsv"
az backup container list -g $RGV -v $RSV --backup-management-type AzureWorkload --query "[?name=='$CONTAINER2']" --output tsv
Write-Host "-----------------------------------------------------"
Write-Host ""


Write-Host "-----------------------------------------------------"
Write-Host "----------------Delete IaaS Backups -----------------"


$CONTDIS1=az backup container list -g $RGV -v $RSV --backup-management-type AzureIaasVM --query "[?name=='$CONTAINER1']"  --output tsv
Write-Host $CONTDIS1

    if([string]::IsNullOrEmpty($CONTDIS1)){
        Write-Host "-------------No IaaS Container found ----------------"
    }
    else {
        Write-Host "-------Container found, backup will be removed-------"
        Write-Host "az backup protection disable -c '$CONTAINER1' -g $RGV -v $RSV --item-name $VM"
        az backup protection disable -c "$CONTAINER1" -g $RGV -v $RSV --item-name $VM --yes
        Write-Host "az backup container unregister -c '$CONTAINER1' -g $RGV -v $RSV --backup-management-type AzureIaasVM --yes"
        az backup container unregister -c "$CONTAINER1" -g $RGV -v $RSV --backup-management-type AzureIaasVM --yes
    }   

Write-Host "-----------------------------------------------------"
Write-Host ""

Write-Host "-----------------------------------------------------"
Write-Host "---------------Checking results----------------------"
Write-Host "az backup item show -c "$CONTAINER1" -g $RGV -v $RSV --name $VM"
az backup item show -c "$CONTAINER1" -g $RGV -v $RSV --name $VM
Write-Host "-----------------------------------------------------"
Write-Host ""

Write-Host "Last exit code: $LASTEXITCODE"
