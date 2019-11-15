#!/bin/bash

# Install the aks-preview extension
az extension add --name aks-preview

set +e
# Update the extension to make sure you have the latest version installed
az extension update --name aks-preview
set -e

# Register Windows preview feature
az feature register --name WindowsPreview --namespace Microsoft.ContainerService

# Wait till the preview is Registered
echo "Waiting till preview is registered"
while [ $(az feature list -o tsv --query "[?contains(name, 'Microsoft.ContainerService/WindowsPreview')].properties.state") != "Registered" ]
do    
    echo -n "."
    sleep 5   
done
echo "Preview is registered"

# when status is Registered Register the namespace again
az provider register --namespace Microsoft.ContainerService