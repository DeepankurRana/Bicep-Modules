# PowerShell deployment script for Static Web App
# This script assumes you have Azure CLI installed and are logged in

param(
    [Parameter(Mandatory=$true)]
    [string]$ResourceGroupName = "staticwebapp",
    
    [Parameter(Mandatory=$true)]
    [string]$RepositoryToken,
    
    [Parameter(Mandatory=$false)]
    [string]$RepositoryUrl = "https://github.com/your-org/your-repo",
    
    [Parameter(Mandatory=$false)]
    [string]$Branch = "main",
    
    [Parameter(Mandatory=$false)]
    [string]$Location = "swedencentral"
)

Write-Host "Starting deployment of Static Web App..." -ForegroundColor Green

try {
    # Deploy the Bicep template
    $deploymentResult = az deployment group create `
        --resource-group $ResourceGroupName `
        --template-file "StaticWebApp.bicep" `
        --parameters "@parameter.json" `
        --parameters repositoryToken="$RepositoryToken" `
        --parameters repositoryUrl="$RepositoryUrl" `
        --parameters branch="$Branch" `
        --verbose `
        --output json | ConvertFrom-Json

    if ($LASTEXITCODE -eq 0) {
        Write-Host "Deployment completed successfully!" -ForegroundColor Green
        Write-Host "Static Web App Name: $($deploymentResult.properties.outputs.name.value)" -ForegroundColor Yellow
        Write-Host "Resource ID: $($deploymentResult.properties.outputs.resourceId.value)" -ForegroundColor Yellow
    } else {
        Write-Error "Deployment failed with exit code: $LASTEXITCODE"
        exit 1
    }
} catch {
    Write-Error "An error occurred during deployment: $($_.Exception.Message)"
    exit 1
}

Write-Host "Deployment script completed." -ForegroundColor Green