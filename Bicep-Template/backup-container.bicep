param vaultName string
param vaultRG string
param vaultSubID string
param backupManagementType string = 'AzureWorkload'
param workloadType string = 'SAPHanaDatabase'
param fabricName string = 'Azure'
param protectionContainers array = [
  'VMAppContainer;Compute;rg-of-vm;vmname'
]
param protectionContainerTypes array = [
  'VMAppContainer'
]
param sourceResourceIds array
param operationType string = 'Register'

resource vaultName_fabricName_protectionContainers 'Microsoft.RecoveryServices/vaults/backupFabrics/protectionContainers@2021-10-01' = [for (item, i) in protectionContainers: {
  name: '${vaultName}/${fabricName}/${item}'
  properties: {
    backupManagementType: backupManagementType
    workloadType: workloadType
    containerType: protectionContainerTypes[i]
    sourceResourceId: sourceResourceIds[i]
    operationType: operationType
  }
}]
