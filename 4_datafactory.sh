#!/bin/bash

# Récupérer les variables de .env
set -o allexport
source .env
set +o allexport

# Déployer la fonction
func azure functionapp publish AllocineFunctionApp \
    --settings DB_HOST=$SERVER_URL \
    --settings DB_USER=$ADMIN_USER \
    --settings DB_PASSWORD=$ADMIN_PASSWORD \
    --settings DB_DATABASE=$DATABASE_NAME \

echo "function deployed successfully"

# ___DATAFACTORY___

# Créer datafactory
az datafactory create \
    --resource-group $RESOURCE_GROUP \
    --factory-name $DATAFACT_NAME\

echo "datafactory deployed successfully"

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
