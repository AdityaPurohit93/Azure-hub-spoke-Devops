@description('Location for firewall rules')
param location string

@description('Name of the existing firewall')
param firewallName string = 'CentralFirewall'

@description('Private IP of the target VM in the spoke network')
param targetVmPrivateIp string = '12.0.2.4'

@description('Public IP address of the firewall (must already exist)')
param firewallPublicIp string

resource firewall 'Microsoft.Network/azureFirewalls@2023-04-01' existing = {
  name: firewallName
}

resource dnatRule 'Microsoft.Network/azureFirewalls/natRuleCollections@2023-04-01' = {
  name: 'RdpAccessCollection'
  parent: firewall
  properties: {
    priority: 100
    action: {
      type: 'Dnat'
    }
    ruleCollectionType: 'FirewallPolicy'
    rules: [
      {
        name: 'AllowRDPViaFirewall'
        ruleType: 'DNAT'
        ipProtocols: [
          'TCP'
        ]
        sourceAddresses: [
          '*'
        ]
        destinationAddresses: [
          firewallPublicIp
        ]
        destinationPorts: [
          '3389'
        ]
        translatedAddress: targetVmPrivateIp
        translatedPort: '3389'
      }
    ]
  }
}
