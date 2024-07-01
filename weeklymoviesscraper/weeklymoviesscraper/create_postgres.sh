# Déclaration des variables
RESOURCE_GROUP="RG_DUBOURG"
LOCATION="francecentral"
SERVER_NAME="serveurdemerde"
ADMIN_PASSWORD="lndub12!3"
ADMIN_USER="adminlnd"
DATABASE_NAME="movies"
STORAGE_NAME="stdubourg"
SKUNAME=Standard_LRS
CONTAINER_NAME="contdubourg"

DATAFACT_NAME="datafactdubourg"
BATCH_ACCOUNT_NAME="datainge"
BATCH_RESOURCE_GROUP="RG_BATCH"

# Effacer le fichier .env avant de lancer le script pour que les informations ne soient pas en double et à jour
if [ -f ".env" ]; then
    rm ".env"
fi

# Créer un groupe de ressources
az group create \
    --name $RESOURCE_GROUP \
    --location $LOCATION

# Créez une instance de serveur flexible 
az postgres flexible-server create \
    --name $SERVER_NAME \
    --resource-group $RESOURCE_GROUP \
    --admin-password $ADMIN_PASSWORD \
    --admin-user $ADMIN_USER \
    --sku-name Standard_D2s_v3 \
    --database-name "movies"

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

# Créer le conteneur blob
az storage container create \
    --account-name $STORAGE_NAME \
    --name $CONTAINER_NAME \
    --account-key $STORAGE_KEY

# création datafactory
az datafactory create \
    --resource-group $RESOURCE_GROUP \
    --factory-name $DATAFACT_NAME\

# récupère la chaîne de connexion
az storage account show-connection-string \
    --resource-group $RESOURCE_GROUP \
    --name $STORAGE_NAME \
    --key key1

# création d'un linked-service
az datafactory linked-service create \
    --resource-group $RESOURCE_GROUP \
    --factory-name $DATAFACT_NAME \
    --linked-service-name AzureStorageLinkedService \
    --properties @AzureStorageLinkedService.json

# Récupérer l'URL du serveur et attendre de l'avoir pour passer à la suite
while true; do
    SERVER_URL=$(az postgres flexible-server show \
        --name $SERVER_NAME \
        --resource-group $RESOURCE_GROUP \
        --query "fullyQualifiedDomainName" \
        --output tsv)
    
    if [ -n "$SERVER_URL" ]; then
        break
    fi
    
    echo "Waiting for server to be available..."
    sleep 10
done

# Générer le fichier .env
cat <<EOT > .env
PGHOST=$SERVER_URL
PGUSER=$ADMIN_USER
PGPORT=5432
PGDATABASE=$DATABASE_NAME
PGPASSWORD=$ADMIN_PASSWORD
DATABASE_URL=postgresql+psycopg2://$ADMIN_USER:$ADMIN_PASSWORD@$SERVER_URL:5432/$DATABASE_NAME
STORAGE_NAME="stdubourg"
SKUNAME=Standard_LRS
CONTAINER_NAME=$CONTINER_NAME
STORAGE_KEY=$STORAGE_KEY
EOT

echo ".env file created successfully with the following content:"
cat .env
