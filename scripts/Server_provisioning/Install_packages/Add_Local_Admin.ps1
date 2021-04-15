            Function Local_admin_group           
            {
            $Host_Name = hostname
            $Server = $Host_Name.ToUpper()
            $Head = $server.Substring(0,3)
            $Header_ADGroup = "$head"+"_RES_SY_"
            $Tail_ADGroup = "_ADMIN"
            $Server_AD_Group = echo "$Header_ADGroup$Server$Tail_ADGroup"
            $GroupObj = [ADSI]”WinNT://localhost/Administrators”
            $GroupObj.Add(“WinNT://global/$Server_AD_Group")
            }
            ###########################################################################
            Local_admin_group