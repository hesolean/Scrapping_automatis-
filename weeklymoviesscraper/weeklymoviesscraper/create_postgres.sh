RESOURCE_GROUP="RG_DUBOURG"
LOCATION="francecentral"
SERVER_NAME="serveurdemerde"
ADMIN_PASSWORD="lndub12!3"
ADMIN_USER="adminlnd"
DATABASE_NAME="movies"

# j'efface le fichier .env avant de lancer le script pour que les informations ne soient pas en double et à jour
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
EOT

echo ".env file created successfully with the following content:"
cat .env
