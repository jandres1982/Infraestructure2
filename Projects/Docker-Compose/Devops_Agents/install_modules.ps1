$ProgressPreference = 'SilentlyContinue'; Invoke-WebRequest -Uri https://aka.ms/installazurecliwindows  -OutFile .\AzureCLI.msi; Start-Process msiexec.exe -Wait -ArgumentList '/I AzureCLI.msi /quiet'; rm .\AzureCLI.msi
Install-PackageProvider -Name NuGet -Force
Get-PackageProvider
Get-PackageSource
Install-Module -Name Az.Compute -Repository PSGallery -Force
Install-Module -Name Az.Accounts -Repository PSGallery -Force
Install-Module -Name Az.Service -Repository PSGallery -Force
Get-Module