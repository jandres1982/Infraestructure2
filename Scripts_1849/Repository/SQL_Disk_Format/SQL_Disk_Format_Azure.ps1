            Function SQL_Disk
            {
            Get-Disk |
            
            Where partitionstyle -eq ‘raw’ |
            
            Initialize-Disk -PartitionStyle GPT -PassThru
            
            New-Partition -AssignDriveLetter "2" -UseMaximumSize |
            Format-Volume -FileSystem NTFS -AllocationUnitSize 65536 -NewFileSystemLabel “SYSDB” -Confirm:$false
            
            New-Partition -AssignDriveLetter "3" -UseMaximumSize |
            Format-Volume -FileSystem NTFS -AllocationUnitSize 65536 -NewFileSystemLabel “USERDB” -Confirm:$false
            
            New-Partition -AssignDriveLetter "4" -UseMaximumSize |
            Format-Volume -FileSystem NTFS -AllocationUnitSize 65536 -NewFileSystemLabel “LOGDB” -Confirm:$false
            
            New-Partition -AssignDriveLetter "5" -UseMaximumSize |
            Format-Volume -FileSystem NTFS -AllocationUnitSize 65536 -NewFileSystemLabel “TEMPDB” -Confirm:$false
            }

            ###########################################################################################
              SQL_Disk