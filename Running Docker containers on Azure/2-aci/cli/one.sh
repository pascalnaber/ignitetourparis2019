RESOURCEGROUP=rome-aci
az group create --name $RESOURCEGROUP --location westeurope

CONTAINERREGISTRY_NAME=romeimages

az container create \
    --resource-group rome-aci \
    --name backend \
    --ports 80 \
    --image $CONTAINERREGISTRY_NAME.azurecr.io/dutchazuremeetupwebapi:627 \
    --registry-login-server $CONTAINERREGISTRY_NAME.azurecr.io \
    --registry-username $CONTAINERREGISTRY_NAME \
    --registry-password $(az acr credential show -n $CONTAINERREGISTRY_NAME --query "passwords[0].value"  -o tsv) \
    --dns-name-label aci-rome \
    --query ipAddress.fqdn