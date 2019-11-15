#!/bin/bash
set -x -e

# Create SPN-AKS
# Needed during the provisioning of AKS

SPNEXISTS=$(az ad sp list --spn "http://$SPN_AKS_NAME" --query [].appId -o tsv)

if [ -z "$SPNEXISTS" ]; then
    SPN_AKS_PASSWORD=$(az ad sp create-for-rbac --name $SPN_AKS_NAME --role Contributor --query password --output tsv)
    az keyvault secret set --vault-name $KEYVAULT_NAME --name spn-aks-password --value $SPN_AKS_PASSWORD
    echo "SPN $SPN_AKS_NAME created"
else
    echo "SPN $SPN_AKS_NAME already exists"
fi

SPN_AKS_ID=$(az ad sp show --id http://$SPN_AKS_NAME --query appId --output tsv)
az keyvault secret set --vault-name $KEYVAULT_NAME --name spn-aks-id --value $SPN_AKS_ID

RESOURCEGROUP_K8S_RESOURCEID=$(az group show -n $RESOURCEGROUP_K8S --query id -o tsv)
az role assignment create --role Contributor --assignee $SPN_AKS_ID --scope $RESOURCEGROUP_K8S_RESOURCEID

SPN_DEPLOY_ID=$(az ad sp show --id http://$SPN_DEPLOY_NAME --query appId --output tsv)

# Give Deployment service principal rights to VNET for AKS
az role assignment create --assignee $SPN_DEPLOY_ID --role "Network Contributor"

set +e
az keyvault secret show --vault-name $KEYVAULT_NAME --name ssh-publickeys > /dev/null 
if [ $? -eq 3 ];
then  
    
    # Generate SSH Key for AKS With generated password. If key already exists, it will be reused.
    SSH_PASSWORD=$(openssl rand -base64 32)
    ssh-keygen -C "matrix" -f ~/.ssh/id_rsa -P $SSH_PASSWORD -q 0>&-
    echo $?
    set -e
    # Add SSH keys to Keyvault
    az keyvault secret set --vault-name $KEYVAULT_NAME --name ssh-publickey -f ~/.ssh/id_rsa.pub 
    az keyvault secret set --vault-name $KEYVAULT_NAME --name ssh-privatekey -f ~/.ssh/id_rsa
    az keyvault secret set --vault-name $KEYVAULT_NAME --name ssh-password --value "$SSH_PASSWORD"
fi

# Password must have 3 of the following: 1 lower case character, 1 upper case character, 1 number, and 1 special character between 12 and 72 characters long
# apt install pwgen
# pwgen 14 1 -n 1 -c 1 -y 1
az keyvault secret set --vault-name $KEYVAULT_NAME --name aks-windows-admin-password --value '!'$(gpg --gen-random --armor 1 14)
az keyvault secret set --vault-name $KEYVAULT_NAME --name aks-windows-admin-password --value 'P@ssw0rd1234'


