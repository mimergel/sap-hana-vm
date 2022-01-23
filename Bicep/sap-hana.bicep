@description('The VM Name in Azure that you want to deploy')
param vmNameInput string

@description('The Host Name on OS level that you want to deploy')
param HostNameInput string

@description('HANA System ID.')
@minLength(3)
@maxLength(3)
param hanaSystemId string = 'HDB'

@description('The type of the operating system you want to deploy.')
@allowed([
  'RHEL 7.7'
  'RHEL 8.1'
  'SLES 12 SP4'
  'SLES 12 SP5'
  'SLES 15 SP2'
])
param osType string = 'SLES 12 SP4'

@description('The type of the database')
@allowed([
  'HANA'
])
param dbType string = 'HANA'

@description('The size of the HANA System you want to deploy.')
@allowed([
  'E16ds_v4_128_GB-Non-PRD'
  'E20ds_v4_160_GB-Non-PRD'
  'M32ts_192_GB'
  'M32ls_256_GB'
  'E48ds_v4_384_GB-Non-PRD'
  'M64ls_512_GB'
  'M32dms_v2_875_GB'
  'M64ds_v2_1.000_GB'
  'M64dms_v2_1.792_GB'
  'M128ds_v2_2.000_GB'
  'M208s_v2_2.850_GB'
  'M128dms_v2_3.892_GB'
  'M208ms_v2_5.700_GB'
  'M416ms_v2_11.400_GB'
])
param hanaSystemSize string = 'M32ts_192_GB'

@description('Username for the Virtual Machine.')
param adminUsername string = 'azureuser'

@description('Type of authentication to use on the Virtual Machine.')
@allowed([
  'password'
  'sshPublicKey'
])
param authenticationType string = 'sshPublicKey'

@description('Password or ssh key for the Virtual Machine.')
@secure()
param adminPasswordOrKey string

@description('The id of the subnet you want to use.')
param subnetId string

@description('Zone number. Set to 0 if you do not want to use Availability Zones')
@minValue(0)
@maxValue(3)
param availabilityZone int = 0

@description('Location for all resources.')
param location string = resourceGroup().location

@description('Provide mandatory Owner Name')
param Owner string = 'SAP Team Contact'

@description('Provide mandatory Cost Center ID')
param CostCenter string = '28007510'

@description('DeployIfNotExist: Configure backup on the VM with a given tag to an existing recovery services vault in the same location, expected Tag is HANABackup with value Non-PRD or PRD')
param BackupTag string = 'Non-PRD'

@description('Name of the storage account for boot diagnostics')
param diagnosticsStorageAccountName string = 'saponazuretrialdiag'

@description('URL of the disk configuration script')
param Script_URL string = 'https://raw.githubusercontent.com/mimergel/sap-hana-vm/main/Scripts/diskConfig.sh'

var selectedZones = ((availabilityZone == 0) ? json('null') : array(availabilityZone))
var images = {
  'RHEL 7.7': {
    sku: '77sapha-gen2'
    offer: 'RHEL-SAP-HA'
    publisher: 'RedHat'
    OSType: 'Linux'
    version: 'latest'
  }
  'RHEL 8.1': {
    sku: '81sapha-gen2'
    offer: 'RHEL-SAP-HA'
    publisher: 'RedHat'
    OSType: 'Linux'
    version: '8.1.2021040902'
  }
  'SLES 12 SP4': {
    sku: '12-sp4-gen2'
    offer: 'SLES-SAP'
    publisher: 'SUSE'
    OSType: 'Linux'
    version: 'latest'
  }
  'SLES 12 SP5': {
    sku: 'gen2'
    offer: 'sles-sap-12-sp5'
    publisher: 'SUSE'
    OSType: 'Linux'
    version: 'latest'
  }
  'SLES 15 SP2': {
    sku: 'gen2'
    offer: 'sles-sap-15-sp2'
    publisher: 'SUSE'
    OSType: 'Linux'
    version: 'latest'
  }
}
var internalOSType = images[osType].OSType
var csExtension = {
  Linux: {
    Publisher: 'Microsoft.Azure.Extensions'
    Name: 'CustomScript'
    Version: '2.0'
    script: Script_URL
    scriptCall: 'sh diskConfig.sh'
  }
}
var sizes = {
  'E16ds_v4_128_GB-Non-PRD': {
    HANA: {
      vmSize: 'Standard_E16ds_v4'
      disks: [
        {
          lun: 0
          name: '${vmName_var}-usrsap-disk'
          caching: 'ReadOnly'
          createOption: 'Empty'
          diskSizeGB: 64
        }
        {
          lun: 1
          name: '${vmName_var}-data1-disk'
          caching: 'ReadOnly'
          createOption: 'Empty'
          diskSizeGB: 64
        }
        {
          lun: 2
          name: '${vmName_var}-data2-disk'
          caching: 'ReadOnly'
          createOption: 'Empty'
          diskSizeGB: 64
        }
        {
          lun: 3
          name: '${vmName_var}-data3-disk'
          caching: 'ReadOnly'
          createOption: 'Empty'
          diskSizeGB: 64
        }
        {
          lun: 4
          name: '${vmName_var}-log1-disk'
          caching: 'None'
          createOption: 'Empty'
          diskSizeGB: 128
        }
        {
          lun: 5
          name: '${vmName_var}-log2-disk'
          caching: 'None'
          createOption: 'Empty'
          diskSizeGB: 128
        }
        {
          lun: 6
          name: '${vmName_var}-log3-disk'
          caching: 'None'
          createOption: 'Empty'
          diskSizeGB: 128
        }
        {
          lun: 7
          name: '${vmName_var}-shared-disk'
          caching: 'ReadOnly'
          createOption: 'Empty'
          diskSizeGB: 512
        }
        {
          lun: 8
          name: '${vmName_var}-backup-disk'
          caching: 'ReadOnly'
          createOption: 'Empty'
          diskSizeGB: 512
        }
      ]
      scriptArguments: {
        Linux: '-luns \'0#1,2,3#4,5,6#7#8\' -names \'usrsap#data#log#shared#backup\' -paths \'/usr/sap#/hana/data#/hana/log#/hana/shared#/hana/backup\' -sizes \'100#100#100#100#100\''
      }
      useFastNetwork: true
    }
  }
  'E20ds_v4_160_GB-Non-PRD': {
    HANA: {
      vmSize: 'Standard_E20ds_v4'
      disks: [
        {
          lun: 0
          name: '${vmName_var}-usrsap-disk'
          caching: 'ReadOnly'
          createOption: 'Empty'
          diskSizeGB: 64
        }
        {
          lun: 1
          name: '${vmName_var}-data1-disk'
          caching: 'ReadOnly'
          createOption: 'Empty'
          diskSizeGB: 128
        }
        {
          lun: 2
          name: '${vmName_var}-data2-disk'
          caching: 'ReadOnly'
          createOption: 'Empty'
          diskSizeGB: 128
        }
        {
          lun: 3
          name: '${vmName_var}-data3-disk'
          caching: 'ReadOnly'
          createOption: 'Empty'
          diskSizeGB: 128
        }
        {
          lun: 4
          name: '${vmName_var}-log1-disk'
          caching: 'None'
          createOption: 'Empty'
          diskSizeGB: 128
        }
        {
          lun: 5
          name: '${vmName_var}-log2-disk'
          caching: 'None'
          createOption: 'Empty'
          diskSizeGB: 128
        }
        {
          lun: 6
          name: '${vmName_var}-log3-disk'
          caching: 'None'
          createOption: 'Empty'
          diskSizeGB: 128
        }
        {
          lun: 7
          name: '${vmName_var}-shared-disk'
          caching: 'ReadOnly'
          createOption: 'Empty'
          diskSizeGB: 512
        }
        {
          lun: 8
          name: '${vmName_var}-backup-disk'
          caching: 'ReadOnly'
          createOption: 'Empty'
          diskSizeGB: 512
        }
      ]
      scriptArguments: {
        Linux: '-luns \'0#1,2,3,#4,5,6#7#8\' -names \'usrsap#data#log#shared#backup\' -paths \'/usr/sap#/hana/data#/hana/log#/hana/shared#/hana/backup\' -sizes \'100#100#100#100#100\''
      }
      useFastNetwork: true
    }
  }
  M32ts_192_GB: {
    HANA: {
      vmSize: 'Standard_M32ts'
      disks: [
        {
          lun: 0
          name: '${vmName_var}-usrsap-disk'
          caching: 'ReadOnly'
          createOption: 'Empty'
          diskSizeGB: 64
        }
        {
          lun: 1
          name: '${vmName_var}-data1-disk'
          caching: 'ReadOnly'
          createOption: 'Empty'
          diskSizeGB: 64
        }
        {
          lun: 2
          name: '${vmName_var}-data2-disk'
          caching: 'ReadOnly'
          createOption: 'Empty'
          diskSizeGB: 64
        }
        {
          lun: 3
          name: '${vmName_var}-data3-disk'
          caching: 'ReadOnly'
          createOption: 'Empty'
          diskSizeGB: 64
        }
        {
          lun: 4
          name: '${vmName_var}-data4-disk'
          caching: 'ReadOnly'
          createOption: 'Empty'
          diskSizeGB: 64
        }
        {
          lun: 5
          name: '${vmName_var}-log1-disk'
          caching: 'None'
          writeAcceleratorEnabled: 'true'
          createOption: 'Empty'
          diskSizeGB: 128
        }
        {
          lun: 6
          name: '${vmName_var}-log2-disk'
          caching: 'None'
          writeAcceleratorEnabled: 'true'
          createOption: 'Empty'
          diskSizeGB: 128
        }
        {
          lun: 7
          name: '${vmName_var}-log3-disk'
          caching: 'None'
          writeAcceleratorEnabled: 'true'
          createOption: 'Empty'
          diskSizeGB: 128
        }
        {
          lun: 8
          name: '${vmName_var}-shared-disk'
          caching: 'ReadOnly'
          createOption: 'Empty'
          diskSizeGB: 512
        }
        {
          lun: 9
          name: '${vmName_var}-backup-disk'
          caching: 'ReadOnly'
          createOption: 'Empty'
          diskSizeGB: 512
        }
      ]
      scriptArguments: {
        Linux: '-luns \'0#1,2,3,4#5,6,7#8#9\' -names \'usrsap#data#log#shared#backup\' -paths \'/usr/sap#/hana/data#/hana/log#/hana/shared#/hana/backup\' -sizes \'100#100#100#100#100\''
      }
      useFastNetwork: true
    }
  }
  M32ls_256_GB: {
    HANA: {
      vmSize: 'Standard_M32ls'
      disks: [
        {
          lun: 0
          name: '${vmName_var}-usrsap-disk'
          caching: 'ReadOnly'
          createOption: 'Empty'
          diskSizeGB: 64
        }
        {
          lun: 1
          name: '${vmName_var}-data1-disk'
          caching: 'ReadOnly'
          createOption: 'Empty'
          diskSizeGB: 64
        }
        {
          lun: 2
          name: '${vmName_var}-data2-disk'
          caching: 'ReadOnly'
          createOption: 'Empty'
          diskSizeGB: 64
        }
        {
          lun: 3
          name: '${vmName_var}-data3-disk'
          caching: 'ReadOnly'
          createOption: 'Empty'
          diskSizeGB: 64
        }
        {
          lun: 4
          name: '${vmName_var}-data4-disk'
          caching: 'ReadOnly'
          createOption: 'Empty'
          diskSizeGB: 64
        }
        {
          lun: 5
          name: '${vmName_var}-log1-disk'
          caching: 'None'
          writeAcceleratorEnabled: 'true'
          createOption: 'Empty'
          diskSizeGB: 128
        }
        {
          lun: 6
          name: '${vmName_var}-log2-disk'
          caching: 'None'
          writeAcceleratorEnabled: 'true'
          createOption: 'Empty'
          diskSizeGB: 128
        }
        {
          lun: 7
          name: '${vmName_var}-log3-disk'
          caching: 'None'
          writeAcceleratorEnabled: 'true'
          createOption: 'Empty'
          diskSizeGB: 128
        }
        {
          lun: 8
          name: '${vmName_var}-shared-disk'
          caching: 'ReadOnly'
          createOption: 'Empty'
          diskSizeGB: 512
        }
        {
          lun: 9
          name: '${vmName_var}-backup-disk'
          caching: 'ReadOnly'
          createOption: 'Empty'
          diskSizeGB: 512
        }
      ]
      scriptArguments: {
        Linux: '-luns \'0#1,2,3,4#5,6,7#8#9\' -names \'usrsap#data#log#shared#backup\' -paths \'/usr/sap#/hana/data#/hana/log#/hana/shared#/hana/backup\' -sizes \'100#100#100#100#100\''
      }
      useFastNetwork: true
    }
  }
  'E48ds_v4_384_GB-Non-PRD': {
    HANA: {
      vmSize: 'Standard_E48ds_v4'
      disks: [
        {
          lun: 0
          name: '${vmName_var}-usrsap-disk'
          caching: 'ReadOnly'
          createOption: 'Empty'
          diskSizeGB: 64
        }
        {
          lun: 1
          name: '${vmName_var}-data1-disk'
          caching: 'ReadOnly'
          createOption: 'Empty'
          diskSizeGB: 256
        }
        {
          lun: 2
          name: '${vmName_var}-data2-disk'
          caching: 'ReadOnly'
          createOption: 'Empty'
          diskSizeGB: 256
        }
        {
          lun: 3
          name: '${vmName_var}-data3-disk'
          caching: 'ReadOnly'
          createOption: 'Empty'
          diskSizeGB: 256
        }
        {
          lun: 4
          name: '${vmName_var}-log1-disk'
          caching: 'None'
          writeAcceleratorEnabled: 'true'
          createOption: 'Empty'
          diskSizeGB: 128
        }
        {
          lun: 5
          name: '${vmName_var}-log2-disk'
          caching: 'None'
          writeAcceleratorEnabled: 'true'
          createOption: 'Empty'
          diskSizeGB: 128
        }
        {
          lun: 6
          name: '${vmName_var}-log3-disk'
          caching: 'None'
          writeAcceleratorEnabled: 'true'
          createOption: 'Empty'
          diskSizeGB: 128
        }
        {
          lun: 7
          name: '${vmName_var}-shared-disk'
          caching: 'ReadOnly'
          createOption: 'Empty'
          diskSizeGB: 512
        }
        {
          lun: 8
          name: '${vmName_var}-backup-disk'
          caching: 'ReadOnly'
          createOption: 'Empty'
          diskSizeGB: 512
        }
      ]
      scriptArguments: {
        Linux: '-luns \'0#1,2,3#4,5,6#7#8\' -names \'usrsap#data#log#shared#backup\' -paths \'/usr/sap#/hana/data#/hana/log#/hana/shared#/hana/backup\' -sizes \'100#100#100#100#100\''
      }
      useFastNetwork: true
    }
  }
  M64ls_512_GB: {
    HANA: {
      vmSize: 'Standard_M64ls'
      disks: [
        {
          lun: 0
          name: '${vmName_var}-usrsap-disk'
          caching: 'ReadOnly'
          createOption: 'Empty'
          diskSizeGB: 64
        }
        {
          lun: 1
          name: '${vmName_var}-data1-disk'
          caching: 'ReadOnly'
          createOption: 'Empty'
          diskSizeGB: 128
        }
        {
          lun: 2
          name: '${vmName_var}-data2-disk'
          caching: 'ReadOnly'
          createOption: 'Empty'
          diskSizeGB: 128
        }
        {
          lun: 3
          name: '${vmName_var}-data3-disk'
          caching: 'ReadOnly'
          createOption: 'Empty'
          diskSizeGB: 128
        }
        {
          lun: 4
          name: '${vmName_var}-data4-disk'
          caching: 'ReadOnly'
          createOption: 'Empty'
          diskSizeGB: 128
        }
        {
          lun: 5
          name: '${vmName_var}-log1-disk'
          caching: 'None'
          writeAcceleratorEnabled: 'true'
          createOption: 'Empty'
          diskSizeGB: 128
        }
        {
          lun: 6
          name: '${vmName_var}-log2-disk'
          caching: 'None'
          writeAcceleratorEnabled: 'true'
          createOption: 'Empty'
          diskSizeGB: 128
        }
        {
          lun: 7
          name: '${vmName_var}-log3-disk'
          caching: 'None'
          writeAcceleratorEnabled: 'true'
          createOption: 'Empty'
          diskSizeGB: 128
        }
        {
          lun: 8
          name: '${vmName_var}-shared-disk'
          caching: 'ReadOnly'
          createOption: 'Empty'
          diskSizeGB: 512
        }
        {
          lun: 9
          name: '${vmName_var}-backup-disk'
          caching: 'ReadOnly'
          createOption: 'Empty'
          diskSizeGB: 512
        }
      ]
      scriptArguments: {
        Linux: '-luns \'0#1,2,3,4#5,6,7#8#9\' -names \'usrsap#data#log#shared#backup\' -paths \'/usr/sap#/hana/data#/hana/log#/hana/shared#/hana/backup\' -sizes \'100#100#100#100#100\''
      }
      useFastNetwork: true
    }
  }
  M32dms_v2_875_GB: {
    HANA: {
      vmSize: 'Standard_M32dms_v2'
      disks: [
        {
          lun: 0
          name: '${vmName_var}-usrsap-disk'
          caching: 'ReadOnly'
          createOption: 'Empty'
          diskSizeGB: 64
        }
        {
          lun: 1
          name: '${vmName_var}-data1-disk'
          caching: 'ReadOnly'
          createOption: 'Empty'
          diskSizeGB: 256
        }
        {
          lun: 2
          name: '${vmName_var}-data2-disk'
          caching: 'ReadOnly'
          createOption: 'Empty'
          diskSizeGB: 256
        }
        {
          lun: 3
          name: '${vmName_var}-data3-disk'
          caching: 'ReadOnly'
          createOption: 'Empty'
          diskSizeGB: 256
        }
        {
          lun: 4
          name: '${vmName_var}-data4-disk'
          caching: 'ReadOnly'
          createOption: 'Empty'
          diskSizeGB: 256
        }
        {
          lun: 5
          name: '${vmName_var}-log1-disk'
          caching: 'None'
          writeAcceleratorEnabled: 'true'
          createOption: 'Empty'
          diskSizeGB: 256
        }
        {
          lun: 6
          name: '${vmName_var}-log2-disk'
          caching: 'None'
          writeAcceleratorEnabled: 'true'
          createOption: 'Empty'
          diskSizeGB: 256
        }
        {
          lun: 7
          name: '${vmName_var}-log3-disk'
          caching: 'None'
          writeAcceleratorEnabled: 'true'
          createOption: 'Empty'
          diskSizeGB: 256
        }
        {
          lun: 8
          name: '${vmName_var}-shared-disk'
          caching: 'ReadOnly'
          createOption: 'Empty'
          diskSizeGB: 1024
        }
        {
          lun: 9
          name: '${vmName_var}-backup-disk'
          caching: 'ReadOnly'
          createOption: 'Empty'
          diskSizeGB: 1024
        }
      ]
      scriptArguments: {
        Linux: '-luns \'0#1,2,3,4#5,6,7#8#9\' -names \'usrsap#data#log#shared#backup\' -paths \'/usr/sap#/hana/data#/hana/log#/hana/shared#/hana/backup\' -sizes \'100#100#100#100#100\''
      }
      useFastNetwork: true
    }
  }
  'M64ds_v2_1.000_GB': {
    HANA: {
      vmSize: 'Standard_M64ds_v2'
      disks: [
        {
          lun: 0
          name: '${vmName_var}-usrsap-disk'
          caching: 'ReadOnly'
          createOption: 'Empty'
          diskSizeGB: 64
        }
        {
          lun: 1
          name: '${vmName_var}-data1-disk'
          caching: 'ReadOnly'
          createOption: 'Empty'
          diskSizeGB: 256
        }
        {
          lun: 2
          name: '${vmName_var}-data2-disk'
          caching: 'ReadOnly'
          createOption: 'Empty'
          diskSizeGB: 256
        }
        {
          lun: 3
          name: '${vmName_var}-data3-disk'
          caching: 'ReadOnly'
          createOption: 'Empty'
          diskSizeGB: 256
        }
        {
          lun: 4
          name: '${vmName_var}-data4-disk'
          caching: 'ReadOnly'
          createOption: 'Empty'
          diskSizeGB: 256
        }
        {
          lun: 5
          name: '${vmName_var}-log1-disk'
          caching: 'None'
          writeAcceleratorEnabled: 'true'
          createOption: 'Empty'
          diskSizeGB: 256
        }
        {
          lun: 6
          name: '${vmName_var}-log2-disk'
          caching: 'None'
          writeAcceleratorEnabled: 'true'
          createOption: 'Empty'
          diskSizeGB: 256
        }
        {
          lun: 7
          name: '${vmName_var}-log3-disk'
          caching: 'None'
          writeAcceleratorEnabled: 'true'
          createOption: 'Empty'
          diskSizeGB: 256
        }
        {
          lun: 8
          name: '${vmName_var}-shared-disk'
          caching: 'ReadOnly'
          createOption: 'Empty'
          diskSizeGB: 1024
        }
        {
          lun: 9
          name: '${vmName_var}-backup-disk'
          caching: 'ReadOnly'
          createOption: 'Empty'
          diskSizeGB: 1024
        }
      ]
      scriptArguments: {
        Linux: '-luns \'0#1,2,3,4#5,6,7#8#9\' -names \'usrsap#data#log#shared#backup\' -paths \'/usr/sap#/hana/data#/hana/log#/hana/shared#/hana/backup\' -sizes \'100#100#100#100#100\''
      }
      useFastNetwork: true
    }
  }
  'M64dms_v2_1.792_GB': {
    HANA: {
      vmSize: 'Standard_M64dms_v2'
      disks: [
        {
          lun: 0
          name: '${vmName_var}-usrsap-disk'
          caching: 'ReadOnly'
          createOption: 'Empty'
          diskSizeGB: 64
        }
        {
          lun: 1
          name: '${vmName_var}-data1-disk'
          caching: 'ReadOnly'
          createOption: 'Empty'
          diskSizeGB: 512
        }
        {
          lun: 2
          name: '${vmName_var}-data2-disk'
          caching: 'ReadOnly'
          createOption: 'Empty'
          diskSizeGB: 512
        }
        {
          lun: 3
          name: '${vmName_var}-data3-disk'
          caching: 'ReadOnly'
          createOption: 'Empty'
          diskSizeGB: 512
        }
        {
          lun: 4
          name: '${vmName_var}-data4-disk'
          caching: 'ReadOnly'
          createOption: 'Empty'
          diskSizeGB: 512
        }
        {
          lun: 5
          name: '${vmName_var}-log1-disk'
          caching: 'None'
          writeAcceleratorEnabled: 'true'
          createOption: 'Empty'
          diskSizeGB: 256
        }
        {
          lun: 6
          name: '${vmName_var}-log2-disk'
          caching: 'None'
          writeAcceleratorEnabled: 'true'
          createOption: 'Empty'
          diskSizeGB: 256
        }
        {
          lun: 7
          name: '${vmName_var}-log3-disk'
          caching: 'None'
          writeAcceleratorEnabled: 'true'
          createOption: 'Empty'
          diskSizeGB: 256
        }
        {
          lun: 8
          name: '${vmName_var}-shared-disk'
          caching: 'ReadOnly'
          createOption: 'Empty'
          diskSizeGB: 1024
        }
        {
          lun: 9
          name: '${vmName_var}-backup-disk'
          caching: 'ReadOnly'
          createOption: 'Empty'
          diskSizeGB: 1024
        }
      ]
      scriptArguments: {
        Linux: '-luns \'0#1,2,3,4#5,6,7#8#9\' -names \'usrsap#data#log#shared#backup\' -paths \'/usr/sap#/hana/data#/hana/log#/hana/shared#/hana/backup\' -sizes \'100#100#100#100#100\''
      }
      useFastNetwork: true
    }
  }
  'M128ds_v2_2.000_GB': {
    HANA: {
      vmSize: 'Standard_M128ds_v2'
      disks: [
        {
          lun: 0
          name: '${vmName_var}-usrsap-disk'
          caching: 'ReadOnly'
          createOption: 'Empty'
          diskSizeGB: 128
        }
        {
          lun: 1
          name: '${vmName_var}-data1-disk'
          caching: 'ReadOnly'
          createOption: 'Empty'
          diskSizeGB: 512
        }
        {
          lun: 2
          name: '${vmName_var}-data2-disk'
          caching: 'ReadOnly'
          createOption: 'Empty'
          diskSizeGB: 512
        }
        {
          lun: 3
          name: '${vmName_var}-data3-disk'
          caching: 'ReadOnly'
          createOption: 'Empty'
          diskSizeGB: 512
        }
        {
          lun: 4
          name: '${vmName_var}-data4-disk'
          caching: 'ReadOnly'
          createOption: 'Empty'
          diskSizeGB: 512
        }
        {
          lun: 5
          name: '${vmName_var}-log1-disk'
          caching: 'None'
          writeAcceleratorEnabled: 'true'
          createOption: 'Empty'
          diskSizeGB: 256
        }
        {
          lun: 6
          name: '${vmName_var}-log2-disk'
          caching: 'None'
          writeAcceleratorEnabled: 'true'
          createOption: 'Empty'
          diskSizeGB: 256
        }
        {
          lun: 7
          name: '${vmName_var}-log3-disk'
          caching: 'None'
          writeAcceleratorEnabled: 'true'
          createOption: 'Empty'
          diskSizeGB: 256
        }
        {
          lun: 8
          name: '${vmName_var}-shared-disk'
          caching: 'ReadOnly'
          createOption: 'Empty'
          diskSizeGB: 1024
        }
        {
          lun: 9
          name: '${vmName_var}-backup-disk'
          caching: 'ReadOnly'
          createOption: 'Empty'
          diskSizeGB: 1024
        }
      ]
      scriptArguments: {
        Linux: '-luns \'0#1,2,3,4#5,6,7#8#9\' -names \'usrsap#data#log#shared#backup\' -paths \'/usr/sap#/hana/data#/hana/log#/hana/shared#/hana/backup\' -sizes \'100#100#100#100#100\''
      }
      useFastNetwork: true
    }
  }
  'M208s_v2_2.850_GB': {
    HANA: {
      vmSize: 'Standard_M208s_v2'
      disks: [
        {
          lun: 0
          name: '${vmName_var}-usrsap-disk'
          caching: 'ReadOnly'
          createOption: 'Empty'
          diskSizeGB: 128
        }
        {
          lun: 1
          name: '${vmName_var}-data1-disk'
          caching: 'ReadOnly'
          createOption: 'Empty'
          diskSizeGB: 1024
        }
        {
          lun: 2
          name: '${vmName_var}-data2-disk'
          caching: 'ReadOnly'
          createOption: 'Empty'
          diskSizeGB: 1024
        }
        {
          lun: 3
          name: '${vmName_var}-data3-disk'
          caching: 'ReadOnly'
          createOption: 'Empty'
          diskSizeGB: 1024
        }
        {
          lun: 4
          name: '${vmName_var}-data4-disk'
          caching: 'ReadOnly'
          createOption: 'Empty'
          diskSizeGB: 1024
        }
        {
          lun: 5
          name: '${vmName_var}-log1-disk'
          caching: 'None'
          writeAcceleratorEnabled: 'true'
          createOption: 'Empty'
          diskSizeGB: 256
        }
        {
          lun: 6
          name: '${vmName_var}-log2-disk'
          caching: 'None'
          writeAcceleratorEnabled: 'true'
          createOption: 'Empty'
          diskSizeGB: 256
        }
        {
          lun: 7
          name: '${vmName_var}-log3-disk'
          caching: 'None'
          writeAcceleratorEnabled: 'true'
          createOption: 'Empty'
          diskSizeGB: 256
        }
        {
          lun: 8
          name: '${vmName_var}-shared-disk'
          caching: 'ReadOnly'
          createOption: 'Empty'
          diskSizeGB: 1024
        }
        {
          lun: 9
          name: '${vmName_var}-backup-disk'
          caching: 'ReadOnly'
          createOption: 'Empty'
          diskSizeGB: 1024
        }
      ]
      scriptArguments: {
        Linux: '-luns \'0#1,2,3,4#5,6,7#8#9\' -names \'usrsap#data#log#shared#backup\' -paths \'/usr/sap#/hana/data#/hana/log#/hana/shared#/hana/backup\' -sizes \'100#100#100#100#100\''
      }
      useFastNetwork: true
    }
  }
  'M128dms_v2_3.892_GB': {
    HANA: {
      vmSize: 'Standard_M128dms_v2'
      disks: [
        {
          lun: 0
          name: '${vmName_var}-usrsap-disk'
          caching: 'ReadOnly'
          createOption: 'Empty'
          diskSizeGB: 128
        }
        {
          lun: 1
          name: '${vmName_var}-data1-disk'
          caching: 'ReadOnly'
          createOption: 'Empty'
          diskSizeGB: 1024
        }
        {
          lun: 2
          name: '${vmName_var}-data2-disk'
          caching: 'ReadOnly'
          createOption: 'Empty'
          diskSizeGB: 1024
        }
        {
          lun: 3
          name: '${vmName_var}-data3-disk'
          caching: 'ReadOnly'
          createOption: 'Empty'
          diskSizeGB: 1024
        }
        {
          lun: 4
          name: '${vmName_var}-data4-disk'
          caching: 'ReadOnly'
          createOption: 'Empty'
          diskSizeGB: 1024
        }
        {
          lun: 5
          name: '${vmName_var}-data5-disk'
          caching: 'ReadOnly'
          createOption: 'Empty'
          diskSizeGB: 1024
        }
        {
          lun: 6
          name: '${vmName_var}-log1-disk'
          caching: 'None'
          writeAcceleratorEnabled: 'true'
          createOption: 'Empty'
          diskSizeGB: 256
        }
        {
          lun: 7
          name: '${vmName_var}-log2-disk'
          caching: 'None'
          writeAcceleratorEnabled: 'true'
          createOption: 'Empty'
          diskSizeGB: 256
        }
        {
          lun: 8
          name: '${vmName_var}-log3-disk'
          caching: 'None'
          writeAcceleratorEnabled: 'true'
          createOption: 'Empty'
          diskSizeGB: 256
        }
        {
          lun: 9
          name: '${vmName_var}-shared-disk'
          caching: 'ReadOnly'
          createOption: 'Empty'
          diskSizeGB: 1024
        }
        {
          lun: 10
          name: '${vmName_var}-backup-disk'
          caching: 'ReadOnly'
          createOption: 'Empty'
          diskSizeGB: 1024
        }
      ]
      scriptArguments: {
        Linux: '-luns \'0#1,2,3,4,5#6,7,8#9#10\' -names \'usrsap#data#log#shared#backup\' -paths \'/usr/sap#/hana/data#/hana/log#/hana/shared#/hana/backup\' -sizes \'100#100#100#100#100\''
      }
      useFastNetwork: true
    }
  }
  'M208ms_v2_5.700_GB': {
    HANA: {
      vmSize: 'Standard_M208ms_v2'
      disks: [
        {
          lun: 0
          name: '${vmName_var}-usrsap-disk'
          caching: 'ReadOnly'
          createOption: 'Empty'
          diskSizeGB: 128
        }
        {
          lun: 1
          name: '${vmName_var}-data1-disk'
          caching: 'ReadOnly'
          createOption: 'Empty'
          diskSizeGB: 2048
        }
        {
          lun: 2
          name: '${vmName_var}-data2-disk'
          caching: 'ReadOnly'
          createOption: 'Empty'
          diskSizeGB: 2048
        }
        {
          lun: 3
          name: '${vmName_var}-data3-disk'
          caching: 'ReadOnly'
          createOption: 'Empty'
          diskSizeGB: 2048
        }
        {
          lun: 4
          name: '${vmName_var}-data4-disk'
          caching: 'ReadOnly'
          createOption: 'Empty'
          diskSizeGB: 2048
        }
        {
          lun: 5
          name: '${vmName_var}-log1-disk'
          caching: 'None'
          writeAcceleratorEnabled: 'true'
          createOption: 'Empty'
          diskSizeGB: 256
        }
        {
          lun: 6
          name: '${vmName_var}-log2-disk'
          caching: 'None'
          writeAcceleratorEnabled: 'true'
          createOption: 'Empty'
          diskSizeGB: 256
        }
        {
          lun: 7
          name: '${vmName_var}-log3-disk'
          caching: 'None'
          writeAcceleratorEnabled: 'true'
          createOption: 'Empty'
          diskSizeGB: 256
        }
        {
          lun: 8
          name: '${vmName_var}-shared-disk'
          caching: 'ReadOnly'
          createOption: 'Empty'
          diskSizeGB: 1024
        }
        {
          lun: 9
          name: '${vmName_var}-backup-disk'
          caching: 'ReadOnly'
          createOption: 'Empty'
          diskSizeGB: 1024
        }
      ]
      scriptArguments: {
        Linux: '-luns \'0#1,2,3,4#5,6,7#8#9\' -names \'usrsap#data#log#shared#backup\' -paths \'/usr/sap#/hana/data#/hana/log#/hana/shared#/hana/backup\' -sizes \'100#100#100#100#100\''
      }
      useFastNetwork: true
    }
  }
  'M416ms_v2_11.400_GB': {
    HANA: {
      vmSize: 'Standard_M416ms_v2'
      disks: [
        {
          lun: 0
          name: '${vmName_var}-usrsap-disk'
          caching: 'ReadOnly'
          createOption: 'Empty'
          diskSizeGB: 128
        }
        {
          lun: 1
          name: '${vmName_var}-data1-disk'
          caching: 'ReadOnly'
          createOption: 'Empty'
          diskSizeGB: 4095
        }
        {
          lun: 2
          name: '${vmName_var}-data2-disk'
          caching: 'ReadOnly'
          createOption: 'Empty'
          diskSizeGB: 4095
        }
        {
          lun: 3
          name: '${vmName_var}-data3-disk'
          caching: 'ReadOnly'
          createOption: 'Empty'
          diskSizeGB: 4095
        }
        {
          lun: 4
          name: '${vmName_var}-data4-disk'
          caching: 'ReadOnly'
          createOption: 'Empty'
          diskSizeGB: 4095
        }
        {
          lun: 5
          name: '${vmName_var}-log1-disk'
          caching: 'None'
          writeAcceleratorEnabled: 'true'
          createOption: 'Empty'
          diskSizeGB: 256
        }
        {
          lun: 6
          name: '${vmName_var}-log2-disk'
          caching: 'None'
          writeAcceleratorEnabled: 'true'
          createOption: 'Empty'
          diskSizeGB: 256
        }
        {
          lun: 7
          name: '${vmName_var}-log3-disk'
          caching: 'None'
          writeAcceleratorEnabled: 'true'
          createOption: 'Empty'
          diskSizeGB: 256
        }
        {
          lun: 8
          name: '${vmName_var}-shared-disk'
          caching: 'ReadOnly'
          createOption: 'Empty'
          diskSizeGB: 1024
        }
        {
          lun: 9
          name: '${vmName_var}-backup-disk'
          caching: 'ReadOnly'
          createOption: 'Empty'
          diskSizeGB: 1024
        }
      ]
      scriptArguments: {
        Linux: '-luns \'0#1,2,3,4#5,6,7#8#9\' -names \'usrsap#data#log#shared#backup\' -paths \'/usr/sap#/hana/data#/hana/log#/hana/shared#/hana/backup\' -sizes \'100#100#100#100#100\''
      }
      useFastNetwork: true
    }
  }
}
var vmName_var = vmNameInput
var HostName = toLower(HostNameInput)
var vnetName = '${vmName_var}-vnet'
var nicName_var = '${vmName_var}-nic'
var subnetName = 'Subnet'
var linuxConfiguration = {
  disablePasswordAuthentication: true
  ssh: {
    publicKeys: [
      {
        path: '/home/${adminUsername}/.ssh/authorized_keys'
        keyData: adminPasswordOrKey
      }
    ]
  }
}
var subnets = {
  true: resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, subnetName)
  false: subnetId
}
var selectedSubnetId = subnets[string((length(subnetId) == 0))]

resource nicName 'Microsoft.Network/networkInterfaces@2018-10-01' = {
  name: nicName_var
  location: location
  tags: {
    'cost-center': CostCenter
    application: 'SAP'
    owner: Owner
    'cmdb-link': 'https://tbd.'
  }
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: selectedSubnetId
          }
        }
      }
    ]
    enableAcceleratedNetworking: sizes[hanaSystemSize][dbType].useFastNetwork
  }
}

resource vmName 'Microsoft.Compute/virtualMachines@2018-10-01' = {
  name: vmName_var
  zones: selectedZones
  location: location
  tags: {
    'cost-center': CostCenter
    application: 'SAP'
    owner: Owner
    'cmdb-link': 'https://tbd.'
    HANABackup: BackupTag
  }
  properties: {
    hardwareProfile: {
      vmSize: sizes[hanaSystemSize][dbType].vmSize
    }
    osProfile: {
      computerName: HostName
      adminUsername: adminUsername
      adminPassword: adminPasswordOrKey
      linuxConfiguration: ((authenticationType == 'password') ? json('null') : linuxConfiguration)
    }
    storageProfile: {
      imageReference: {
        publisher: images[osType].publisher
        offer: images[osType].offer
        sku: images[osType].sku
        version: images[osType].version
      }
      osDisk: {
        name: '${vmName_var}-os-disk'
        caching: 'ReadWrite'
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Premium_LRS'
        }
      }
      dataDisks: sizes[hanaSystemSize][dbType].disks
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nicName.id
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
        storageUri: 'https://${diagnosticsStorageAccountName}.blob.core.windows.net/'
      }
    }
  }
}

resource vmName_csExtension_internalOSType_Name 'Microsoft.Compute/virtualMachines/extensions@2018-10-01' = {
  parent: vmName
  name: '${csExtension[internalOSType].Name}'
  location: location
  tags: {
    'cost-center': CostCenter
    application: 'SAP'
    owner: Owner
    'cmdb-link': 'https://tbd.'
  }
  properties: {
    publisher: csExtension[internalOSType].Publisher
    type: csExtension[internalOSType].Name
    typeHandlerVersion: csExtension[internalOSType].Version
    autoUpgradeMinorVersion: true
    settings: {
      fileUris: [
        csExtension[internalOSType].script
      ]
      commandToExecute: '${csExtension[internalOSType].scriptCall} ${sizes[hanaSystemSize][dbType].scriptArguments[internalOSType]}'
    }
  }
}

output HANAVMNAME string = vmName_var
output HANADBID string = hanaSystemId
output PRIVATEIP string = nicName.properties.ipConfigurations[0].properties.privateIPAddress