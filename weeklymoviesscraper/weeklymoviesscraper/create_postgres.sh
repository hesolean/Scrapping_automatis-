# Déclaration des variables
RESOURCE_GROUP=RG_DUBOURG
LOCATION=francecentral
SERVER_NAME=moviesserver
SKU_SERVER=Standard_D2s_v3
# Base de données
ADMIN_PASSWORD=lndub12!3
ADMIN_USER=adminlnd
DATABASE_NAME=movies
# Stockage
STORAGE_NAME=moviesstoragedubourg
SKUNAME=Standard_LRS
CONTAINER_NAME=moviescontainer
# Datafactory
DATAFACT_NAME=moviesdatatfact
PIPELINE_NAME=moviespipeline
BATCH_ACCOUNT_NAME=scrapybatch
BATCH_RESOURCE_GROUP=RG_BATCH
POOL_NAME=scrapypool_e

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
    --sku-name $SKU_SERVER \
    --database-name $DATABASE_NAME

# Attendre que le serveur PostgreSQL soit disponible et récupérer l'URL
SERVER_URL=""
while [ -z "$SERVER_URL" ]; do
    SERVER_URL=$(az postgres flexible-server show \
        --name $SERVER_NAME \
        --resource-group $RESOURCE_GROUP \
        --query 'fullyQualifiedDomainName' \
        --output tsv)
    if [ -z "$SERVER_URL" ]; then
        echo "Waiting for PostgreSQL server to be ready..."
        sleep 50
    fi
done

# # Créer un compte de stockage
# az storage account create \
#     --name $STORAGE_NAME \
#     --resource-group $RESOURCE_GROUP \
#     --location $LOCATION \
#     --sku $SKUNAME \
#     --encryption-services blob

# # Récupérer la clé de stockage
# STORAGE_KEY=$(az storage account keys list \
#     --resource-group $RESOURCE_GROUP \
#     --account-name $STORAGE_NAME \
#     --query '[0].value' \
#     --output tsv)

# # Créer le conteneur blob
# az storage container create \
#     --account-name $STORAGE_NAME \
#     --name $CONTAINER_NAME \
#     --account-key $STORAGE_KEY

# # création datafactory
# az datafactory create \
#     --resource-group $RESOURCE_GROUP \
#     --factory-name $DATAFACT_NAME\

# # récupère la chaîne de connexion
# az storage account show-connection-string \
#     --resource-group $RESOURCE_GROUP \
#     --name $STORAGE_NAME \
#     --key key1

# Générer le fichier .env avec toutes les variables
cat <<EOT > .env
PGHOST=$SERVER_URL
PGUSER=$ADMIN_USER
PGPORT=5432
PGDATABASE=$DATABASE_NAME
PGPASSWORD=$ADMIN_PASSWORD
DATABASE_URL=postgresql+psycopg2://$ADMIN_USER:$ADMIN_PASSWORD@$SERVER_URL:5432/$DATABASE_NAME
STORAGE_NAME=stdubourg
SKU_SERVER=$SKU_SERVER
SKUNAME=$SKUNAME
CONTAINER_NAME=$CONTINER_NAME
STORAGE_KEY=$STORAGE_KEY
DATAFACT_NAME=$DATAFACT_NAME
PIPELINE_NAME=$PIPELINE_NAME
BATCH_ACCOUNT_NAME=$BATCH_ACCOUNT_NAME
BATCH_RESOURCE_GROUP=$BATCH_RESOURCE_GROUP
POOL_NAME=$POOL_NAME
EOT

echo ".env file created successfully with the following content:"
cat .env

# # Exécuter le scrapping
# cd spiders
# scrapy crawl allomovies -O allomovies.csv