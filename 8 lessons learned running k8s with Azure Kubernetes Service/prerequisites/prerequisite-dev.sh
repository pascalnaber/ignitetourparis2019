#!/bin/bash

LOCATION=westeurope
REPLICATION_LOCATION=northeurope

RESOURCEGROUP_NETWORK=matrix-network-dev-we
RESOURCEGROUP_DATA=matrix-data-dev-we
RESOURCEGROUP_K8S=matrix-k8s-dev-we
RESOURCEGROUP_KEYVAULT=matrix-keyvault-dev-we
RESOURCEGROUP_COMMON=matrix-common-we

SPN_REGISTRY_NAME=spn-matrix-registry
SPN_DEPLOY_NAME=spn-matrix-deployment-dev
SPN_AKS_NAME=spn-matrix-k8s-dev
IDENTITY_AKSKEYVAULT_NAME=identity-kv-aks-dev

KEYVAULT_NAME=matrix-secrets-dev #Make sure this is a unique name
REGISTRY_NAME=matriximages  #Make sure this is a unique name



. ./prerequisite.sh