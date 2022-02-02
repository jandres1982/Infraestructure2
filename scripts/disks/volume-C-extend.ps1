# Variable specifying the drive you want to extend
$letter="C"
# Refresh available space
"rescan" | diskpart
# Script to get the partition sizes and then resize the volume
$MaxSize = (Get-PartitionSupportedSize -DriveLetter $letter).sizeMax
Resize-Partition -DriveLetter $letter -Size $MaxSize