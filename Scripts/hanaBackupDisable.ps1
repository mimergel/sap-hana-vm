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
Write-Host "----------Disable existing HANA backup items---------"
Write-Host "az backup protectable-item  list -c '$CONTAINER' -g $RGV -v $RSV --workload-type SAPHANA --output tsv"
$PROTECT=az backup protectable-item  list -c "$CONTAINER" -g $RGV -v $RSV --workload-type SAPHANA --output tsv
Write-Host $PROTECT

    if([string]::IsNullOrEmpty($PROTECT)){
        Write-Host "----------------No Container for disabling-----------"
    }
    else {
        Write-Host "---------Found items will be disabled----------------"
        Write-Host "az backup protection disable -c '$CONTAINER' --delete-backup-data true --item-name '$ITEMSYS' -g $RGV -v $RSV --yes"
        az backup protection disable -c "$CONTAINER" --delete-backup-data true --item-name "$ITEMSYS" -g $RGV -v $RSV --yes
        Write-Host "az backup protection disable -c '$CONTAINER' --delete-backup-data true --item-name '$ITEMSTEN' -g $RGV -v $RSV --yes"
        az backup protection disable -c "$CONTAINER" --delete-backup-data true --item-name "$ITEMTEN" -g $RGV -v $RSV --yes
        Write-Host "-----------------------------------------------------"
        Write-Host ""
    }

Write-Host "-----------------------------------------------------"
Write-Host "----------------Unregister Container-----------------"
$CONTDIS=az backup container show  -g $RGV -v $RSV --name "$CONTAINER"
Write-Host $CONTDIS

    if([string]::IsNullOrEmpty($CONTDIS)){
        Write-Host "-------------No Container for disabling--------------"
    }
    else {
        Write-Host "-------------Container will be disabled--------------"
        Write-Host "az backup container unregister -c '$CONTAINER' -g $RGV -v $RSV --backup-management-type AzureWorkload --yes"
        az backup container unregister -c "$CONTAINER" -g $RGV -v $RSV --backup-management-type AzureWorkload --yes
    }   

Write-Host "-----------------------------------------------------"
Write-Host ""

Write-Host "-----------------------------------------------------"
Write-Host "---------------Checking results----------------------"
Write-Host "az backup protectable-item  list -c '$CONTAINER' -g $RGV -v $RSV --workload-type SAPHANA --output tsv"
az backup protectable-item  list -c "$CONTAINER" -g $RGV -v $RSV --workload-type SAPHANA --output tsv
Write-Host "-----------------------------------------------------"
Write-Host ""


Write-Host "-----------------------------------------------------"
Write-Host "----------------Delete IaaS Backups -----------------"

$CONTAINER2="IaasVMContainer;iaasvmcontainerv2;$VMRG;$VM"
$CONTDIS2=az backup container list -g $RGV -v $RSV --backup-management-type AzureIaasVM --query "[?name=='$CONTAINER2']"
Write-Host $CONTDIS2

    if([string]::IsNullOrEmpty($CONTDIS2)){
        Write-Host "-------------No IaaS Container found ----------------"
    }
    else {
        Write-Host "-------Container found, backup will be removed-------"
        Write-Host "az backup protection disable -c "$CONTAINER2" -g $RGV -v $RSV --item-name $VM"
        az backup protection disable -c "$CONTAINER2" -g $RGV -v $RSV --item-name $VM --yes
    }   

Write-Host "-----------------------------------------------------"
Write-Host ""

Write-Host "-----------------------------------------------------"
Write-Host "---------------Checking results----------------------"
Write-Host "az backup item show -c "$CONTAINER" -g $RGV -v $RSV --name $VM"
az backup item show -c "$CONTAINER2" -g $RGV -v $RSV --name $VM
Write-Host "-----------------------------------------------------"
Write-Host ""
