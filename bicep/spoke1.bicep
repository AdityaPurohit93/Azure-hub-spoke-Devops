@description('Location for Spoke1 VNet')
param location string

@description('Hub VNet resource ID for peering')
param hubVnetId string

resource spokeVnet 'Microsoft.Network/virtualNetworks@2023-04-01' = {
  name: 'SpokeVnet1'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '12.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'WorkloadSubnet'
        properties: {
          addressPrefix: '12.0.2.0/24'
        }
      }
    ]
  }
}

resource spokeToHubPeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-04-01' = {
  name: 'Spoke1ToHub'
  parent: spokeVnet
  properties: {
    remoteVirtualNetwork: {
      id: hubVnetId
    }
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: false
    useRemoteGateways: false
  }
}

resource routeTable 'Microsoft.Network/routeTables@2023-04-01' = {
  name: 'Spoke1RouteTable'
  location: location
  properties: {
    routes: [
      {
        name: 'DefaultToFirewall'
        properties: {
          addressPrefix: '0.0.0.0/0'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: '11.0.1.4' // Firewall Private IP
        }
      }
    ]
  }
}

resource routeAssociation 'Microsoft.Network/virtualNetworks/subnets@2023-04-01' = {
  parent: spokeVnet
  name: 'WorkloadSubnet'
  properties: {
    addressPrefix: '12.0.2.0/24'
    routeTable: {
      id: routeTable.id
    }
  }
}
