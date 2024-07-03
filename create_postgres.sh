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

# ___DATABASE___

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

# Créer le conteneur blob
az storage container create \
    --account-name $STORAGE_NAME \
    --name $CONTAINER_NAME \
    --account-key $STORAGE_KEY

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

# Déployer la fonction
func azure functionapp publish AllocineFunctionApp \
    --settings DB_HOST=$SERVER_URL \
    --settings DB_USER=$ADMIN_USER \
    --settings DB_PASSWORD=$ADMIN_PASSWORD \
    --settings DB_DATABASE=$DATABASE_NAME \

# Récupérer la functionKey
FUNCTION_KEY=""
while [ -z "$FUNCTION_KEY" ]; do
    FUNCTION_KEY=$(az functionapp keys list \
    --name AllocineFunctionApp \
    --resource-group $RESOURCE_GROUP \
    --query default --output tsv)
    if [ -z "$FUNCTION_KEY" ]; then
        echo "Waiting for function to be ready..."
        sleep 50
    fi
done
echo FUNCTION_KEY=$FUNCTION_KEY >> .env
echo "Function key retrieved and saved to .env file."

# ___DATAFACTORY___

# Créer datafactory
az datafactory create \
    --resource-group $RESOURCE_GROUP \
    --factory-name $DATAFACT_NAME\

# ___FUNCTION linked service___

FunctionLinkedServiceName="FunctionLinkedService"
Functionjsonpath="json/function_properties.json"

# Attention jq doit être installé sur votre machine
FunctionServiceContent=$(cat $Functionjsonpath | jq -c '.')

# Créer le linked service
az datafactory linked-service create \
    --factory-name $DATAFACT_NAME \
    --properties "$FunctionServiceContent" \
    --name $FunctionLinkedServiceName \
    --resource-group $RESOURCE_GROUP


# ___PIPELINE___

PipelineName="PythonPipeline"
Pipelinejsonpath="json/pipeline_properties.json"

# Attention jq doit être installé sur votre machine
PipelineContent=$(cat $Pipelinejsonpath | jq -c '.')

# Créer le linked service
az datafactory pipeline create \
    --factory-name $DATAFACT_NAME \
    --pipeline "$PipelineContent" \
    --name $PIPELINE_NAME \
    --resource-group $RESOURCE_GROUP


# ___TRIGGER___

TriggerName="TriggerPythonPipeline"
Triggerjsonpath="json/trigger_properties.json"

# Attention jq doit être installé sur votre machine
TriggerContent=$(cat $Triggerjsonpath | jq -c '.')

# Créer le Trigger
az datafactory trigger create \
    --factory-name $DATAFACT_NAME \
    --properties "$TriggerContent" \
    --name $TriggerName \
    --resource-group $RESOURCE_GROUP

# Démarrer le trigger
az datafactory trigger start \
    --resource-group $RESOURCE_GROUP \
    --factory-name $DATAFACT_NAME \
    --name $TriggerName

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
FUNCTION_KEY=$FUNCTION_KEY
EOT

echo ".env file created successfully with the following content:"
cat .env
