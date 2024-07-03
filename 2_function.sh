#!/bin/bash

# Récupérer les variables de .env
set -o allexport
source .env
set +o allexport

# ___STOCKAGE___

# Créer un compte de stockage
az storage account create \
    --name $STORAGE_NAME \
    --resource-group $RESOURCE_GROUP \
    --location $LOCATION \
    --sku $SKUNAME \
    --encryption-services blob

# Récupérer la clé de stockage
STORAGE_KEY=$(az storage account keys list \
    --resource-group $RESOURCE_GROUP \
    --account-name $STORAGE_NAME \
    --query '[0].value' \
    --output tsv)


echo "storage created successfully"

# Créer le conteneur blob
az storage container create \
    --account-name $STORAGE_NAME \
    --name $CONTAINER_NAME \
    --account-key $STORAGE_KEY

echo STORAGE_KEY=$STORAGE_KEY >> .env

# ___FUNCTION___

# Créer un espace de noms pour les fonctions
az functionapp create \
    --resource-group $RESOURCE_GROUP \
    --consumption-plan-location $LOCATION \
    --name AllocineFunctionApp \
    --os-type Linux \
    --runtime python \
    --runtime-version 3.10 \
    --functions-version 4 \
    --storage-account $STORAGE_NAME 

echo "functionapp created successfully"


