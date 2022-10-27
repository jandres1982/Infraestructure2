############ proxy ##################
#([System.Net.WebRequest]::GetSystemWebproxy()).GetProxy("https://google.com")
#Check if there is proxy behind
#To avoid using Schindler proxy:
$request = [System.Net.WebRequest]::Create('http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&client_id=2f9eefbb-eb19-486e-9bda-60c11cae3c08&resource=https://management.azure.com/')
$request.Proxy = [System.Net.WebProxy]::new() #blank proxy
    Try
       {
        $response = $request.GetResponse()
        }catch
            {
            Write-Output "Response is enabled"
            }
$content = $response.Content | ConvertFrom-Json
$ArmToken = $content.access_token

$response = Invoke-WebRequest -Uri 'http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&client_id=2f9eefbb-eb19-486e-9bda-60c11cae3c08&resource=https://management.azure.com/' -Method GET -Headers @{Metadata="true"}
$content = $response.Content | ConvertFrom-Json
$ArmToken = $content.access_token

$json = (Invoke-WebRequest -Uri https://management.azure.com/subscriptions/7fa3c3a2-7d0d-4987-a30c-30623e38756c/resourceGroups/rg-cis-test-server-01?api-version=2016-06-01 -Method GET -ContentType "application/json" -Headers @{Authorization ="Bearer $ArmToken"}).content
$sub = "s-sis-eu-prod-01"
Connect-AzAccount -AccessToken $ArmToken -Subscription $sub -AccountId $content.client_id

$spID = (Get-AzUserAssignedIdentity -ResourceGroupName "RG-GIS-PROD-SCRIPTINGSERVER-01"  -Name shhwsr1849).principalid
New-AzRoleAssignment -ObjectId $spID -RoleDefinitionName "Reader" -Scope "/subscriptions/505ead1a-5a5f-4363-9b72-83eb2234a43d/"


Connect-AzAccount -AccessToken $ArmToken -Subscription $sub -AccountId $content.client_i