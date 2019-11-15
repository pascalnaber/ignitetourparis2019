# https://docs.microsoft.com/en-us/azure/aks/azure-ad-rbac?toc=https%3A%2F%2Fdocs.microsoft.com%2Fen-us%2Fazure%2Faks%2FTOC.json&bc=https%3A%2F%2Fdocs.microsoft.com%2Fen-us%2Fazure%2Fbread%2Ftoc.json
# https://docs.microsoft.com/en-us/azure/aks/azure-ad-integration-cli
# Create the Azure AD application

APP_AAD_BACKEND_APPNAME="${AKS_NAME}Server"

APP_AAD_BACKEND_APPID=$(az ad app create \
        --display-name $APP_AAD_BACKEND_APPNAME \
        --identifier-uris "https://$APP_AAD_BACKEND_APPNAME" \
        --query appId -o tsv)

az keyvault secret set --vault-name $KEYVAULT_NAME --name 'spn-aad-backend-clientid' --value $APP_AAD_BACKEND_APPID

echo "APP_AAD_BACKEND_APPID: " $APP_AAD_BACKEND_APPID
# Update the application group membership claims
az ad app update --id $APP_AAD_BACKEND_APPID --set groupMembershipClaims=All

# Create a service principal for the Azure AD application
SPN_AAD_BACKEND_SP_ID=$(az ad sp list --display-name $APP_AAD_BACKEND_APPNAME --query "[].appId" -o tsv)
if [ -z "$SPN_AAD_BACKEND_SP_ID" ]; then
    # Not idempotent
    az ad sp create --id $APP_AAD_BACKEND_APPID 
fi

# Get the service principal secret
SPN_AAD_BACKEND_SP_SECRETKEYID=$(az ad sp credential list --id $APP_AAD_BACKEND_APPID --query "[].keyId" -o tsv)
if [ -z "$SPN_AAD_BACKEND_SP_SECRETKEYID" ]; then
    SPN_AAD_BACKEND_SP_SECRET=$(az ad sp credential reset \
        --name $APP_AAD_BACKEND_APPNAME \
        --credential-description "AKSPassword" \
        --query password -o tsv)
    echo "secret" $SPN_AAD_BACKEND_SP_SECRET
    az keyvault secret set --vault-name $KEYVAULT_NAME --name 'spn-aad-backend-secret' --value $SPN_AAD_BACKEND_SP_SECRET    
fi

# Assign permissions 
PERMISSIONS=$(az ad app permission list --id $SPN_AAD_BACKEND_SP_ID --query "[].resourceAccess[?id == 'e1fe6dd8-ba31-4d61-89e7-88639da4683d'] | [].id"  -o tsv)
if [ -z "$PERMISSIONS" ];then
    az ad app permission add \
        --id $SPN_AAD_BACKEND_SP_ID \
        --api 00000003-0000-0000-c000-000000000000 \
        --api-permissions e1fe6dd8-ba31-4d61-89e7-88639da4683d=Scope 06da0dbc-49e2-44d2-8312-53f166ab848a=Scope 7ab1d382-f21e-4acd-a863-ba3e13f7da61=Role

        az ad app permission grant --id $SPN_AAD_BACKEND_SP_ID --api 00000003-0000-0000-c000-000000000000
        az ad app permission admin-consent --id  $SPN_AAD_BACKEND_SP_ID
fi

#  Create the Azure AD app for the client component
APP_AAD_CLIENT_APPID=$(az ad app create \
    --display-name "${AKS_NAME}Client" \
    --native-app \
    --reply-urls "https://${AKS_NAME}Client" \
    --query appId -o tsv)
az keyvault secret set --vault-name $KEYVAULT_NAME --name 'spn-aad-client-clientid' --value $APP_AAD_CLIENT_APPID 

# Create a service principal for the client application
SERVICEPRINCIPAL_ID=$(az ad sp list --display-name ${AKS_NAME}Client --query "[].appId" -o tsv)
if [ -z "$SERVICEPRINCIPAL_ID" ]; then
    # Not idempotent
    az ad sp create --id $APP_AAD_CLIENT_APPID
fi

# Get the oAuth2 ID for the server app to allow the authentication flow between the two app components
OAUTHPERMISSIONID=$(az ad app show --id $APP_AAD_BACKEND_APPID --query "oauth2Permissions[0].id" -o tsv)

# Add the permissions for the client application and server application components to use the oAuth2 communication flow 
az ad app permission add --id $APP_AAD_CLIENT_APPID --api $APP_AAD_BACKEND_APPID --api-permissions $OAUTHPERMISSIONID=Scope
az ad app permission grant --id $APP_AAD_CLIENT_APPID --api $APP_AAD_BACKEND_APPID