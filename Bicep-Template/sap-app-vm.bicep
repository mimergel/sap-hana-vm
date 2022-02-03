@description('The VM Name in Azure and OS level that you want to deploy')
param vmNameInput string

@description('The Host Name on OS level that you want to deploy')
param HostNameInput string

@description('SAP System ID.')
@minLength(3)
@maxLength(3)
param sapSystemId string = 'SID'

@description('The type of the operating system you want to deploy.')
@allowed([
  'RHEL 7.7'
  'RHEL 7_9'
  'RHEL 8.1'
  'RHEL 8.2'
  'RHEL 8_4'
  'SLES 12 SP3'
  'SLES 12 SP4'
  'SLES 12 SP5'
  'SLES 15'
  'SLES 15 SP1'
  'SLES 15 SP2'
  'SLES 15 SP3'
  'Windows Server 2012 R2 Datacenter'
  'Windows Server 2016 Datacenter'
  'Windows Server 2019 Datacenter'  
])
param osType string = 'SLES 12 SP4'

@description('The size of the SAP System you want to deploy.')
@allowed([
  'E2ds_v4_16GB'
  'E4ds_v4_32GB'
  'E8ds_v4_64GB'
  'E16ds_v4_128GB'
  'E20ds_v4_160GB'
  'E32ds_v4_256GB'
  'E48ds_v4_384GB'
  'E64ds_v4_504GB'
  'E80ids_v4_504GB'
  'M32ts_192_GB'
  'M32ls_256_GB'
])
param sapSystemSize string = 'E8ds_v4_64GB'

@description('Username for the Virtual Machine.')
param adminUsername string = 'azureuser'

@description('Type of authentication to use on the Virtual Machine.')
@allowed([
  'password'
  'sshPublicKey'
])
param authenticationType string = 'password'

@description('Password or ssh key for the Virtual Machine.')
@secure()
param adminPasswordOrKey string

// @description('The id of the subnet you want to use.')
// param subnetId string
param subnetID string

@description('Zone number. Set to 0 if you do not want to use Availability Zones')
@minValue(0)
@maxValue(3)
param availabilityZone int = 0

@description('Location for all resources.')
param location string = resourceGroup().location

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
  'RHEL 7_9': {
    sku: '79sapha-gen2'
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
    version: 'latest'
  }
  'RHEL 8.2': {
    sku: '82sapha-gen2'
    offer: 'RHEL-SAP-HA'
    publisher: 'RedHat'
    OSType: 'Linux'
    version: 'latest'
  }
  'RHEL 8_4': {
    sku: '84sapha-gen2'
    offer: 'RHEL-SAP-HA'
    publisher: 'RedHat'
    OSType: 'Linux'
    version: 'latest'
  }
  'SLES 12 SP3': {
    sku: '12-sp3'
    offer: 'SLES-SAP'
    publisher: 'SUSE'
    OSType: 'Linux'
    version: 'latest'
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
  'SLES 15': {
    sku: '15-gen2'
    offer: 'SLES-SAP'
    publisher: 'SUSE'
    OSType: 'Linux'
    version: 'latest'
  }
  'SLES 15 SP1': {
    sku: 'gen2'
    offer: 'sles-sap-15-sp1'
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
  'SLES 15 SP3': {
    sku: 'gen2'
    offer: 'sles-sap-15-sp3'
    publisher: 'SUSE'
    OSType: 'Linux'
    version: 'latest'
  }
  'Windows Server 2012 R2 Datacenter': {
    sku: '2012-R2-Datacenter'
    offer: 'WindowsServer'
    publisher: 'MicrosoftWindowsServer'
    version: 'latest'
    OSType: 'Windows'
    UsePlan: false
  }
  'Windows Server 2016 Datacenter': {
    sku: '2016-Datacenter'
    offer: 'WindowsServer'
    publisher: 'MicrosoftWindowsServer'
    version: 'latest'
    OSType: 'Windows'
    UsePlan: false
  }
  'Windows Server 2019 Datacenter': {
    sku: '2019-Datacenter'
    offer: 'WindowsServer'
    publisher: 'MicrosoftWindowsServer'
    version: 'latest'
    OSType: 'Windows'
    UsePlan: false
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
  E2ds_v4_16GB: {
    vmSize: 'Standard_E2ds_v4'
    disks: [
      {
        lun: 0
        name: '${vmName_var}-sapexe-disk'
        caching: 'ReadOnly'
        createOption: 'Empty'
        diskSizeGB: 128
      }
    ]
    scriptArguments: {
      Linux: '-luns \'0\' -names \'sapexe\' -paths \'/home/${sidlower}adm,/sapmnt/${sapSystemId},/usr/sap,/usr/sap/${sapSystemId},/usr/sap/trans,/usr/sap/${sapSystemId}/SUM\' -sizes \'1,2,1,5,20,30\''
    }
    useFastNetwork: true
  }
  E4ds_v4_32GB: {
    vmSize: 'Standard_E4ds_v4'
    disks: [
      {
        lun: 0
        name: '${vmName_var}-sapexe-disk'
        caching: 'ReadOnly'
        createOption: 'Empty'
        diskSizeGB: 256
      }
    ]
    scriptArguments: {
      Linux: '-luns \'0\' -names \'sapexe\' -paths \'/home/${sidlower}adm,/sapmnt/${sapSystemId},/usr/sap,/usr/sap/${sapSystemId},/usr/sap/trans,/usr/sap/${sapSystemId}/SUM\' -sizes \'1,2,1,5,20,30\''
    }
    useFastNetwork: true
  }
  E8ds_v4_64GB: {
    vmSize: 'Standard_E8ds_v4'
    disks: [
      {
        lun: 0
        name: '${vmName_var}-sapexe-disk'
        caching: 'ReadOnly'
        createOption: 'Empty'
        diskSizeGB: 512
      }
    ]
    scriptArguments: {
      Linux: '-luns \'0\' -names \'sapexe\' -paths \'/home/${sidlower}adm,/sapmnt/${sapSystemId},/usr/sap,/usr/sap/${sapSystemId},/usr/sap/trans,/usr/sap/${sapSystemId}/SUM\' -sizes \'1,2,1,5,20,30\''
    }
    useFastNetwork: true
  }
}
var sidlower = toLower(sapSystemId)
var vmName_var = vmNameInput
var HostName = toLower(HostNameInput)
// var vnetName = '${vmName_var}-vnet'
var nicName_var = '${vmName_var}-nic'
// var subnetName = 'Subnet'
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
// var subnets = {
//    subnetIdbool ? resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, subnetName): subnetId
// }
// var selectedSubnetId = subnets[string((length(subnetId) == 0))]

resource nicName 'Microsoft.Network/networkInterfaces@2018-10-01' = {
  name: nicName_var
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: subnetID 
          }
        }
      }
    ]
    enableAcceleratedNetworking: sizes[sapSystemSize].useFastNetwork
  }
}

resource vmName 'Microsoft.Compute/virtualMachines@2018-10-01' = {
  name: vmName_var
  zones: selectedZones
  location: location
  properties: {
    hardwareProfile: {
      vmSize: sizes[sapSystemSize].vmSize
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
        name: '${vmName_var}-osdisk'
        caching: 'ReadWrite'
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Premium_LRS'
        }
      }
      dataDisks: sizes[sapSystemSize].disks
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
  properties: {
    publisher: csExtension[internalOSType].Publisher
    type: csExtension[internalOSType].Name
    typeHandlerVersion: csExtension[internalOSType].Version
    autoUpgradeMinorVersion: true
    settings: {
      fileUris: [
        csExtension[internalOSType].script
      ]
      
      commandToExecute: '${csExtension[internalOSType].scriptCall} ${sizes[sapSystemSize].scriptArguments[internalOSType]}'
    }
  }
}

output SAPVMNAME string = vmName_var
output SAPSID string = sapSystemId
output PRIVATEIP string = nicName.properties.ipConfigurations[0].properties.privateIPAddress
