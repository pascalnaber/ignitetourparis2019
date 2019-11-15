#!/bin/bash

. ./1-resourcegroups.sh
. ./2-keyvault.sh
. ./3-appregistration-deployment.sh
. ./4-appregistration-deployment-keyvault.sh
. ./5-appregistration-aks.sh
. ./6-managedidentity-aks-keyvault.sh
#. ./7-aad-aks.sh
. ./8-containerregistry.sh