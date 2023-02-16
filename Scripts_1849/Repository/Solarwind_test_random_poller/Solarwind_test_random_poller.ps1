$poller_num = Get-Random -Maximum 3
If ($poller_num -eq 0)
{
$poller = "shhwsr2181"
install aget poll1

}else
     {
     If ($poller_num -eq 1)
        {
         $poller = "shhwsr2182"
          install aget poll2
        }
             else
             {
             $poller = "shhwsr2183"
             install aget poll3
             }
    }