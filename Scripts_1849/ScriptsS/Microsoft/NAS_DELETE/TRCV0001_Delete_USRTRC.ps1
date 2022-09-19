#############################################################################
# Script: Delete all Files on a NAS share
# Author: Michael Barmettler
# Date: 20/01/2016
# Comments:
# Pre-Requisites: Full Control over destination folder.
#############################################################################


#Specify the target folder where files should be deleted
$targetfolder = "\\trcv0001\admintrc$\data\data_home\"

#Delete all files and folders
Get-ChildItem $targetfolder -Recurse -Force | Remove-Item -Recurse -Force