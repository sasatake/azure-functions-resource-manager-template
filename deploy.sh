#!bin/bash

set -eu

##############################################################

location="japaneast"
serviceId="user-manager"
deploymentName=$serviceId"-deployment"

##############################################################

function getResourceGroupName(){
  az deployment show \
    --name user-manager-deployment \
    --output tsv \
    --query properties.outputs.resourceGroupName.value
}

function getStorageName(){
  az deployment show \
    --name user-manager-deployment \
    --output tsv \
    --query properties.outputs.storageName.value
}

function getContainerName(){
  az deployment show \
    --name user-manager-deployment \
    --output tsv \
    --query properties.outputs.containerName.value
}

function validate(){
  az deployment validate \
    -l $location \
    --template-file templates/init.json \
    --parameters \
      serviceId=$serviceId \
      location=$location
}

function init(){
  az deployment create \
    -n $deploymentName \
    -l $location \
    --template-file templates/init.json \
    --parameters \
      serviceId=$serviceId \
      location=$location
}

function uploadLinkedTemplate(){
  storageName=`getStorageName`
  containerName=`getContainerName`

  az storage blob upload-batch \
    --account-name $storageName \
    --destination $containerName \
    --source templates/linked/ \
    --pattern *.json
}

function clear(){
  resourceGroupName=`getResourceGroupName`

  az deployment delete -n $deploymentName
  az group delete -n $resourceGroupName
}

case "${1:-''}" in
  "clear") clear ;;
  "validate") validate ;;
  "upload") uploadLinkedTemplate ;;
  * ) validate && init && uploadLinkedTemplate ;;
esac

