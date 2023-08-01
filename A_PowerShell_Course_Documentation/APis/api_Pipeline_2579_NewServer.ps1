# Replace these variables with your actual values
$organizationUrl = "https://dev.azure.com/devsdb"
$projectName = "SIS-Azure_OP-Automation"
$personalAccessToken = "2iorsurunvakcaqqjdevtggtm23gabou4llrbkm5y4awwvm35ljq"
$pipelineId = "1764"
$varname1 = "vm"
$varvalue1 = "zzzwsr0012"
$varname2 = "domain"
$varvalue2 = "global"
$varname3 = "sub"
$varvalue3 = "s-sis-eu-nonprod-01"
$varname4 = "vmSize"
$varvalue4 = "Standard_DS1_v2"
$varname5 = "datasize"
$varvalue5 = "5"
$varname6 = "subnetName"
$varvalue6 = "test"
$varname7 = "zone"
$varvalue7 = "1"
$varname8 = "osversion"
$varvalue8 = "2019"
$varname9 = "ip"
$varvalue9 = ""

# Define the API endpoint
$apiUrl = "$organizationUrl/$projectName/_apis/pipelines/$pipelineId/runs?api-version=6.0-preview.1"

# Create a JSON payload for the request with variables
$variables = @{
    variables = @{
                ($varname1) = @{
            value = $varvalue1
        }
                ($varname2) = @{
            value = $varvalue2
        }
        ($varname3) = @{
            value = $varvalue3
        }
                ($varname4) = @{
            value = $varvalue4
        }
        ($varname5) = @{
            value = $varvalue5
        }
                ($varname6) = @{
            value = $varvalue6
        }
        ($varname6) = @{
            value = $varvalue6
        }
                ($varname7) = @{
            value = $varvalue7
        }
        ($varname8) = @{
            value = $varvalue8
        }
        ($varname9) = @{
            value = $varvalue9
        }
    }
}

$payload = ConvertTo-Json $variables

# Make the API request to trigger the pipeline run with variables
$response = Invoke-RestMethod -Uri $apiUrl -Method Post -Headers @{
    Authorization = "Basic " + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$personalAccessToken"))
} -ContentType "application/json" -Body $payload

# Output the response
$response