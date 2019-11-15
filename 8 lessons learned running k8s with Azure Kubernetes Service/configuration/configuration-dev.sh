#!/bin/bash

TENANTID=$(az account show --query tenantId -o tsv)
RESOURCEGROUP_K8S=matrix-k8s-dev-we
AKS_NAME=matrix-aks-dev-we
IDENTITY_AKSKEYVAULT_NAME=identity-kv-aks-dev
IPADDRESS_NAME=matrix-aks-ip-dev-we #same as provisioning

. ./configuration.sh