#!/bin/bash

# Récupérer les variables de .env
set -o allexport
source .env
set +o allexport

# Variables
VM_SIZE="STANDARD_A1_v2"
NODE_COUNT=2
IMAGE="UbuntuServer"
IMAGE_VERSION="20_04-LTS"
NODE_AGENT_SKU_ID="batch.node.ubuntu 18.04"

# Créer un compte Batch
az batch account create \
    --name $BATCH_ACCOUNT_NAME \
    --storage-account $STORAGE_NAME \
    --resource-group $RESOURCE_GROUP \
    --location $LOCATION

# Lier le compte Batch avec l'abonnement Azure
az batch account login \
    --name $BATCH_ACCOUNT_NAME \
    --resource-group $RESOURCE_GROUP \
    --shared-key-auth

# Créer un pool Batch
az batch pool create \
    --id $POOL_NAME \
    --vm-size $VM_SIZE \
    --target-dedicated-nodes $NODE_COUNT \
    --image canonical:$IMAGE:$IMAGE_VERSION\
    --node-agent-sku-id $NODE_AGENT_SKU_ID

# Vérifier la création du pool
echo "Le pool $POOL_ID a été créé avec succès."
