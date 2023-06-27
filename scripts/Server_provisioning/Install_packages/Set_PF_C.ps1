if ($(Get-ItemProperty -path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management' -Name 'PagingFiles').PagingFiles -eq 'T:\pagefile.sys 0 0') 
{
    Write-Output "All Ok Page File is already in T:\"
}
else {
    Set-Itemproperty -path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management' -Name 'PagingFiles' -value 'C:\pagefile.sys 0 0'
    restart-computer -force
}




