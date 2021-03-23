Set-Itemproperty -path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management' -Name 'PagingFiles' -value 'T:\pagefile.sys 0 0'
restart-computer -force