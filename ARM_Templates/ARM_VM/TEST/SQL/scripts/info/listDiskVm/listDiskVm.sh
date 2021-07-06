#!/bin/bash
#
# @uthor sampy
#
# DESCRIPTION:
# CREATION: 0.1 October 2019
# REQUIREMENTS: jq, azcli
#
## VARS
declare -a subscriptionArray
declare -a statediskArray
declare -a namediskArray
declare -a sizediskArray
declare -a resourcegroupArray

# COLORS
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
PURPLE='\033[0;35m'
WHITE='\033[1;37m'
OTHER='\033[1;38m'
NC='\033[0m' # No Color


## FUNCTIONS

function getListSubscriptions (){
	SAVEIFS=$IFS
	IFS=$(echo -en "\n\b")
        for subs in `az account list  | jq -r '.[].name'`
        do
                subscriptionArray+=("$subs")
        done
}

function getDiskState (){
        for subs in "${subscriptionArray[@]}"
        do
           for info in `az disk list --subscription $subs | jq -r '.[].diskState'`
           do
              statediskArray+=($info)
           done

           for name in `az disk list --subscription $subs | jq -r '.[].name'`
           do
              namediskArray+=($name)
           done

           for size in `az disk list --subscription $subs | jq -r '.[].diskSizeGb'`
           do
              sizediskArray+=($size)
           done

           for rg in `az disk list --subscription $subs | jq -r '.[].resourceGroup'`
           do
              resourcegroupArray+=($rg)
           done
        done

        for element in "${!statediskArray[@]}"
        do
            if [ "${statediskArray[$element]}" = "Unattached" ]
            then
                    echo -e "${RED}RESOURCE GROUP "  ${YELLOW}"DISK NAME " "${GREEN}SIZE"
                    echo -e "${RED} ${resourcegroupArray[$element]}"  "${YELLOW} ${namediskArray[$element]}" "${GREEN} ${sizediskArray[$element]}" |column
            fi
        done
}
## MAIN

getListSubscriptions
getDiskState
