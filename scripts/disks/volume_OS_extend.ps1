# Variable defined in release
param([string]$letter)
# Refresh available space
"rescan" | diskpart
# Script to get the partition sizes and then resize the volume
$MaxSize = (Get-PartitionSupportedSize -DriveLetter $letter).sizeMax
Resize-Partition -DriveLetter $letter -Size $MaxSize
