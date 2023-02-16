#############################################################################
# Script: Weekly delete files and folders on CRDV0001\PUBCRD
# Author: Michael Barmettler
# Date: 24/08/2015
# Comments:
# Pre-Requisites: Full Control over destination folder.
#############################################################################


#Specify how old (number of days) a file or folder has to be so that it will be deleted
$datelimit = (Get-Date).AddDays(-7)

#Specify the target folder where files should be deleted
$targetfolder = "\\crdv0001.global.schindler.com\pubcrd\"

#Specify folders that should be completely ignored
$ignorefolders = Get-Content "D:\Scripts\Schindler\Microsoft\CRDV0001_PUBCRD\CRDV0001_PUBCRD_Cleanup_Folderignore.txt"

#Specify folders where only files shall be deleted, but folders should stay
$onlyfilesnofolder = Get-Content "D:\Scripts\Schindler\Microsoft\CRDV0001_PUBCRD\CRDV0001_PUBCRD_Cleanup_OnlyFiles.txt"

#############################################################################

#Delete all files and folders. Exlude "ignorefolders" and "onlyfilesnofolder"
Get-ChildItem $targetfolder -Recurse -Force | Where-Object {$_.LastWriteTime -lt $datelimit } | Select-Object -ExpandProperty FullName | Select-String -SimpleMatch $ignorefolders -NotMatch | Select-String -SimpleMatch $onlyfilesnofolder -NotMatch |Select-Object -ExpandProperty Line | Remove-Item -Recurse -Force

#Delete all files and keep folders for "onlyfilesnofolder"
Get-ChildItem $targetfolder -Recurse -Force | Where-Object {$_.LastWriteTime -lt $datelimit -and !$_.psiscontainer } |Select-Object -ExpandProperty FullName | Select-String -SimpleMatch $onlyfilesnofolder | Select-Object -ExpandProperty Line | Remove-Item -Recurse -Force