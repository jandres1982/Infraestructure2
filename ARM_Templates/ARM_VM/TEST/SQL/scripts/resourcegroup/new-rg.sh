#!/bin/bash

###Select subscription###
az account set --subscription $subscription

###Resource Group Creation###
az group create -l $location -n $name \
--tags applicationowner=$applicationowner costcenter=$costcenter infrastructureservice=$infrastructureservice kg=$kg serviceowner=$serviceowner technicalcontact=$technicalcontact