#############################################################################
# Script: Delete all Files on a NAS share
# Author: Michael Barmettler
# Date: 20/01/2016
# Comments:
# Pre-Requisites: Full Control over destination folder.
#############################################################################



#Specify the target folder where files should be deleted
$targetfolder = "\\crdv0001.crd.schindler.com\admincrd$\data\QTREE2\USRCRD\"

#Delete all files and folders
Get-ChildItem $targetfolder -Recurse -Force | Remove-Item -Recurse -Force