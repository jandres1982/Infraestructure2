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

cmd.exe /c '"C:\Provision\Microsoft\Log_Analytics_Agent\MMASetup-AMD64.exe" /c /t:c:\TEMP\Azure\MMA'
cmd.exe /c 'C:\TEMP\Azure\MMA\Setup.exe /qn NOAPM=1 ADD_OPINSIGHTS_WORKSPACE=1 OPINSIGHTS_WORKSPACE_AZURE_CLOUD_TYPE=0 OPINSIGHTS_PROXY_URL="http://shhnwg1000.global.schindler.com:3128" OPINSIGHTS_WORKSPACE_ID="fa488d5a-d8e4-4437-9ccc-2ef59e9eb669" OPINSIGHTS_WORKSPACE_KEY="1DxbXeHBAM3QLWl4GcE9SF0eTCEYuyr5pAt5k3wGG+bASH/ug9XGmVUyHKGvi/nmVIAYLLvfemwkuhM0yxGWCA==" AcceptEndUserLicenseAgreement=1"'