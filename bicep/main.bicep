targetScope = 'resourceGroup'

@description('Location for all resources')
param location string = resourceGroup().location

module hub 'bicep/hub.bicep' = {
  name: 'hubDeployment'
  params: {
    location: location
  }
}

module spoke1 'bicep/spoke1.bicep' = {
  name: 'spoke1Deployment'
  params: {
    location: location
    hubVnetId: hub.outputs.vnetId
  }
}

module spoke2 'bicep/spoke2.bicep' = {
  name: 'spoke2Deployment'
  params: {
    location: location
    hubVnetId: hub.outputs.vnetId
  }
}
