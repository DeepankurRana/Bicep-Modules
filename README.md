# Azure Static Web App with Bicep and Azure DevOps Integration

This repository contains Bicep templates and Azure DevOps pipeline configuration to deploy an Azure Static Web App with automatic CI/CD integration.

## 🏗️ Architecture Overview

The solution includes:
- **Static Web App Module** (`staticWebApp.bicep`) - Bicep module for creating the static web app resource
- **Main Template** (`main.bicep`) - Main Bicep template that calls the module
- **Parameters File** (`parameters.json`) - Configuration parameters for deployment
- **Azure DevOps Pipeline** (`azure-pipelines.yml`) - CI/CD pipeline for automated deployment

## 📋 Prerequisites

1. **Azure Subscription** with appropriate permissions
2. **Azure DevOps Organization** and Project
3. **Azure Service Connection** configured in Azure DevOps
4. **Personal Access Token (PAT)** for Azure DevOps repository access

## 🚀 Features

- ✅ **System-assigned Managed Identity** automatically enabled
- ✅ **Azure DevOps Integration** with automatic deployments
- ✅ **Custom Domain Support** (optional)
- ✅ **Role-based Access Control** support
- ✅ **Staging Environment** support
- ✅ **Build Configuration** flexibility
- ✅ **Health Checks** and validation

## 📁 File Structure

```
├── staticWebApp.bicep      # Static Web App Bicep module
├── main.bicep             # Main Bicep template
├── parameters.json        # Deployment parameters
├── azure-pipelines.yml    # Azure DevOps pipeline
├── README.md             # This file
└── index.html            # Your static web app content
```

## ⚙️ Configuration

### 1. Update Parameters

Edit `parameters.json` with your specific values:

```json
{
  "staticWebAppName": {
    "value": "your-static-web-app-name"
  },
  "repositoryUrl": {
    "value": "https://dev.azure.com/YourOrg/YourProject/_git/YourRepo"
  },
  "repositoryToken": {
    "value": "YOUR_AZURE_DEVOPS_PAT_TOKEN"
  }
}
```

### 2. Configure Azure DevOps Pipeline

Update the variables in `azure-pipelines.yml`:

```yaml
variables:
  azureServiceConnection: 'YourAzureServiceConnection'
  resourceGroupName: 'rg-staticwebapp-dev'
  subscriptionId: 'YOUR_SUBSCRIPTION_ID'
```

### 3. Set Up Service Connection

1. Go to Azure DevOps → Project Settings → Service Connections
2. Create a new Azure Resource Manager connection
3. Use the connection name in your pipeline variables

## 🔧 Deployment Options

### Option 1: Azure DevOps Pipeline (Recommended)

1. **Push to Repository**: The pipeline triggers automatically on changes to:
   - `index.html`
   - `src/*`
   - `assets/*`
   - Bicep templates
   - Parameters file

2. **Manual Trigger**: You can also trigger the pipeline manually from Azure DevOps

### Option 2: Manual Deployment

```bash
# Create resource group
az group create --name rg-staticwebapp-dev --location "East US 2"

# Deploy the Bicep template
az deployment group create \
  --resource-group rg-staticwebapp-dev \
  --template-file main.bicep \
  --parameters @parameters.json
```

## 🏃‍♂️ Pipeline Stages

### 1. **Deploy Infrastructure**
- Creates resource group
- Deploys Bicep templates
- Configures Static Web App with system identity
- Retrieves deployment token

### 2. **Deploy Application**
- Gets Static Web App details
- Deploys application content using deployment token
- Updates the static web app automatically

### 3. **Post Deployment**
- Performs health checks
- Validates deployment success
- Displays the application URL

## 🔐 Security Features

### System-Assigned Managed Identity
The Static Web App is automatically configured with a system-assigned managed identity:

```bicep
managedIdentities: {
  systemAssigned: true
}
```

### Access Control
Role assignments can be configured through the `roleAssignments` parameter:

```json
"roleAssignments": [
  {
    "principalId": "user-or-group-object-id",
    "roleDefinitionIdOrName": "Website Contributor",
    "principalType": "User"
  }
]
```

## 🌐 Custom Domain Configuration

To add a custom domain, update the parameters:

```json
"customDomainName": {
  "value": "www.yourdomain.com"
}
```

## 📊 Monitoring and Outputs

The deployment provides several useful outputs:

- **Static Web App Name**: Resource name
- **Resource ID**: Full Azure resource identifier
- **Default Hostname**: Generated Azure hostname
- **System Identity Principal ID**: For role assignments
- **Deployment Token**: For CI/CD integration (secure)

## 🔄 Automatic Updates

The pipeline is configured to trigger on changes to:
- `index.html` - Your main application file
- `src/*` - Source code directory
- `assets/*` - Static assets
- Bicep templates - Infrastructure changes

## 🛠️ Customization

### Build Properties
Customize the build configuration in `parameters.json`:

```json
"buildProperties": {
  "value": {
    "appLocation": "/",
    "apiLocation": "api",
    "outputLocation": "dist"
  }
}
```

### Environment-Specific Deployments
Create separate parameter files for different environments:
- `parameters.dev.json`
- `parameters.test.json`
- `parameters.prod.json`

## 🐛 Troubleshooting

### Common Issues

1. **Pipeline Fails**: Check service connection permissions
2. **Deployment Token Issues**: Verify PAT token has correct permissions
3. **Build Failures**: Check build properties configuration
4. **Custom Domain**: Ensure DNS configuration is correct

### Useful Commands

```bash
# Check static web app status
az staticwebapp show --name <app-name> --resource-group <rg-name>

# List deployment tokens
az staticwebapp secrets list --name <app-name> --resource-group <rg-name>

# Check deployment history
az deployment group list --resource-group <rg-name>
```

## 📚 Additional Resources

- [Azure Static Web Apps Documentation](https://docs.microsoft.com/en-us/azure/static-web-apps/)
- [Bicep Documentation](https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/)
- [Azure DevOps Pipelines](https://docs.microsoft.com/en-us/azure/devops/pipelines/)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test the deployment
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.