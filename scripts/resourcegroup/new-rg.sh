#!/bin/bash

###Select subscription###
az account set --subscription $subscription

###Resource Group Creation###
az group create -l $location -n $name --tags owner=$owner deputyowner=$deputyowner kg=$kg costcenter=$costcenter

