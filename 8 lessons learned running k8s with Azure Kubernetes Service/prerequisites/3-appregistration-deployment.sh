#!/bin/bash
set -x -e

# Create SPN-Deploy 
# Can be used during the deployment using Azure DevOps for example
# - Contributor to all resourcegroups

SPNEXISTS=$(az ad sp list --spn "http://$SPN_DEPLOY_NAME" --query [].appId -o tsv)

if [ -z "$SPNEXISTS" ]; then
    SPN_DEPLOY_PASSWORD=$(az ad sp create-for-rbac --name $SPN_DEPLOY_NAME --role Contributor --query password --output tsv)
    az keyvault secret set --vault-name $KEYVAULT_NAME --name spn-deploy-password --value $SPN_DEPLOY_PASSWORD
    echo "SPN $SPN_DEPLOY_NAME created"
else
    echo "SPN $SPN_DEPLOY_NAME already exists"
fi

SPN_DEPLOY_ID=$(az ad sp show --id http://$SPN_DEPLOY_NAME --query appId --output tsv)
az keyvault secret set --vault-name $KEYVAULT_NAME --name spn-deploy-id --value $SPN_DEPLOY_ID

RESOURCEGROUP_NETWORK_RESOURCEID=$(az group show -n $RESOURCEGROUP_NETWORK --query id -o tsv)
RESOURCEGROUP_DATA_RESOURCEID=$(az group show -n $RESOURCEGROUP_DATA --query id -o tsv)
RESOURCEGROUP_K8S_RESOURCEID=$(az group show -n $RESOURCEGROUP_K8S --query id -o tsv)
RESOURCEGROUP_KEYVAULT_RESOURCEID=$(az group show -n $RESOURCEGROUP_KEYVAULT --query id -o tsv)
RESOURCEGROUP_COMMON_RESOURCEID=$(az group show -n $RESOURCEGROUP_COMMON --query id -o tsv)

az role assignment create --role Contributor --assignee $SPN_DEPLOY_ID --scope $RESOURCEGROUP_NETWORK_RESOURCEID
az role assignment create --role Contributor --assignee $SPN_DEPLOY_ID --scope $RESOURCEGROUP_DATA_RESOURCEID
az role assignment create --role Contributor --assignee $SPN_DEPLOY_ID --scope $RESOURCEGROUP_K8S_RESOURCEID
az role assignment create --role Contributor --assignee $SPN_DEPLOY_ID --scope $RESOURCEGROUP_KEYVAULT_RESOURCEID
az role assignment create --role Contributor --assignee $SPN_DEPLOY_ID --scope $RESOURCEGROUP_COMMON_RESOURCEID
