if (Get-ItemProperty -path HKLM:\SOFTWARE\Microsoft\.NETFramework\v4.0.30319)
   {
   Write-host "path exist"
   cmd.exe /c "REG ADD HKLM\SOFTWARE\Microsoft\.NETFramework\v4.0.30319 /v SchUseStrongCrypto /t REG_DWORD /d 1 /f"
   New-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\.NETFramework\v4.0.30319' -Name SchUseStrongCrypto -PropertyType DWORD -Value 1 -ErrorAction SilentlyContinue
   
   }
    else
    {Write-host "HKLM:\SOFTWARE\Microsoft\.NETFramework\v4.0.30319 doesn't exist"
    }




if (Get-ItemProperty -path HKLM:\SOFTWARE\WOW6432Node\Microsoft\.NETFramework\v4.0.30319)
   {
   Write-host "path exist"
   cmd.exe /c "REG ADD HKLM\SOFTWARE\WOW6432Node\Microsoft\.NETFramework\v4.0.30319 /v SchUseStrongCrypto /t REG_DWORD /d 1 /f" 
   New-ItemProperty -Path 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\.NETFramework\v4.0.30319' -Name SchUseStrongCrypto -PropertyType DWORD -Value 1 -ErrorAction SilentlyContinue
   }
    else
    {Write-host "HKLM:\SOFTWARE\WOW6432Node\Microsoft\.NETFramework\v4.0.30319"
    }
    
New-Item -ItemType Directory -Force "c:\TEMP\Azure\MMA"

cmd.exe /c '"c:\temp\MMASetup-AMD64.exe" /c /t:c:\TEMP\Azure\MMA'
cmd.exe /c 'C:\TEMP\Azure\MMA\Setup.exe /qn NOAPM=1 ADD_OPINSIGHTS_WORKSPACE=1 OPINSIGHTS_WORKSPACE_AZURE_CLOUD_TYPE=0 OPINSIGHTS_PROXY_URL="http://webgateway-eu.schindler.com:3128" OPINSIGHTS_WORKSPACE_ID="a054b1bf-24eb-4e0b-a7e6-0fb782e77bf6" OPINSIGHTS_WORKSPACE_KEY="d/DAXhGLEcj+D+QNvTQj84jWCEcAb+jsn/37lroX0zjfBEQBIOppTeIglpqCeCHz6a/XXcyY8QgUvmrOkV+dmg==" AcceptEndUserLicenseAgreement=1"'