#!bin/bash

set -eu

##############################################################

location="japaneast"
resourceGroupName="user-manager-service"
deploymentName=$resourceGroupName"-deployment"

##############################################################

function validate(){
  az deployment validate \
    -l $location \
    --template-file templates/init.json \
    --parameters \
      resourceGroupName=$resourceGroupName \
      resourceGroupLocation=$location
}

function init(){
  az deployment create \
    -n $deploymentName \
    -l $location \
    --template-file templates/init.json \
    --parameters \
      resourceGroupName=$resourceGroupName \
      resourceGroupLocation=$location
}

function clear(){
  az deployment delete -n $deploymentName
  az group delete -n $resourceGroupName
}

case "${1:-''}" in
  "clear") clear ;;
  "validate") validate ;;
  * ) init ;;
esac

