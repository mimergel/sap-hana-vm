@description('The VM Name in Azure and OS level that you want to deploy')
param vmNameInput string

@description('HANA System ID.')
@minLength(3)
@maxLength(3)
param hanaSystemId string = 'HDB'

@description('The type of the operating system you want to deploy.')
@allowed([
  'RHEL 7'
  'RHEL 8'
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
  '128_GB-Non-PRD'
  '160_GB-Non-PRD'
  '192_GB'
  '256_GB'
  '512_GB'
  '1.000_GB'
  '1.792_GB'
  '2.000_GB'
  '2.850_GB'
  '3.892_GB'
  '5.700_GB'
  '11.400_GB'
])
param hanaSystemSize string = '192_GB'

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
param Backup string = 'Non-PRD'

@description('URL of storage account for boot diagnostics')
param Boot_Diag_URL string = 'https://saponazuretrialdiag.blob.core.windows.net'

@description('URL of the disk configuration script')
param Script_URL string = 'https://raw.githubusercontent.com/mimergel/sap-hana-vm/main/Scripts/diskConfig.sh'

var selectedZones = ((availabilityZone == 0) ? json('null') : array(availabilityZone))
var images = {
  'RHEL 7': {
    sku: '77sapha-gen2'
    offer: 'RHEL-SAP-HA'
    publisher: 'RedHat'
    OSType: 'Linux'
  }
  'RHEL 8': {
    sku: '81sapha-gen2'
    offer: 'RHEL-SAP-HA'
    publisher: 'RedHat'
    OSType: 'Linux'
  }
  'SLES 12 SP4': {
    sku: '12-sp4-gen2'
    offer: 'SLES-SAP'
    publisher: 'SUSE'
    OSType: 'Linux'
  }
  'SLES 12 SP5': {
    sku: 'gen2'
    offer: 'sles-sap-12-sp5'
    publisher: 'SUSE'
    OSType: 'Linux'
  }
  'SLES 15 SP2': {
    sku: 'gen2'
    offer: 'sles-sap-15-sp2'
    publisher: 'SUSE'
    OSType: 'Linux'
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
  '128_GB-Non-PRD': {
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
  '160_GB-Non-PRD': {
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
          createOption: 'Empty'
          diskSizeGB: 128
        }
        {
          lun: 6
          name: '${vmName_var}-log2-disk'
          caching: 'None'
          createOption: 'Empty'
          diskSizeGB: 128
        }
        {
          lun: 7
          name: '${vmName_var}-log3-disk'
          caching: 'None'
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
  '192_GB': {
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
  '256_GB': {
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
  '512_GB': {
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
  '1.000_GB': {
    HANA: {
      vmSize: 'Standard_M64s'
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
  '1.792_GB': {
    HANA: {
      vmSize: 'Standard_M64ms'
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
  '2.000_GB': {
    HANA: {
      vmSize: 'Standard_M128s'
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
  '2.850_GB': {
    HANA: {
      vmSize: 'Standard_M208sv2'
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
  '3.892_GB': {
    HANA: {
      vmSize: 'Standard_M128ms'
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
  '5.700_GB': {
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
  '11.400_GB': {
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
var vmName_var = toLower(vmNameInput)
var vnetName_var = '${vmName_var}-vnet'
var publicIpName_var = '${vmName_var}-pib'
var nicName_var = '${vmName_var}-nic'
var nsgName_var = '${vmName_var}-nsg-cs'
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
var osSecurityRules = {
  Windows: [
    {
      name: 'RDP'
      properties: {
        description: 'Allow RDP Subnet'
        protocol: 'Tcp'
        sourcePortRange: '*'
        destinationPortRange: '3389'
        sourceAddressPrefix: '*'
        destinationAddressPrefix: '*'
        access: 'Allow'
        priority: 100
        direction: 'Inbound'
      }
    }
  ]
  Linux: [
    {
      name: 'SSH'
      properties: {
        description: 'Allow SSH Subnet'
        protocol: 'Tcp'
        sourcePortRange: '*'
        destinationPortRange: '22'
        sourceAddressPrefix: '*'
        destinationAddressPrefix: '*'
        access: 'Allow'
        priority: 100
        direction: 'Inbound'
      }
    }
  ]
}
var selectedSecurityRules = osSecurityRules[internalOSType]
// var subnets = {
//   true: resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName_var, subnetName)
//   false: subnetId
// }
// var selectedSubnetId = subnets[string((length(subnetId) == 0))]

resource nsgName 'Microsoft.Network/networkSecurityGroups@2018-10-01' = if (length(subnetId) == 0) {
  name: concat(nsgName_var)
  location: location
  tags: {
    'cost-center': CostCenter
    application: 'SAP'
    owner: Owner
    'cmdb-link': 'https://tbd.'
  }
  properties: {
    securityRules: selectedSecurityRules
  }
}

resource vnetName 'Microsoft.Network/virtualNetworks@2018-10-01' = if (length(subnetId) == 0) {
  name: vnetName_var
  location: location
  tags: {
    'cost-center': CostCenter
    application: 'SAP'
    owner: Owner
    'cmdb-link': 'https://tbd.'
  }
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: '10.0.0.0/24'
          networkSecurityGroup: {
            id: nsgName.id
          }
        }
      }
    ]
  }
}

resource publicIpName 'Microsoft.Network/publicIPAddresses@2018-10-01' = if (length(subnetId) == 0) {
  name: publicIpName_var
  location: location
  tags: {
    'cost-center': CostCenter
    application: 'SAP'
    owner: Owner
    'cmdb-link': 'https://tbd.'
  }
  properties: {
    publicIPAllocationMethod: 'Dynamic'
  }
  dependsOn: [
    vnetName
  ]
}

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
          publicIPAddress: ((length(subnetId) == 0) ? json('{"id": "${publicIpName.id}"}') : json('null'))
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName_var, subnetName)
          }
        }
      }
    ]
    enableAcceleratedNetworking: sizes[hanaSystemSize][dbType].useFastNetwork
  }
  dependsOn: [
    vnetName
  ]
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
    HANABackup: Backup
  }
  properties: {
    hardwareProfile: {
      vmSize: sizes[hanaSystemSize][dbType].vmSize
    }
    osProfile: {
      computerName: vmName_var
      adminUsername: adminUsername
      adminPassword: adminPasswordOrKey
      linuxConfiguration: ((authenticationType == 'password') ? json('null') : linuxConfiguration)
    }
    storageProfile: {
      imageReference: {
        publisher: images[osType].publisher
        offer: images[osType].offer
        sku: images[osType].sku
        version: 'latest'
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
        storageUri: Boot_Diag_URL
        enabled: true
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
