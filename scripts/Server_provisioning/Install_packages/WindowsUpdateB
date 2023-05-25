   
  <#verifica si esta instalada la libreria previa a la instalacion#> 
  $provider= Get-Package -Name Nuget -EA Ignore
  if ($provider) {
    $installed = $true
  }else{
      $installed = $false
  }
  if ($installed -eq $false) {
      Install-Package -Name Nuget -Force 
  }
  
  
  
  <#verifica si esta instalado el modulo de actualizaciones de windows#>
  $moduleInstalled = Get-Module -Name PSWindowsUpdate -ListAvailable
  
  if ($moduleInstalled) {
      $isModuleInstalled = $true
  } else {
      $isModuleInstalled = $false
  }
  <#ejecuta el analisis y la instalacion de las actualizaciones del equipo,
   primero verificando si existe alguna disponible#>
  if ($isModuleInstalled -eq $true) {
      $updatesVerify = Get-WindowsUpdate 
  if($updatesVerify){
  $verify = $true
  }else{
      $verify = $false
  }
      if ($verify -eq $true) {
          
          Get-WindowsUpdate -AcceptAll -Install -IgnoreReboot
  Write-OutPut "Updates has been installed"
  
              }else{
                   Write-Output "No Updates are needed"
                      }
  }else{
      Install-Module PSWindowsUpdate -Force
      if ($verify -eq $true) {
          Get-WindowsUpdate -AcceptAll -Install -IgnoreReboot
              }else{
                   Write-Output "No Updates are needed"
                      }
      
      
     }