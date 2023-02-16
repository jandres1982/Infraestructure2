$OSversion = (Get-WmiObject -class Win32_OperatingSystem).caption
If ($OSversion -cmatch "2019")
{
Write-host "This is a $OSversion --> 2019"

########################### SET ACTIONS HERE #################





########################### END ACTIONS HERE #################



}else
    {
    If ($OSversion -cmatch "2016")
    {
    Write-host "This is a $OSversion --> 2016"
            ########################### SET ACTIONS HERE #################





           ########################### END ACTIONS HERE #################


    }         else
              {
              If ($OSversion -cmatch "2012")
                 {
                 Write-host "This is a $OSversion --> 2012"
              
                 ########################### SET ACTIONS HERE #################
                 
                
              
              
              
                 ########################### END ACTIONS HERE #################
              
                 }else
                 {Write-host "No version found"
                 }
              }

  }