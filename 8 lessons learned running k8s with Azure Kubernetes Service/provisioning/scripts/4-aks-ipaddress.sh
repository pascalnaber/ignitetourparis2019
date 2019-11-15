#!/bin/bash

NODERESOURCEGROUP=$(az aks show --resource-group $RESOURCEGROUP_K8S --name $AKS_NAME --query nodeResourceGroup -o tsv)
 
# az network public-ip create --resource-group $NODERESOURCEGROUP --name $IPADDRESS_NAME --allocation-method static --dns-name a$(cat /proc/sys/kernel/random/uuid)
az network public-ip create --resource-group $NODERESOURCEGROUP --name $IPADDRESS_NAME --allocation-method static --sku Standard --dns-name a$(cat /proc/sys/kernel/random/uuid)