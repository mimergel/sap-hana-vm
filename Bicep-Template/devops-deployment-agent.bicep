param location string = resourceGroup().location
param subnetId string = '/subscriptions/5fd3d14e-3648-4720-99ee-f9e14261f9d7/resourceGroups/VNETRG/providers/Microsoft.Network/virtualNetworks/VNETNAME/subnets/SUBNETNAME'
param DevOpsDeployerVMName string = 'DEVOPSDEPLOYER'
param DevOpsDeployerComputerName string = 'devopsdeployer'
param DevOpsDeployerosDiskType string = 'Premium_LRS'
param DevOpsDeployerosvirtualMachineSize string = 'Standard_B1s'
param adminUsername string = 'azureuser'

@secure()
param adminPublicKey string
param Script_URL string = './sap-hana-vm/Scripts/setup-deployment-agent.sh'
param Owner string = 'Contact'
param CostCenter string = '123456'

var DevOpsDeployerNWInterfaceName_var = '${DevOpsDeployerVMName}-nic'
var DevOpsDeployerOS = 'Linux'
var DevOpsDeployerCSExtension = {
  Linux: {
    Publisher: 'Microsoft.Azure.Extensions'
    Name: 'CustomScript'
    Version: '2.0'
    script: Script_URL
    scriptCall: 'sh setup-deployment-agent.sh ${adminUsername}'
  }
}

resource DevOpsDeployerNWInterfaceName 'Microsoft.Network/networkInterfaces@2021-05-01' = {
  name: DevOpsDeployerNWInterfaceName_var
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
          subnet: {
            id: subnetId
          }
          privateIPAllocationMethod: 'Dynamic'
        }
      }
    ]
  }
  dependsOn: []
}

resource DevOpsDeployerVMName_resource 'Microsoft.Compute/virtualMachines@2021-07-01' = {
  name: DevOpsDeployerVMName
  location: location
  tags: {
    'cost-center': CostCenter
    application: 'SAP'
    owner: Owner
    'cmdb-link': 'https://tbd.'
  }
  properties: {
    hardwareProfile: {
      vmSize: DevOpsDeployerosvirtualMachineSize
    }
    storageProfile: {
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: DevOpsDeployerosDiskType
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
      linuxConfiguration: {
        disablePasswordAuthentication: true
        ssh: {
          publicKeys: [
            {
              path: '/home/${adminUsername}/.ssh/authorized_keys'
              keyData: adminPublicKey
            }
          ]
        }
      }
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
  tags: {
    'cost-center': CostCenter
    application: 'SAP'
    owner: Owner
    'cmdb-link': 'https://tbd.'
  }
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

output adminUsername string = adminUsername
