# Lab 1C - Managed Identity Access
# Enables the lab VM's system-assigned managed identity and grants it the
# Cosmos DB and Foundry data-plane permissions used by the workshop labs.

param(
  [Parameter(Mandatory = $false)]
  [string]$ResourceGroup = $env:LAB_RESOURCE_GROUP,

  [Parameter(Mandatory = $false)]
  [string]$VmName
)

$ErrorActionPreference = 'Stop'

az account show -o none 2>$null
if ($LASTEXITCODE -ne 0) {
  Write-Error "No active Azure CLI session. Run 'az login' first."
  exit 1
}

if (-not $ResourceGroup) {
  Write-Error "LAB_RESOURCE_GROUP is not set. Run './SetEnv.ps1' first or pass -ResourceGroup."
  exit 1
}

$subscriptionId = ([string](az account show --query id -o tsv)).Trim()

if (-not $VmName) {
  $vmNames = @(az vm list --resource-group $ResourceGroup --query "[].name" -o tsv)
  if ($LASTEXITCODE -ne 0) {
    Write-Error "Failed to list virtual machines in $ResourceGroup."
    exit 1
  }

  $vmNames = @($vmNames | Where-Object { $_ } | ForEach-Object { $_.Trim() })
  if ($vmNames.Count -eq 0) {
    Write-Error "No virtual machine found in $ResourceGroup."
    exit 1
  }
  if ($vmNames.Count -gt 1) {
    Write-Error "Multiple virtual machines found in $ResourceGroup. Pass -VmName explicitly: $($vmNames -join ', ')"
    exit 1
  }
  $VmName = $vmNames[0]
}

Write-Output "Enabling the system-assigned managed identity on $VmName..."
az vm identity assign --resource-group $ResourceGroup --name $VmName --only-show-errors | Out-Null
if ($LASTEXITCODE -ne 0) {
  Write-Error "Failed to enable the managed identity on $VmName."
  exit 1
}

$principalId = ([string](az vm show `
  --resource-group $ResourceGroup `
  --name $VmName `
  --query identity.principalId `
  -o tsv)).Trim()
if ($LASTEXITCODE -ne 0 -or -not $principalId) {
  Write-Error "The managed identity principal ID could not be resolved for $VmName."
  exit 1
}

Write-Output "Subscription:      $subscriptionId"
Write-Output "Resource group:    $ResourceGroup"
Write-Output "Virtual machine:   $VmName"
Write-Output "MSI principal ID:  $principalId"

$resourceGroupScope = "/subscriptions/$subscriptionId/resourceGroups/$ResourceGroup"
$existingContributorAssignment = az role assignment list `
  --scope $resourceGroupScope `
  --query "[?principalId=='$principalId' && roleDefinitionName=='Contributor'].id | [0]" `
  -o tsv 2>$null

if (-not $existingContributorAssignment) {
  az role assignment create `
    --assignee-object-id $principalId `
    --assignee-principal-type ServicePrincipal `
    --role Contributor `
    --scope $resourceGroupScope `
    --only-show-errors | Out-Null
  if ($LASTEXITCODE -ne 0) {
    Write-Error "Failed to grant Contributor on resource group $ResourceGroup."
    exit 1
  }
  Write-Output "Granted Contributor on resource group $ResourceGroup."
} else {
  Write-Output "Contributor already assigned on resource group $ResourceGroup."
}

$cosmosAccounts = @(az cosmosdb list --resource-group $ResourceGroup -o json | ConvertFrom-Json)
if ($LASTEXITCODE -ne 0) {
  Write-Error "Failed to list Cosmos DB accounts in $ResourceGroup."
  exit 1
}
if ($cosmosAccounts.Count -eq 0) {
  Write-Error "No Cosmos DB accounts found in $ResourceGroup."
  exit 1
}

foreach ($account in $cosmosAccounts) {
  $existingAssignment = az cosmosdb sql role assignment list `
    --resource-group $ResourceGroup `
    --account-name $account.name `
    --query "[?principalId=='$principalId' && contains(roleDefinitionId, '00000000-0000-0000-0000-000000000002')].id | [0]" `
    -o tsv 2>$null

  if (-not $existingAssignment) {
    az cosmosdb sql role assignment create `
      --resource-group $ResourceGroup `
      --account-name $account.name `
      --role-definition-id 00000000-0000-0000-0000-000000000002 `
      --principal-id $principalId `
      --scope "/" `
      --only-show-errors | Out-Null
    if ($LASTEXITCODE -ne 0) {
      Write-Error "Failed to grant Cosmos DB Built-in Data Contributor on $($account.name)."
      exit 1
    }
    Write-Output "Granted Cosmos DB Built-in Data Contributor on $($account.name)."
  } else {
    Write-Output "Cosmos DB Built-in Data Contributor already assigned on $($account.name)."
  }
}

$foundryName = ([string](az cognitiveservices account list `
  --resource-group $ResourceGroup `
  --query "[?kind=='AIServices'] | [0].name" `
  -o tsv)).Trim()
if ($LASTEXITCODE -ne 0 -or -not $foundryName) {
  Write-Error "No AIServices (Foundry) account found in $ResourceGroup."
  exit 1
}

$foundryScope = "/subscriptions/$subscriptionId/resourceGroups/$ResourceGroup/providers/Microsoft.CognitiveServices/accounts/$foundryName"
$foundryRoles = @(
  'Cognitive Services Contributor',
  'Cognitive Services OpenAI Contributor'
)

foreach ($role in $foundryRoles) {
  $existingAssignment = az role assignment list `
    --scope $foundryScope `
    --query "[?principalId=='$principalId' && roleDefinitionName=='$role'].id | [0]" `
    -o tsv 2>$null

  if (-not $existingAssignment) {
    az role assignment create `
      --assignee-object-id $principalId `
      --assignee-principal-type ServicePrincipal `
      --role $role `
      --scope $foundryScope `
      --only-show-errors | Out-Null
    if ($LASTEXITCODE -ne 0) {
      Write-Error "Failed to grant $role on $foundryName."
      exit 1
    }
    Write-Output "Granted $role on $foundryName."
  } else {
    Write-Output "$role already assigned on $foundryName."
  }
}

Write-Output ""
Write-Output "Done. Allow one to three minutes for the role assignments to propagate."