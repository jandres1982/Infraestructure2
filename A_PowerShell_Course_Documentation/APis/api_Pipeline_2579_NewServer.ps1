# Replace these variables with your actual values
$organizationUrl = "https://dev.azure.com/devsdb"
$projectName = "SIS-Azure_OP-Automation"
$personalAccessToken = "2iorsurunvakcaqqjdevtggtm23gabou4llrbkm5y4awwvm35ljq"
$pipelineId = "1764"
$varname1 = "vm"
$varvalue1 = ""
$varname2 = "domain"
$varvalue2 = ""
$varname3 = "sub"
$varvalue3 = ""
$varname4 = "vmSize"
$varvalue4 = ""
$varname5 = "datasize"
$varvalue5 = ""
$varname6 = "existingSubnetName"
$varvalue6 = ""
$varname7 = "zone"
$varvalue7 = ""
$varname8 = "osversion"
$varvalue8 = ""
$varname8 = "ip"
$varvalue8 = ""

# Define the API endpoint
$apiUrl = "$organizationUrl/$projectName/_apis/pipelines/$pipelineId/runs?api-version=6.0-preview.1"

sub=$(sub) vmSize=$(vmsize) datasize=$(drive_d_size_GB) vmname=$(vm) existingSubnetName=$(subnetName) zone=$(zone) osversion=$(OSversion) ip=$(ip)

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
    }
}

$payload = ConvertTo-Json $variables

# Make the API request to trigger the pipeline run with variables
$response = Invoke-RestMethod -Uri $apiUrl -Method Post -Headers @{
    Authorization = "Basic " + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$personalAccessToken"))
} -ContentType "application/json" -Body $payload

# Output the response
$response