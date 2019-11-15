RESOURCEGROUP=rome-webapp
az group create --name $RESOURCEGROUP --location westeurope

ARMTEMPLATE_PATH=azuredeploy.json
CONTAINERREGISTRY_NAME=romeimages
CONTAINERREGISTRY_PASSWORD=$(az acr credential show -n $CONTAINERREGISTRY_NAME --query "passwords[0].value"  -o tsv)
CONTAINER_NAME=$CONTAINERREGISTRY_NAME.azurecr.io/dutchazuremeetupwebapi:627
#$DOCKERIMAGE_NAME:$BUILD_BUILDID

az group deployment create --resource-group $RESOURCEGROUP \
   --template-file $ARMTEMPLATE_PATH \
   --parameters appServicePlanName=$HOSTINGPLAN_NAME appServiceName=$WEBAPP_NAME appServiceSku=$SKU dockerImageName=$CONTAINER_NAME dockerRegistryUrl=https://$CONTAINERREGISTRY_NAME.azurecr.io dockerRegistryUsername=$CONTAINERREGISTRY_NAME dockerRegistryPassword=$CONTAINERREGISTRY_PASSWORD \
   --verbose

#before:  "cors": null,
az resource update --name web --resource-group $RESOURCEGROUP --namespace Microsoft.Web --resource-type config --parent sites/$WEBAPP_NAME --set properties.cors.allowedOrigins=null --api-version 2015-06-01

#after:
# "cors": {
#           "allowedOrigins": null,
#           "supportCredentials": false
#         },

# Disable Authentication/Authorization (aka EasyAuth) and/or CORS (if they configured it via CLI).  Both the built-in App Service Authentication/Authorization feature, as well as CORs, will cause App Service to run a container in front of your code.  It is that intermediate container that implements EasyAuth and CORS using .NET Core+Kestrel.  Disabling both feature (if they are using them) will cause App Service to not use this intermediate container, and hence you won’t run in current 25MB limit.