@description('Location for hub resources')
param location string

// 1. Create the Hub Virtual Network
resource hubVnet 'Microsoft.Network/virtualNetworks@2023-04-01' = {
  name: 'HubVnet'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '11.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'AzureFirewallSubnet'
        properties: {
          addressPrefix: '11.0.1.0/24'
        }
      }
    ]
  }
}

// 2. Create Public IP for Firewall
resource firewallPublicIP 'Microsoft.Network/publicIPAddresses@2023-04-01' = {
  name: 'FirewallPublicIP'
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

// 3. Create Azure Firewall (without invalid NAT rules here)
resource firewall 'Microsoft.Network/azureFirewalls@2023-04-01' = {
  name: 'CentralFirewall'
  location: location
  properties: {
    sku: {
      name: 'AZFW_VNet'
      tier: 'Standard'
    }
    ipConfigurations: [
      {
        name: 'fwConfig'
        properties: {
          subnet: {
            id: hubVnet.properties.subnets[0].id
          }
          publicIPAddress: {
            id: firewallPublicIP.id
          }
        }
      }
    ]
  }
}

// 4. Output IDs for use in other modules
output vnetId string = hubVnet.id
output firewallId string = firewall.id
output firewallPublicIpId string = firewallPublicIP.id
output firewallPublicIp string = firewallPublicIP.properties.ipAddress
