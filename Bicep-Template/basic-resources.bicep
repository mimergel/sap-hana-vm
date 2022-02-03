@description('Will be set automatically base on the RG location')
param location string = resourceGroup().location

@description('Enter the admin user name for the Linux & Windows VM')
param adminUsername string = 'azureuser'

@description('Type of authentication to use on the Virtual Machine.')
@allowed([
  'password'
  'sshPublicKey'
])
param authenticationType string = 'sshPublicKey'

@description('Password or ssh key for the Linux VM')
@secure()
param adminPasswordOrKey string

@description('Enter password for the Windows SAP Admin VM')
@secure()
param WindowsPassword string 

@description('Enter your private DNS zone')
param PrivateDNSZoneName string = 'daftpunk.net'

@description('Enter your own script location if required')
param SetupDeploymentAgentScriptURL string = './sap-hana-vm/Scripts/setup-deployment-agent.sh'
param SAPVNETName string = 'vnet-sap-prod-${resourceGroup().location}-001'
param SAPVNETNameAddressSpace array = [
  '10.0.0.0/16'
]
param SAPSubnetName string = 'snet-sap-prod-${resourceGroup().location}-001'
param SAPSubnetAddressRange string = '10.0.0.0/24'
param SAPAdminSubnetName string = 'snet-sap-admin-${resourceGroup().location}-001'
param SAPAdminSubnetAddressRange string = '10.0.3.0/24'
param BastionSubnetName string = 'AzureBastionSubnet'
param BastianSubnetAddressRange string = '10.0.2.0/24'
param bastionHostName string = 'bastion-host-${resourceGroup().location}'
param SAPNSGName string = 'nsg-sap-prod-${resourceGroup().location}-001'
param SAPAdminNSGName string = 'nsg-sap-admin-${resourceGroup().location}-001'
param RecoveryServiceVaultName string = 'rsv-sap-${resourceGroup().location}-001'

@allowed([
  'LocallyRedundant'
  'GeoRedundant'
])
param VaultStorageType string = 'GeoRedundant'
param VaultEnableCRR bool = false
param OSPolicyNamePRD string = 'pol-sapos-prod'
param OSPolicyNameNonPRD string = 'pol-sapos-non-prod'
param HANAPolicyNamePRD string = 'pol-saphana-prod'
param HANAPolicyNameNonPRD string = 'pol-saphana-non-prod'
param DevOpsDeployerVMName string = 'DEVOPSDEPLOYER'
param DevOpsDeployerComputerName string = 'devopsdeployer'
param SAPWinAdminVMName string = 'SAPWINADMIN'
param SAPWinAdminComputerName string = 'sapwinadmin'
param DiskType string = 'Premium_LRS'
param DevOpsDeployerVirtualMachineSize string = 'Standard_B1s'
param SAPWinAdminVirtualMachineSize string = 'Standard_B2s'
param storageAccountNameSAPBits string = 'stsapbits'

@description('Specifies the name of the blob container.')
param storageContainerNameSAPBits string = 'sapbits'
param storageAccountNameDiagnostics string = 'stdiagnostics'
param accountType string = 'Standard_LRS'
param kind string = 'StorageV2'
param accessTier string = 'Cool'
param minimumTlsVersion string = 'TLS1_2'
param supportsHttpsTrafficOnly bool = true
param allowBlobPublicAccess bool = true
param allowSharedKeyAccess bool = true
param networkAclsBypass string = 'AzureServices'
param networkAclsDefaultAction string = 'Deny'
param isContainerRestoreEnabled bool = false
param isBlobSoftDeleteEnabled bool = false
param isContainerSoftDeleteEnabled bool = false
param changeFeed bool = false
param isVersioningEnabled bool = false
param isShareSoftDeleteEnabled bool = false
param ddosProtectionPlanEnabled bool = false
param instantRPDetails object = {}
// param OSbackupManagementType string = 'AzureIaasVM'
param OSBackupSchedule object = {
  schedulePolicyType: 'SimpleSchedulePolicy'
  scheduleRunFrequency: 'Daily'
  scheduleRunDays: null
  scheduleRunTimes: [
    '20.06.2021 18:00:00'
  ]
}
param timeZone string = 'W. Europe Standard Time'
param OSretentionPolicyPRD object = {
  retentionPolicyType: 'LongTermRetentionPolicy'
  dailySchedule: {
    retentionTimes: [
      '20.06.2021 18:00:00'
    ]
    retentionDuration: {
      count: 14
      durationType: 'Days'
    }
  }
  weeklySchedule: {
    daysOfTheWeek: [
      'Sunday'
    ]
    retentionTimes: [
      '20.06.2021 18:00:00'
    ]
    retentionDuration: {
      count: 4
      durationType: 'Weeks'
    }
  }
  monthlySchedule: {
    retentionScheduleFormatType: 'Weekly'
    retentionScheduleDaily: null
    retentionScheduleWeekly: {
      daysOfTheWeek: [
        'Sunday'
      ]
      weeksOfTheMonth: [
        'First'
      ]
    }
    retentionTimes: [
      '20.06.2021 18:00:00'
    ]
    retentionDuration: {
      count: 3
      durationType: 'Months'
    }
  }
  yearlySchedule: {
    retentionScheduleFormatType: 'Weekly'
    monthsOfYear: [
      'January'
    ]
    retentionScheduleDaily: null
    retentionScheduleWeekly: {
      daysOfTheWeek: [
        'Sunday'
      ]
      weeksOfTheMonth: [
        'First'
      ]
    }
    retentionTimes: [
      '20.06.2021 18:00:00'
    ]
    retentionDuration: {
      count: 1
      durationType: 'Years'
    }
  }
}
param OSretentionPolicyNonPRD object = {
  retentionPolicyType: 'LongTermRetentionPolicy'
  dailySchedule: {
    retentionTimes: [
      '20.06.2021 18:00:00'
    ]
    retentionDuration: {
      count: 14
      durationType: 'Days'
    }
  }
  weeklySchedule: null
  monthlySchedule: null
  yearlySchedule: null
}
param instantRpRetentionRangeInDays int = 3
param hanabackupsettings object = {
  timeZone: 'W. Europe Standard Time'
  issqlcompression: false
  isCompression: false
}
param HANAsubProtectionPolicyListPRD array = [
  {
    policyType: 'Full'
    schedulePolicy: {
      schedulePolicyType: 'SimpleSchedulePolicy'
      scheduleRunFrequency: 'Daily'
      scheduleRunDays: null
      scheduleRunTimes: [
        '19.06.2021 21:00:00'
      ]
    }
    retentionPolicy: {
      retentionPolicyType: 'LongTermRetentionPolicy'
      dailySchedule: {
        retentionTimes: [
          '19.06.2021 21:00:00'
        ]
        retentionDuration: {
          count: 14
          durationType: 'Days'
        }
      }
      weeklySchedule: {
        daysOfTheWeek: [
          'Sunday'
        ]
        retentionTimes: [
          '19.06.2021 21:00:00'
        ]
        retentionDuration: {
          count: 4
          durationType: 'Weeks'
        }
      }
      monthlySchedule: {
        retentionScheduleFormatType: 'Weekly'
        retentionScheduleDaily: null
        retentionScheduleWeekly: {
          daysOfTheWeek: [
            'Sunday'
          ]
          weeksOfTheMonth: [
            'First'
          ]
        }
        retentionTimes: [
          '19.06.2021 21:00:00'
        ]
        retentionDuration: {
          count: 3
          durationType: 'Months'
        }
      }
      yearlySchedule: {
        retentionScheduleFormatType: 'Weekly'
        monthsOfYear: [
          'January'
        ]
        retentionScheduleDaily: null
        retentionScheduleWeekly: {
          daysOfTheWeek: [
            'Sunday'
          ]
          weeksOfTheMonth: [
            'First'
          ]
        }
        retentionTimes: [
          '19.06.2021 21:00:00'
        ]
        retentionDuration: {
          count: 1
          durationType: 'Years'
        }
      }
    }
  }
  {
    policyType: 'Log'
    schedulePolicy: {
      schedulePolicyType: 'LogSchedulePolicy'
      scheduleFrequencyInMins: 15
    }
    retentionPolicy: {
      retentionPolicyType: 'SimpleRetentionPolicy'
      retentionDuration: {
        count: 14
        durationType: 'Days'
      }
    }
  }
]
param HANAsubProtectionPolicyListNonPRD array = [
  {
    policyType: 'Full'
    schedulePolicy: {
      schedulePolicyType: 'SimpleSchedulePolicy'
      scheduleRunFrequency: 'Daily'
      scheduleRunDays: null
      scheduleRunTimes: [
        '19.06.2021 21:00:00'
      ]
    }
    retentionPolicy: {
      retentionPolicyType: 'LongTermRetentionPolicy'
      dailySchedule: {
        retentionTimes: [
          '19.06.2021 21:00:00'
        ]
        retentionDuration: {
          count: 7
          durationType: 'Days'
        }
      }
      weeklySchedule: null
      monthlySchedule: null
      yearlySchedule: null
    }
  }
  {
    policyType: 'Log'
    schedulePolicy: {
      schedulePolicyType: 'LogSchedulePolicy'
      scheduleFrequencyInMins: 120
    }
    retentionPolicy: {
      retentionPolicyType: 'SimpleRetentionPolicy'
      retentionDuration: {
        count: 7
        durationType: 'Days'
      }
    }
  }
]

var resourcegroupId = resourceGroup().id
var bastionPublicIPName_var = '${bastionHostName}pip'
var shortlocation = take(resourceGroup().location, 10)
var storageAccountNameSAPBits_var = '${storageAccountNameSAPBits}${shortlocation}'
var storageAccountNameDiagnostics_var = '${storageAccountNameDiagnostics}${shortlocation}'
var vmRegistration = true
var VARnetworkAclsVirtualNetworkRules = [
  {
    id: '${resourcegroupId}/providers/Microsoft.Network/virtualNetworks/${SAPVNETName}/subnets/${SAPSubnetName}'
  }
  {
    id: '${resourcegroupId}/providers/Microsoft.Network/virtualNetworks/${SAPVNETName}/subnets/${SAPAdminSubnetName}'
  }
]
var DevOpsDeployerNWInterfaceName_var = '${DevOpsDeployerVMName}-nic'
var SAPWinAdminNWInterfaceName_var = '${SAPWinAdminVMName}-nic'
var DevOpsDeployerOS = 'Linux'
var DevOpsDeployerCSExtension = {
  Linux: {
    Publisher: 'Microsoft.Azure.Extensions'
    Name: 'CustomScript'
    Version: '2.0'
    script: SetupDeploymentAgentScriptURL
    scriptCall: 'sh setup-deployment-agent.sh ${adminUsername}'
  }
}
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

resource SAPNSGName_resource 'Microsoft.Network/networkSecurityGroups@2019-02-01' = {
  name: SAPNSGName
  location: location
  tags: {}
  properties: {
    securityRules: [
      {
        name: 'RDP'
        properties: {
          description: 'Allow RDP'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '3389'
          sourceAddressPrefix: 'Internet'
          destinationAddressPrefix: '*'
          access: 'Deny'
          priority: 100
          direction: 'Inbound'
        }
      }
      {
        name: 'SSH'
        properties: {
          description: 'Allow SSH'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '22'
          sourceAddressPrefix: 'Internet'
          destinationAddressPrefix: '*'
          access: 'Deny'
          priority: 200
          direction: 'Inbound'
        }
      }
      {
        name: 'Allow-Inbound-HTTPS'
        properties: {
          description: 'Allows inbound traffic for HTTPS'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 300
          direction: 'Inbound'
        }
      }
      {
        name: 'Allow-SAP'
        properties: {
          description: 'Allows inbound traffic for SAP'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '3200'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 400
          direction: 'Inbound'
        }
      }
    ]
  }
}

resource SAPAdminNSGName_resource 'Microsoft.Network/networkSecurityGroups@2019-02-01' = {
  name: SAPAdminNSGName
  location: location
  tags: {}
  properties: {
    securityRules: [
      {
        name: 'RDP'
        properties: {
          description: 'Allow RDP'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '3389'
          sourceAddressPrefix: 'Internet'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
        }
      }
      {
        name: 'SSH'
        properties: {
          description: 'Allow SSH'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '22'
          sourceAddressPrefix: 'Internet'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 200
          direction: 'Inbound'
        }
      }
    ]
  }
}

resource bastionPublicIPName 'Microsoft.Network/publicIPAddresses@2020-05-01' = {
  name: bastionPublicIPName_var
  location: location
  properties: {
    publicIPAllocationMethod: 'Static'
  }
  sku: {
    name: 'Standard'
  }
}

resource bastionHostName_resource 'Microsoft.Network/bastionHosts@2020-05-01' = {
  name: bastionHostName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'bastionipconfig'
        properties: {
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', SAPVNETName, BastionSubnetName)
          }
          publicIPAddress: {
            id: bastionPublicIPName.id
          }
          privateIPAllocationMethod: 'Dynamic'
        }
      }
    ]
  }
  dependsOn: [
    SAPVNETName_resource
  ]
}

resource RecoveryServiceVaultName_resource 'Microsoft.RecoveryServices/vaults@2021-08-01' = {
  name: RecoveryServiceVaultName
  location: location
  sku: {
    name: 'RS0'
    tier: 'Standard'
  }
  properties: {}
}

resource RecoveryServiceVaultName_OSPolicyNamePRD 'Microsoft.RecoveryServices/vaults/backupPolicies@2021-10-01' = {
  parent: RecoveryServiceVaultName_resource
  name: OSPolicyNamePRD
  properties: {
    backupManagementType: 'AzureIaasVM'
    instantRpRetentionRangeInDays: instantRpRetentionRangeInDays
    schedulePolicy: OSBackupSchedule
    timeZone: timeZone
    retentionPolicy: OSretentionPolicyPRD
    instantRPDetails: instantRPDetails
  }
}

resource RecoveryServiceVaultName_OSPolicyNameNonPRD 'Microsoft.RecoveryServices/vaults/backupPolicies@2021-10-01' = {
  parent: RecoveryServiceVaultName_resource
  name: OSPolicyNameNonPRD
  properties: {
    backupManagementType: 'AzureIaasVM'
    instantRpRetentionRangeInDays: 3
    schedulePolicy: OSBackupSchedule
    timeZone: timeZone
    retentionPolicy: OSretentionPolicyNonPRD
    instantRPDetails: instantRPDetails
  }
}

resource RecoveryServiceVaultName_HANAPolicyNamePRD 'Microsoft.RecoveryServices/vaults/backupPolicies@2021-10-01' = {
  parent: RecoveryServiceVaultName_resource
  name: HANAPolicyNamePRD
  properties: {
    backupManagementType: 'AzureWorkload'
    workLoadType: 'SAPHanaDatabase'
    settings: hanabackupsettings
    subProtectionPolicy: HANAsubProtectionPolicyListPRD
  }
}

resource RecoveryServiceVaultName_HANAPolicyNameNonPRD 'Microsoft.RecoveryServices/vaults/backupPolicies@2021-10-01' = {
  parent: RecoveryServiceVaultName_resource
  name: HANAPolicyNameNonPRD
  properties: {
    backupManagementType: 'AzureWorkload'
    workLoadType: 'SAPHanaDatabase'
    settings: hanabackupsettings
    subProtectionPolicy: HANAsubProtectionPolicyListNonPRD
  }
}

resource PrivateDNSZoneName_resource 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: PrivateDNSZoneName
  location: 'global'
  tags: {}
  properties: {}
  dependsOn: []
}

resource PrivateDNSZoneName_PrivateDNSZoneName_link 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: PrivateDNSZoneName_resource
  name: '${PrivateDNSZoneName}-link'
  location: 'global'
  properties: {
    registrationEnabled: vmRegistration
    virtualNetwork: {
      id: SAPVNETName_resource.id
    }
  }
}

resource RecoveryServiceVaultName_vaultstorageconfig 'Microsoft.RecoveryServices/vaults/backupstorageconfig@2021-10-01' = {
  parent: RecoveryServiceVaultName_resource
  name: 'vaultstorageconfig'
  properties: {
    storageModelType: VaultStorageType
    crossRegionRestoreFlag: VaultEnableCRR
  }
}

resource SAPVNETName_resource 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: SAPVNETName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: SAPVNETNameAddressSpace
    }
    subnets: [
      {
        name: SAPSubnetName
        properties: {
          addressPrefix: SAPSubnetAddressRange
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
          serviceEndpoints: [
            {
              service: 'Microsoft.Storage'
            }
          ]
          networkSecurityGroup: {
            id: SAPNSGName_resource.id
          }
        }
        type: 'Microsoft.Network/virtualNetworks/subnets'
      }
      {
        name: SAPAdminSubnetName
        properties: {
          addressPrefix: SAPAdminSubnetAddressRange
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
          serviceEndpoints: [
            {
              service: 'Microsoft.Storage'
            }
          ]
          networkSecurityGroup: {
            id: SAPAdminNSGName_resource.id
          }
        }
        type: 'Microsoft.Network/virtualNetworks/subnets'
      }
      {
        type: 'Microsoft.Network/virtualNetworks/subnets'
        name: BastionSubnetName
        properties: {
          addressPrefix: BastianSubnetAddressRange
        }
      }
    ]
    virtualNetworkPeerings: []
    enableDdosProtection: ddosProtectionPlanEnabled
  }
  tags: {}
}

resource storageAccountNameSAPBits_resource 'Microsoft.Storage/storageAccounts@2021-06-01' = {
  name: storageAccountNameSAPBits_var
  location: location
  tags: {}
  sku: {
    name: accountType
  }
  kind: kind
  properties: {
    accessTier: accessTier
    minimumTlsVersion: minimumTlsVersion
    supportsHttpsTrafficOnly: supportsHttpsTrafficOnly
    allowBlobPublicAccess: allowBlobPublicAccess
    allowSharedKeyAccess: allowSharedKeyAccess
    networkAcls: {
      bypass: networkAclsBypass
      defaultAction: networkAclsDefaultAction
      ipRules: []
      virtualNetworkRules: VARnetworkAclsVirtualNetworkRules
    }
    resources: [
      {
        type: 'blobServices/containers'
        apiVersion: '2019-06-01'
        name: 'default/${storageContainerNameSAPBits}'
        dependsOn: [
          storageAccountNameSAPBits_var
        ]
      }
    ]
  }
  dependsOn: [
    SAPVNETName_resource
  ]
}

resource storageAccountNameDiagnostics_resource 'Microsoft.Storage/storageAccounts@2021-06-01' = {
  name: storageAccountNameDiagnostics_var
  location: location
  tags: {}
  sku: {
    name: accountType
  }
  kind: kind
  properties: {
    accessTier: accessTier
    minimumTlsVersion: minimumTlsVersion
    supportsHttpsTrafficOnly: supportsHttpsTrafficOnly
    allowBlobPublicAccess: allowBlobPublicAccess
    allowSharedKeyAccess: allowSharedKeyAccess
    networkAcls: {
      bypass: networkAclsBypass
      defaultAction: networkAclsDefaultAction
    }
  }
  dependsOn: []
}

resource storageAccountNameSAPBits_default 'Microsoft.Storage/storageAccounts/blobServices@2021-06-01' = {
  parent: storageAccountNameSAPBits_resource
  name: 'default'
  properties: {
    restorePolicy: {
      enabled: isContainerRestoreEnabled
    }
    deleteRetentionPolicy: {
      enabled: isBlobSoftDeleteEnabled
    }
    containerDeleteRetentionPolicy: {
      enabled: isContainerSoftDeleteEnabled
    }
    changeFeed: {
      enabled: changeFeed
    }
    isVersioningEnabled: isVersioningEnabled
  }
}

resource Microsoft_Storage_storageAccounts_fileservices_storageAccountNameSAPBits_default 'Microsoft.Storage/storageAccounts/fileServices@2021-06-01' = {
  parent: storageAccountNameSAPBits_resource
  name: 'default'
  properties: {
    shareDeleteRetentionPolicy: {
      enabled: isShareSoftDeleteEnabled
    }
  }
  dependsOn: [
    storageAccountNameSAPBits_default
  ]
}

resource DevOpsDeployerNWInterfaceName 'Microsoft.Network/networkInterfaces@2021-05-01' = {
  name: DevOpsDeployerNWInterfaceName_var
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'devopsdeployeripconfig'
        properties: {
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', SAPVNETName, SAPAdminSubnetName)
          }
          privateIPAllocationMethod: 'Dynamic'
        }
      }
    ]
  }
  dependsOn: [
    SAPVNETName_resource
  ]
}

resource DevOpsDeployerVMName_resource 'Microsoft.Compute/virtualMachines@2021-07-01' = {
  name: DevOpsDeployerVMName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: DevOpsDeployerVirtualMachineSize
    }
    storageProfile: {
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: DiskType
        }
      }
      imageReference: {
        publisher: 'Canonical'
        offer: 'UbuntuServer'
        sku: '18.04-LTS'
        version: 'latest'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: DevOpsDeployerNWInterfaceName.id
        }
      ]
    }
    osProfile: {
      computerName: DevOpsDeployerComputerName
      adminUsername: adminUsername
      adminPassword: adminPasswordOrKey
      linuxConfiguration: ((authenticationType == 'password') ? json('null') : linuxConfiguration)
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: false
      }
    }
  }
}

resource DevOpsDeployerVMName_DevOpsDeployerCSExtension_DevOpsDeployerOS_Name 'Microsoft.Compute/virtualMachines/extensions@2021-07-01' = {
  parent: DevOpsDeployerVMName_resource
  name: '${DevOpsDeployerCSExtension[DevOpsDeployerOS].Name}'
  location: location
  properties: {
    publisher: DevOpsDeployerCSExtension[DevOpsDeployerOS].Publisher
    type: DevOpsDeployerCSExtension[DevOpsDeployerOS].Name
    typeHandlerVersion: DevOpsDeployerCSExtension[DevOpsDeployerOS].Version
    autoUpgradeMinorVersion: true
    settings: {
      fileUris: [
        DevOpsDeployerCSExtension[DevOpsDeployerOS].script
      ]
      commandToExecute: DevOpsDeployerCSExtension[DevOpsDeployerOS].scriptCall
    }
  }
}

resource SAPWinAdminNWInterfaceName 'Microsoft.Network/networkInterfaces@2021-05-01' = {
  name: SAPWinAdminNWInterfaceName_var
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'sapwinadminipconfig'
        properties: {
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', SAPVNETName, SAPAdminSubnetName)
          }
          privateIPAllocationMethod: 'Dynamic'
        }
      }
    ]
  }
  dependsOn: [
    SAPVNETName_resource
  ]
}

resource SAPWinAdminVMName_resource 'Microsoft.Compute/virtualMachines@2021-07-01' = {
  name: SAPWinAdminVMName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: SAPWinAdminVirtualMachineSize
    }
    storageProfile: {
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: DiskType
        }
      }
      imageReference: {
        publisher: 'MicrosoftWindowsDesktop'
        offer: 'Windows-10'
        sku: '21h1-pro'
        version: 'latest'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: SAPWinAdminNWInterfaceName.id
        }
      ]
    }
    osProfile: {
      computerName: SAPWinAdminComputerName
      adminUsername: adminUsername
      adminPassword: WindowsPassword
      windowsConfiguration: {
        enableAutomaticUpdates: true
        provisionVMAgent: true
        patchSettings: {
          enableHotpatching: false
          patchMode: 'AutomaticByOS'
        }
      }
    }
    licenseType: 'Windows_Client'
  }
}

output subnetID string = SAPVNETName_resource.properties.subnets[0].id
