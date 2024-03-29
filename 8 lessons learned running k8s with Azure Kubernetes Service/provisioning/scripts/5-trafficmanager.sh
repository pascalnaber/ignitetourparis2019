#!/bin/bash
set -e -x

# Traffic Manager
az network traffic-manager profile create -g $RESOURCEGROUP_NETWORK -n $TRAFFICMANAGER_NAME --routing-method Performance --unique-dns-name $TRAFFICMANAGER_NAME --ttl 30 --protocol HTTP --port 80 --path "/"

NODERESOURCEGROUP=$(az aks show --resource-group $RESOURCEGROUP_K8S --name $AKS_NAME --query nodeResourceGroup -o tsv)

# Get resourceID of public ip address to configure in Traffic Manager 
PUBLICIP_RESOURCEID=$(az network public-ip show -g $NODERESOURCEGROUP -n $IPADDRESS_NAME --query 'id' -o tsv)

# Configure Traffic Manager: add endpoint to public ip address of WAG/WAF
echo "add ipaddress to trafficmanager"
az network traffic-manager endpoint create -g $RESOURCEGROUP_NETWORK --profile-name $TRAFFICMANAGER_NAME --name wagwaf --type azureEndpoints --target-resource-id $PUBLICIP_RESOURCEID
