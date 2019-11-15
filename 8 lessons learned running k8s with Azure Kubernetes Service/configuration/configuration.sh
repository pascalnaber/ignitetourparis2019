#!/bin/bash
set -e

az aks get-credentials --resource-group $RESOURCEGROUP_K8S --name $AKS_NAME --overwrite-existing --admin

# make the dashboard access work
#kubectl create clusterrolebinding kubernetes-dashboard -n kube-system --clusterrole=cluster-admin --serviceaccount=kube-system:kubernetes-dashboard
kubectl apply -f dashboard.yaml

# helm service account and other needed resources
kubectl apply -f helm.yaml

# apply taint
kubectl taint nodes aksnpwin000000 OS=Windows:NoSchedule --overwrite

# install helm locally & on the k8s cluster (tiller)
helm init --service-account tiller-serviceaccount --upgrade --force-upgrade #--node-selectors "agentpool"="linuxpool" 

# latest charts
helm repo update

NODERESOURCEGROUP=$(az aks show --resource-group $RESOURCEGROUP_K8S --name $AKS_NAME --query nodeResourceGroup -o tsv)

PUBLICIPADDRESS=$(az network public-ip show -g $NODERESOURCEGROUP -n $IPADDRESS_NAME --query 'ipAddress' -o tsv)
echo publicIP: $PUBLICIPADDRESS

# wait for ready tiller pod. otherwise: Error: could not find a ready tiller pod
sleep 60

# install ingress
helm upgrade nginxingress --install stable/nginx-ingress --namespace kube-system --set controller.replicaCount=2 --set controller.service.loadBalancerIP="$PUBLICIPADDRESS" --force 

# install keyvaultaadpodidentity
IDENTITY_CLIENTID=$(az identity show -g $RESOURCEGROUP_K8S -n $IDENTITY_AKSKEYVAULT_NAME --query clientId -o tsv)
IDENTITY_ID=$(az identity show -g $RESOURCEGROUP_K8S -n $IDENTITY_AKSKEYVAULT_NAME --query id -o tsv)

helm upgrade keyvaultaadpodidentity --debug --install ./aad-pod-identity --force --namespace kube-system --set azureIdentityBinding.selector=matrix,azureIdentity.clientID=$IDENTITY_CLIENTID,azureIdentity.resourceID=$IDENTITY_ID

helm upgrade kured --install stable/kured --namespace kured