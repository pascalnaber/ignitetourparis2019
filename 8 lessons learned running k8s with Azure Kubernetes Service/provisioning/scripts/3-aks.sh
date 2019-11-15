#!/bin/bash
set -e -x

# Get ResourceId from aks-subnet
AKSSUBNETID=$(az network vnet subnet show -g $RESOURCEGROUP_NETWORK -n aks-subnet --vnet-name $VNET_NAME --query id --output tsv)

WORKSPACE_RESOURCEID=$(az resource show -g $RESOURCEGROUP_K8S -n $WORKSPACE_NAME --resource-type "Microsoft.OperationalInsights/workspaces" --query 'id' -o tsv)
echo workspace_resourceid: $WORKSPACE_RESOURCEID

# Create AKS
az aks create -g $RESOURCEGROUP_K8S -n $AKS_NAME \
  --kubernetes-version $AKS_VERSION \
  --node-count $AKS_NODE_COUNT \
  --node-vm-size $AKS_VM_SIZE \
  --max-pods 110 \
  --ssh-key-value "$(az keyvault secret show --name ssh-publickey --vault-name $KEYVAULT_NAME --query value -o tsv)" \
  --service-principal $(az keyvault secret show --name spn-aks-id --vault-name $KEYVAULT_NAME --query value -o tsv) \
  --client-secret "$(az keyvault secret show --name spn-aks-password --vault-name $KEYVAULT_NAME --query value -o tsv)" \
  --network-plugin azure \
  --vnet-subnet-id $AKSSUBNETID \
  --docker-bridge-address 172.17.0.1/16 \
  --dns-service-ip 10.2.0.10 \
  --service-cidr 10.2.0.0/24 \
  --enable-addons monitoring \
  --workspace-resource-id $WORKSPACE_RESOURCEID \
  --nodepool-name "linuxpool" \
  --windows-admin-password "$(az keyvault secret show --name aks-windows-admin-password --vault-name $KEYVAULT_NAME --query value -o tsv)" \
  --windows-admin-username azureuser \
  --vm-set-type VirtualMachineScaleSets \  
  --node-zones 1 2 3 \
  --load-balancer-sku standard
  # --enable-pod-security-policy \
  # --aad-server-app-id "$(az keyvault secret show --name spn-aad-backend-clientid --vault-name $KEYVAULT_NAME --query value -o tsv)" \
  # --aad-server-app-secret "$(az keyvault secret show --name spn-aad-backend-secret --vault-name $KEYVAULT_NAME --query value -o tsv)" \
  # --aad-client-app-id "$(az keyvault secret show --name spn-aad-client-clientid --vault-name $KEYVAULT_NAME --query value -o tsv)" \
  # --aad-tenant-id $TENANTID

