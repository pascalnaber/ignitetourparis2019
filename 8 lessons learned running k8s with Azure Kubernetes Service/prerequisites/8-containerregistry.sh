#!/bin/bash
set -x -e

# Create Azure Container Registry (replicated)
# Create SPN-registry to pull images from ACR
# SPN-Deploy has access to push images to ACR

az acr create --name $REGISTRY_NAME --resource-group $RESOURCEGROUP_COMMON --sku Premium --admin-enabled false
az acr replication create -r $REGISTRY_NAME -l $REPLICATION_LOCATION

REGISTRY_RESOURCEID=$(az acr show -g $RESOURCEGROUP_COMMON -n $REGISTRY_NAME --query id --output tsv)

# Create SPN-Registry (read access to container registry)

SPNEXISTS=$(az ad sp list --spn "http://$SPN_REGISTRY_NAME" --query [].appId -o tsv)

if [ -z "$SPNEXISTS" ]; then
    SPN_REGISTRY_PASSWORD=$(az ad sp create-for-rbac --name $SPN_REGISTRY_NAME --role Contributor --query password --output tsv)
    az keyvault secret set --vault-name $KEYVAULT_NAME --name spn-registry-password --value $SPN_REGISTRY_PASSWORD
    echo "SPN $SPN_REGISTRY_NAME created"
else
    echo "SPN $SPN_REGISTRY_NAME already exists"
fi

SPN_REGISTRY_ID=$(az ad sp show --id http://$SPN_REGISTRY_NAME --query appId --output tsv)
az keyvault secret set --vault-name $KEYVAULT_NAME --name spn-registry-id --value $SPN_REGISTRY_ID

az role assignment create --assignee http://$SPN_REGISTRY_NAME --scope $REGISTRY_RESOURCEID --role acrpull
az role assignment create --assignee http://$SPN_DEPLOY_NAME --scope $REGISTRY_RESOURCEID --role acrpush
