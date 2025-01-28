<#
.SYNOPSIS
    This script excludes HANA Data and Log related disks from the OS Backup
.DESCRIPTION
    The scripts searchs Luns based on naming '*data*' or '*log*' and will then exclude the luns from the OS backup
.EXAMPLE
    Test the script:
    $RSV="rsv-gwc-grs-02"                   # recovery service vault name
    $RGV="MGMT-GEWC-DEP01-INFRASTRUCTURE"   # RSV resource group name
    $VM="saphackday50"                      # VM name
    $VMRG="DSAG-germanywestcentral"         # VM resource group name

    ./[script_name] -RSV $RSV -RGV $RGV -VM $VM -VMRG $VMRG -DiskNamePatterns data

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
    [Parameter(Mandatory = $true)][string]$RSV,
    [Parameter(Mandatory = $true)][string]$RGV, 
    [Parameter(Mandatory = $true)][string]$VM,
    [Parameter(Mandatory = $true)][string]$VMRG,
    [Parameter(Mandatory = $true)][string[]]$DiskNamePatterns
)

$CONTAINER1 = "IaasVMContainer;iaasvmcontainerv2;$VMRG;$VM"
Write-Host "Expected Backup Container Name is: $CONTAINER1"
Write-Host "-----------Get VM ID-----------"
$VMID = az vm show -g $VMRG -n $VM --query id --output tsv
Write-Host $VMID
Write-Host ""

Write-Host "-----------Check if VM is protected-----------"
$PROTECT = az backup protection check-vm --vm $VMID
if (-not $PROTECT) {
    Write-Host "VM is not protected, no selective disk backup can be enabled."
    return
}

Write-Host "-----------Select Luns for Exclusion-----------"
$AllLuns = New-Object System.Collections.Generic.List[int]

# Query once for all dataDisks
$diskJson = az vm show -g $VMRG -n $VM --query "storageProfile.dataDisks" --output json
if ($diskJson) {
    $diskObjects = $diskJson | ConvertFrom-Json
    foreach ($diskObj in $diskObjects) {
        $diskName = $diskObj.name
        $diskLun  = $diskObj.lun
        
        # Check if disk name matches any of the provided patterns
        if ($DiskNamePatterns | Where-Object { $diskName -like "*$_*" }) {
            Write-Host "Match found: LUN $diskLun -> $diskName"
            if ($diskLun -match '^\d+$') {
                $AllLuns.Add([int]$diskLun)
            }
        }
    }
}

if ($AllLuns.Count -gt 0) {
    Write-Host "Excluding LUNs: $($AllLuns -join ' ')"
    az backup protection update-for-vm -g $RGV -v $RSV -c "$CONTAINER1" -i $VM `
        --disk-list-setting exclude `
        --diskslist $AllLuns
} else {
    Write-Host "No LUNs found for exclusion."
}

Write-Host "Last exit code: $LASTEXITCODE"
