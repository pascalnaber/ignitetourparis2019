set -x -e

az group create --name $RESOURCEGROUP --location westeurope

CONTAINER_NAME=$CONTAINERREGISTRY_NAME.azurecr.io/$DOCKERIMAGE_NAME:$BUILD_BUILDID
CONTAINERREGISTRY_PASSWORD=$(az acr credential show -n $CONTAINERREGISTRY_NAME --query "passwords[0].value"  -o tsv)

az appservice plan create -n $HOSTINGPLAN_NAME -g $RESOURCEGROUP --is-linux --sku S1 --number-of-workers 2
az webapp create -n $WEBAPP_NAME -g $RESOURCEGROUP -p $HOSTINGPLAN_NAME -i $CONTAINER_NAME

az webapp deployment slot create --name $WEBAPP_NAME --resource-group $RESOURCEGROUP --slot staging

az webapp config container set -n $WEBAPP_NAME --slot staging -g $RESOURCEGROUP -c $CONTAINER_NAME -r https://$CONTAINERREGISTRY_NAME.azurecr.io -u $CONTAINERREGISTRY_NAME -p $CONTAINERREGISTRY_PASSWORD

# not supported yet on Linux
# az webapp deployment slot auto-swap --slot staging --name $WEBAPP_NAME --resource-group $RESOURCEGROUP #--auto-swap-slot $WEBAPP_NAME 

# enable diagnostics
az webapp log config --name $WEBAPP_NAME --slot staging --resource-group $RESOURCEGROUP --docker-container-logging filesystem

# Enable AlwaysOn
az webapp config set --name $WEBAPP_NAME --slot staging --resource-group $RESOURCEGROUP --always-on true

# Disable ARR affinity & configure HTTPS only
az webapp update --name $WEBAPP_NAME --slot staging --resource-group $RESOURCEGROUP --client-affinity-enabled false --https-only true
