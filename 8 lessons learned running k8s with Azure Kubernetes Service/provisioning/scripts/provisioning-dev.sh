#!/bin/bash

LOCATION=westeurope
RESOURCEGROUP_NETWORK=matrix-network-dev-we
RESOURCEGROUP_DATA=matrix-data-dev-we
RESOURCEGROUP_K8S=matrix-k8s-dev-we
RESOURCEGROUP_KEYVAULT=matrix-keyvault-dev-we
RESOURCEGROUP_COMMON=matrix-common-we

DOMAIN_NAME=projectrome.cf
VNET_NAME=matrix-aks-vnet-dev-we
WORKSPACE_NAME=matrix-ws-dev-we # Must be a unique name
WORKSPACE_ARMTEMPLATE_PATH="../arm/resources/Microsoft.OperationalInsights/deploy.json"
AKS_NAME=matrix-aks-dev-we
AKS_NODE_COUNT=2
AKS_VERSION=1.14.8
AKS_VM_SIZE=Standard_DS2_v2
IPADDRESS_NAME=matrix-aks-ip-dev-we
TRAFFICMANAGER_NAME=matrix-tfmgr-dev-we # Must be a unique name
KEYVAULT_NAME=matrix-secrets-dev

TENANTID=$(az account show --query tenantId -o tsv)

clear
. provisioning.sh

