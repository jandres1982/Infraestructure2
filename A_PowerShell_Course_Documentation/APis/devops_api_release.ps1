$token = "lbivwvgk47bqvdohdkynady3u5mq6ipejrw5jx5ti3zjfvyp4aha"
$token = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes(":$token"))
$ORGANIZATION = "devsdb"
$PROJECT = "SIS-IOC-Azure"
#$id = "599"

$reqParams = @{
  "URI"     = "https://vsrm.dev.azure.com/$ORGANIZATION/$PROJECT/_apis/release/releases?api-version=7.0";
  "Method"  = "POST";
  "Headers" = @{
    "Authorization" = "Basic " + $token;
    "Content-Type"  = "application/json";
    "Accept"        = "application/json";
  };
  "Body"    = @{
    "definitionId"       = 114;
    "description"        = "Creating Sample release";
    "artifacts"          = @(
      @{
        "alias"             = "_Infraestructure";
        "instanceReference" = @{
          "id"            = "9e5d607d9814b513b43727780e1688d1bb97182d";
          "name"          = "9e5d607d";
          "sourceBranch"  = "master";
          "commitMessage" = "Update azure-pipelines.yml for Azure Pipelines";
        };
      }
    );
    "isDraft"            = $false;
    "reason"             = "none";
    "manualEnvironments" = $null

  } | ConvertTo-Json -Depth 5;
}

Invoke-WebRequest @reqParams



######

$Body = @{
  "definitionId"       = 1;
  "description"        = "Creating Sample release";
  "artifacts"          = @(
    @{
      "alias"             = "Fabrikam.CI";
      "instanceReference" = @{
        "id"   = "2";
        "name" = $null
      };
    }
  );
  "isDraft"            = $false;
  "reason"             = "none";
  "manualEnvironments" = $null

} | ConvertTo-Json -Depth 5


$Body = @{
  "resources": {
    "repositories": {
      "self": {
        "refName": "refs/heads/main"
      }
    }
  },
  "templateParameters": {
    "vm":"zzzwsr0999"
    "mac":"000056e2e1e4"
    "osversion":"2019"
    "templateKgId":"855"
    "function":"test server devops pipeline" },
  "variables": {}
}@