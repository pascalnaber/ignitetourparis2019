set -x

RESOURCEGROUP=rome-aci
ARMTEMPLATE_PATH=azuredeploy.json
az group create --name $RESOURCEGROUP --location westeurope
CONTAINERREGISTRY_NAME=romeimages
CONTAINERREGISTRY_PASSWORD=$(az acr credential show -n $CONTAINERREGISTRY_NAME --query "passwords[0].value"  -o tsv)

echo "registrypassword: $CONTAINERREGISTRY_PASSWORD"

az group deployment create --resource-group $RESOURCEGROUP \
   --template-file $ARMTEMPLATE_PATH \
   --parameters name=aci-demo imageRegistryServer=$CONTAINERREGISTRY_NAME.azurecr.io imageRegistryUsername=$CONTAINERREGISTRY_NAME imageRegistryPassword=$CONTAINERREGISTRY_PASSWORD \
   --verbose


   